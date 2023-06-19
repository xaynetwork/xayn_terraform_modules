import { UsagePlanStack } from './usage_plan_stack';
import { App } from 'aws-cdk-lib';

export interface UsagePlanProducerProps {
    tenantId: string,
    apiId: string,
    stageName: string,
    apiKeyValue: string,
    accountId: string,
    region: string
}


export class UsagePlanProducer {
    private props: UsagePlanProducerProps;

    constructor(props: UsagePlanProducerProps) {
        this.props = props;
    }

    getStackName(): string {
        return `UsagePlanStack-${this.props.tenantId}`;
    }

    async produce(): Promise<string> {
        const stack_name = this.getStackName();

        const app = new App({
            context: {
                "tenant_id": this.props.tenantId,
                "api_id": this.props.apiId,
                "stage_name": this.props.stageName,
                "api_key_value": this.props.apiKeyValue,
            }
        });
        new UsagePlanStack(app, stack_name, {
            env: { account: this.props.accountId, region: this.props.region }
        });
        return app.synth().directory;
    }
}
