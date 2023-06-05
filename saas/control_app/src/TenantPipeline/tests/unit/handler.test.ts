// Import getAllItemsHandler function from get-all-items.mjs 
import { fromIni, fromNodeProviderChain, fromSSO } from '@aws-sdk/credential-providers';
import { runPipeline } from '../../src/handler';
// Import dynamodb from aws-sdk 
import { DynamoDBDocumentClient, ScanCommand } from '@aws-sdk/lib-dynamodb';
// import { mockClient } from "aws-sdk-client-mock";
import { describe, expect, it, jest } from '@jest/globals'
import { Credentials } from 'aws-cdk-lib/aws-rds';
import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { beforeEach } from 'node:test';




// This includes all tests for getAllItemsHandler() 
describe('Test runPipelineHandler', () => {
    // const ddbMock = mockClient(DynamoDBDocumentClient);

    beforeEach(() => {
        // ddbMock.reset();
        jest.setTimeout(60000)
      });

    it('get all tenant ids', async () => {
        const client = new DynamoDBClient({
            region: 'ddlocal',
            endpoint: 'http://localhost:8000',
            credentials: fromIni({ profile: process.env.PROFILE_B2B_DEV })
        });
        const ddbDocClient = DynamoDBDocumentClient.from(client);
        const items = await ddbDocClient.send(new ScanCommand({
            TableName: "saas_tenants"
        }));
        for (let e in items.Items){
           console.log(items.Items[+e].id)
        }
    })

    it('should return 200', async () => {
        const result = await runPipeline({
            "Records": [
                {
                    "eventID": "7de3041dd709b024af6f29e4fa13d34c",
                    "eventName": "INSERT",
                    "eventVersion": "1.1",
                    "eventSource": "aws:dynamodb",
                    "awsRegion": "region",
                    "dynamodb": {
                        "ApproximateCreationDateTime": 1479499740,
                        "Keys": {
                            "id": {
                                "S": "52003cd4-eb78-4b88-aa83-9c6a5dc711d5"
                            }
                        },
                        "SequenceNumber": "13021600000000001596893679",
                        "SizeBytes": 112,
                        "StreamViewType": "NEW_IMAGE"
                    },
                    "eventSourceARN": "arn:aws:dynamodb:region:account ID:table/BarkTable/stream/2016-11-16T20:42:48.104"
                }
            ]

        }, {
            region: 'eu-west-3',
            tableName: 'saas_tenants',
            endpoint: 'http://localhost:8000',
            // api_saas-application-plane (iq30vaeryi)
            apiId: 'iq30vaeryi',
            apiStageName: 'default',
            accountId: '917039226361',
            credentials: fromNodeProviderChain({ profile: process.env.PROFILE_B2B_DEV })
        })

        const expectedResult = {
            statusCode: 200,
        };

        // Compare the result with the expected result 
        expect(result.statusCode).toEqual(expectedResult.statusCode);
    });
}); 
