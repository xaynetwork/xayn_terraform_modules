import fetch from "node-fetch";
import pg from "pg";
import { SSMClient, GetParameterCommand } from "@aws-sdk/client-ssm";

export async function handler(event) {
  console.log(`EVENT: ${JSON.stringify(event)}`);
  console.assert(event.tenant != null, "'tenant' param required.");
  console.assert(event.command != null, "'command' param required.");

  try {
    return await execCommand(event);
  } catch (err) {
    return error(`Unknown error: ${err}`);
  }
}

function checkElasticsearchParams(event) {
  console.assert(
    event.elasticsearch_user_ssm_name != null,
    "'elasticsearch_user_ssm_name' param required."
  );
  console.assert(
    event.elasticsearch_password_ssm_name != null,
    "'elasticsearch_password_ssm_name' param required."
  );
  console.assert(
    event.elasticsearch_url_ssm_name != null,
    "'elasticsearch_url_ssm_name' param required."
  );
}

function checkPostgresParams(event) {
  console.assert(
    event.postgres_user_ssm_name != null,
    "'postgres_user_ssm_name' param required."
  );
  console.assert(
    event.postgres_password_ssm_name != null,
    "'postgres_password_ssm_name' param required."
  );
  console.assert(
    event.postgres_url_ssm_name != null,
    "'postgres_url_ssm_name' param required."
  );
}

async function execCommand(event) {
  switch (event.command) {
    case "CreateIndex":
      return await createElasticSearchIndex(event);
    case "DeleteIndex":
      return await deleteElasticSearchIndex(event);
    case "CreateDatabase":
      return await createPostgresDatabase(event);
    case "DeleteDatabase":
      return await deletePostgresDatabase(event);
    default:
      return error(`Unknown command: ${event.command}`);
  }
}

async function createElasticSearchIndex(event) {
  const request = async (tenant, user, password, url) => {
    const body = {
      mappings: {
        properties: {
          snippet: {
            type: "text",
          },
          embedding: {
            type: "dense_vector",
            dims: 128,
            index: true,
            similarity: "dot_product",
          },
          properties: {
            dynamic: false,
            properties: {
              publication_date: {
                type: "date",
              },
            },
          },
        },
      },
    };
    return await fetch(`${url}/${tenant}?pretty`, {
      method: "PUT",
      body: JSON.stringify(body),
      headers: {
        "Content-Type": "application/json",
        Authorization: basicAuthToken(user, password),
      },
    });
  };

  return await callElasticSearch("create index", event, request);
}

async function deleteElasticSearchIndex(event) {
  const request = async (tenant, user, password, url) => {
    return await fetch(`${url}/${tenant}`, {
      method: "DELETE",
      headers: {
        Authorization: basicAuthToken(user, password),
      },
    });
  };

  return await callElasticSearch("delete index", event, request);
}

async function callElasticSearch(task, event, request) {
  console.log(`${task} for ${event.tenant}`);
  checkElasticsearchParams(event);
  const client = initSSMClient();
  const config = await getElasticSearchConfig(client, event);

  let res = await request(
    event.tenant,
    config.user,
    config.password,
    config.url
  );

  try {
    checkStatus(res);
    return ok(`${task} for ${event.tenant}`);
  } catch (err) {
    return error(err);
  }
}

class HTTPResponseError extends Error {
  constructor(response) {
    super(`HTTP Error Response: ${response.status} ${response.statusText}`);
    this.response = response;
  }
}

function checkStatus(response) {
  if (response.ok) {
    // response.status >= 200 && response.status < 300
    return response;
  } else {
    throw new HTTPResponseError(response);
  }
}

function basicAuthToken(user, password) {
  const token = Buffer.from(`${user}:${password}`).toString("base64");
  return `Basic ${token}`;
}

function initSSMClient() {
  const config = { region: "eu-central-1" };
  return new SSMClient(config);
}

async function getParameter(client, name, with_decryption = false) {
  const command = new GetParameterCommand({
    Name: name,
    WithDecryption: with_decryption,
  });
  const res = await client.send(command);
  return res.Parameter.Value;
}

async function getElasticSearchConfig(client, event) {
  const user = await getParameter(client, event.elasticsearch_user_ssm_name);
  const password = await getParameter(
    client,
    event.elasticsearch_password_ssm_name,
    true
  );
  const url = await getParameter(client, event.elasticsearch_url_ssm_name);

  return {
    user: user,
    password: password,
    url: url,
  };
}

async function createPostgresDatabase(event) {
  return await callPostgres(
    "create database",
    event,
    `CREATE DATABASE ${event.tenant}`
  );
}

async function deletePostgresDatabase(event) {
  return await callPostgres(
    "delete database",
    event,
    `DROP DATABASE ${event.tenant} WITH (FORCE)`
  );
}

async function callPostgres(task, event, query) {
  console.log(`${task} for ${event.tenant}`);
  checkPostgresParams(event);
  const ssm_client = initSSMClient();
  const config = await getPostgresConfig(ssm_client, event);
  const client = await initPostgresClient(config);

  try {
    await client.query(query);
    return ok(`${task} for ${event.tenant}`);
  } catch (err) {
    return error(err);
  } finally {
    await client.end();
  }
}

async function initPostgresClient(config) {
  const client = new pg.Client({
    user: config.user,
    password: config.password,
    host: config.url,
    database: "postgres",
    port: "5432",
  });

  await client.connect();
  return client;
}

async function getPostgresConfig(client, event) {
  const user = await getParameter(client, event.postgres_user_ssm_name, true);
  const password = await getParameter(
    client,
    event.postgres_password_ssm_name,
    true
  );
  const url = await getParameter(client, event.postgres_url_ssm_name);
  const server = url.split("@")[1];

  return {
    user: user,
    password: password,
    url: server,
  };
}

function error(message) {
  return {
    statusCode: 500,
    body: `Error: ${message}`,
  };
}

function ok(message) {
  return {
    statusCode: 200,
    body: `Ok: ${message}`,
  };
}

