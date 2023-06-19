import 'source-map-support/register';

import { AwsCredentialIdentity, Provider } from '@aws-sdk/types/dist-types';
import { DeploymentRepository } from './deployment_repository';
import { fromNodeProviderChain } from '@aws-sdk/credential-providers';
import { assertNonNull } from './utils';
import { AttributeValue } from '@aws-sdk/client-dynamodb';

interface DynamoDBRecord {
    Keys: Record<string, AttributeValue>
}

interface EventRecord {
    dynamodb: DynamoDBRecord
}

interface Event {
    Records?: [key: EventRecord];
}

export interface Context {
    tableName: string,
    region: string;
    endpoint?: string,
    apiId: string,
    apiStageName: string,
    accountId: string,
    credentials: AwsCredentialIdentity | Provider<AwsCredentialIdentity>
}


export const runPipelineHandler = async (event: Event) => {
    const tableName = assertNonNull(process.env.DB_TABLE);
    const region = assertNonNull(process.env.REGION);
    const apiId = assertNonNull(process.env.API_ID);
    const accountId = assertNonNull(process.env.ACCOUNT_ID);
    const apiStageName = assertNonNull(process.env.API_STAGE_NAME);
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

export const runPipeline = async (event: Event, context: Context) => {
    const records = event?.Records ?? [];
    const repo = new DeploymentRepository(context);
    for (const key in records) {
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
