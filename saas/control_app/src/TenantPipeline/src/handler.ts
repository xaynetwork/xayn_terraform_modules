import 'source-map-support/register';

import { AwsCredentialIdentity, Provider } from '@aws-sdk/types/dist-types';
import { DeploymentRepository } from './deployment_repository';
import { fromNodeProviderChain } from '@aws-sdk/credential-providers';



export interface Context {
  tableName: string,
  region: string;
  endpoint?: string,
  apiId: string,
  apiStageName: string,
  accountId: string,
  credentials: AwsCredentialIdentity | Provider<AwsCredentialIdentity>
}


export const runPipelineHandler = async (event: any) => {
  const tableName = process.env.DB_TABLE!;
  const region = process.env.REGION!;
  const apiId = process.env.API_ID!;
  const accountId = process.env.ACCOUNT_ID!;
  const apiStageName = process.env.API_STAGE_NAME!;
  const endpoint = process.env.DB_ENDPOINT ?? undefined;

  return runPipeline(event, {
    region: region,
    tableName: tableName,
    endpoint: endpoint,
    apiStageName: apiStageName,
    apiId: apiId,
    accountId: accountId,
    credentials: fromNodeProviderChain()
  })
}

export const runPipeline = async (event: any, context: Context) => {
  const records = event?.Records ?? [];
  const repo = new DeploymentRepository(context);
  for (let key in records) {
    const id = records[key]?.dynamodb?.Keys?.id?.S;
    if (id != null) {
      await repo.applyChange(id);
    }
  }

  const response = {
    statusCode: 200,
    body: JSON.stringify({})
  };
  return response;
}
