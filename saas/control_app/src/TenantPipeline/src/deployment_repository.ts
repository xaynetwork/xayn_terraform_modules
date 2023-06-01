import { Context } from './handler'
import 'source-map-support/register';

import { AttributeValue, DynamoDBClient, GetItemCommand, UpdateItemCommand } from '@aws-sdk/client-dynamodb';
import { CloudFormationClient, waitUntilStackCreateComplete, waitUntilStackDeleteComplete, waitUntilStackUpdateComplete, DeleteStackCommand, CreateStackCommand, ListStacksCommand, UpdateStackCommand, StackStatus, DescribeStacksCommand } from '@aws-sdk/client-cloudformation';
import { DynamoDBDocumentClient } from '@aws-sdk/lib-dynamodb';
import { WaiterState } from '@aws-sdk/util-waiter';
import * as fs from 'fs';
import { UsagePlanProducer } from './usage_plan_producer';


class DeploymentState {
    static NEEDS_UPDATE = "NEEDS_UPDATE"
    static UPDATED_IN_PROGRESS = "UPDATED_IN_PROGRESS"
    static DELETION_IN_PROGRESS = "DELETION_IN_PROGRESS"
    static DEPLOYED = "DEPLOYED"
    static DELETED = "DELETED"
    static NEEDS_DELETION = "NEEDS_DELETION"
    static UPDATE_FAILED = "UPDATE_FAILED"
    static DELETION_FAILED = "DELETION_FAILED"
}

export class DeploymentRepository {

    private context: Context;

    constructor(context: Context) {
        this.context = context;
    }


    async applyChange(id: string) {

        const ddbDocClient = this.createDynamoDbClient();
        try {
            const data = await ddbDocClient.send(new GetItemCommand({
                TableName: this.context.tableName,
                Key: {
                    id: {
                        "S": id
                    }
                }
            }));
            const item = data.Item;
            if (item != null) {
                switch (item.deployment_state.S) {
                    case DeploymentState.NEEDS_UPDATE:
                        await this.updateTenant(item);
                        break;
                    case DeploymentState.NEEDS_DELETION:
                        await this.deleteTenant(item);
                        break;
                    default:

                }
            } else {
                console.error(`No tenant found with Id ${id}`);
            }

        } catch (err) {
            console.error("Error while accessing the dyanmodb table.", err);
            throw err;
        }
    }

    private createDynamoDbClient() {
        const client = new DynamoDBClient({
            region: this.context.region,
            credentials: this.context.credentials,
            endpoint: this.context.endpoint
        });
        const ddbDocClient = DynamoDBDocumentClient.from(client);
        return ddbDocClient;
    }

    async updateTenant(item: Record<string, AttributeValue>) {

        const tenantId = item.id.S!;
        const apiKeyValue = item.plan_keys.M!.documents.S!

        await this.setDeploymentState(DeploymentState.UPDATED_IN_PROGRESS, tenantId);

        const producer = new UsagePlanProducer({
            tenantId: tenantId,
            apiId: this.context.apiId,
            stageName: this.context.apiStageName,
            apiKeyValue: apiKeyValue,
            accountId: this.context.accountId,
            region: this.context.region
        });

        const path = await producer.produce();

        const stackName = producer.getStackName()
        const stackBody = fs.readFileSync(`${path}/${stackName}.template.json`, 'utf8');
        const cloudformation = new CloudFormationClient({ region: this.context.region, credentials: this.context.credentials });

        try {
            const res = await this.createOrUpdateStack(cloudformation, stackName, stackBody)

            if (res) {
                await this.setDeploymentState(DeploymentState.DEPLOYED, tenantId);
            } else {
                await this.setDeploymentState(DeploymentState.UPDATE_FAILED, tenantId);
            }

        } catch (e) {
            await this.setDeploymentState(DeploymentState.UPDATE_FAILED, tenantId);
            throw e;
        }
    }

