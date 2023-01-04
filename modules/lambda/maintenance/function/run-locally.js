import { handler } from "./index.js";

async function run() {
  let event = {
    tenant: "tenant",
    command: "DeleteDatabase",
    elasticsearch_user_ssm_name: "/elasticsearch/elasticsearch-dev/user",
    elasticsearch_password_ssm_name:
      "/elasticsearch/elasticsearch-dev/password",
    elasticsearch_url_ssm_name: "/elasticsearch/elasticsearch-dev/url",
    postgres_user_ssm_name: "/postgres/aurora-db-dev/username",
    postgres_password_ssm_name: "/postgres/aurora-db-dev/password",
    postgres_url_ssm_name: "/postgres/aurora-db-dev/url",
  };

  let res = await handler(event);
  console.log(JSON.stringify(res));
}

await run();