    async deleteTenant(item: Record<string, AttributeValue>) {
        const tenantId = item.id.S!;
        const apiKeyValue = item.plan_keys.M!.documents.S!

        await this.setDeploymentState(DeploymentState.DELETION_IN_PROGRESS, tenantId);

        const producer = new UsagePlanProducer({
            tenantId: tenantId,
            apiId: this.context.apiId,
            stageName: this.context.apiStageName,
            apiKeyValue: apiKeyValue,
            accountId: this.context.accountId,
            region: this.context.region
        });

        const stackName = producer.getStackName()
        const cloudformation = new CloudFormationClient({ region: this.context.region, credentials: this.context.credentials });

        try {
            const res = await this.destroyStack(cloudformation, stackName)
            await this.setDeploymentState(res ? DeploymentState.DELETED : DeploymentState.DELETION_FAILED, tenantId);

        } catch (e) {
            await this.setDeploymentState(DeploymentState.DELETION_FAILED, tenantId);
            throw e;
        }
    }

    async destroyStack(client: CloudFormationClient, stackName: string): Promise<boolean> {

        const listResponse = await client.send(new ListStacksCommand({}))

        const instances = listResponse.StackSummaries?.filter(f => f.StackName == stackName) ?? [];
        const waiterConfig = { client, maxWaitTime: 200, maxDelay: 2, minDelay: 1 }

        var updateResponse;
        if (instances.length > 0) {
            // destroy
            await client.send(new DeleteStackCommand({
                StackName: stackName,
            }))

            updateResponse = await waitUntilStackDeleteComplete(waiterConfig, { StackName: stackName })
            if (updateResponse.state == WaiterState.SUCCESS) {
                return true;
            } else {
                console.error(`STACK: ${updateResponse.state} ${updateResponse.reason}`);
                return false;
            }
        } else {
            // the stack does not exist so deletions was successful in the past
            return true;
        }
    }


    private async createOrUpdateStack(client: CloudFormationClient, stackName: string, stackBody: string): Promise<boolean> {

        const listResponse = await client.send(new ListStacksCommand({}))

        const instancesCreated = listResponse.StackSummaries?.filter(f => f.StackName == stackName && f.StackStatus == StackStatus.CREATE_COMPLETE) ?? [];
        const instancesRolledBacked = listResponse.StackSummaries?.filter(f => f.StackName == stackName && (f.StackStatus == StackStatus.ROLLBACK_COMPLETE || f.StackStatus == StackStatus.UPDATE_ROLLBACK_COMPLETE)) ?? [];
        const waiterConfig = { client, maxWaitTime: 200, maxDelay: 2, minDelay: 1 }
        var updateResponse;
        if (instancesRolledBacked.length > 0) {
            await client.send(new DeleteStackCommand({
                StackName: stackName
            }))

            updateResponse = await waitUntilStackDeleteComplete(waiterConfig, { StackName: stackName })
        }


        if (instancesCreated.length == 1) {
            // update
            try {
                updateResponse = await client.send(new UpdateStackCommand({
                    StackName: stackName,
                    TemplateBody: stackBody,
                }))
                updateResponse = await waitUntilStackUpdateComplete(waiterConfig, { StackName: stackName })
            } catch (e: any) {
                if (e?.message == 'No updates are to be performed.') {
                    return true;
                }

                throw e;
            }
        } else {
            updateResponse = await client.send(new CreateStackCommand({
                StackName: stackName,
                TemplateBody: stackBody,
            }))
            updateResponse = await waitUntilStackCreateComplete(waiterConfig, { StackName: stackName })
        }

        if (updateResponse.state == WaiterState.SUCCESS) {
            return true;
        } else {
            console.error(`STACK: ${updateResponse.state} ${updateResponse.reason}`);
            return false;
        }
    }

    private async setDeploymentState(state: string, id: string) {
        const ddbDocClient = this.createDynamoDbClient();
        await ddbDocClient.send(new UpdateItemCommand({
            TableName: this.context.tableName,
            Key: {
                id: {
                    "S": id
                }
            },
            ExpressionAttributeValues: {
                ":deployment_state": { "S": state },
            },
            UpdateExpression: "SET deployment_state = :deployment_state",
        }))
    }
}
