# pylint: disable=broad-exception-raised

import os
import boto3
import pytest
import requests

#  Make sure env variable AWS_SAM_STACK_NAME exists with the name of the stack we are going to test.


class TestApiGateway:
    @pytest.fixture()
    @pytest.mark.skip(reason="Not running integration tests ATM")
    def api_gateway_url(self):
        """Get the API Gateway URL from Cloudformation Stack outputs"""
        stack_name = os.environ.get("AWS_SAM_STACK_NAME")

        if stack_name is None:
            raise ValueError(
                "Please set the AWS_SAM_STACK_NAME environment variable to the name of your stack"
            )

        client = boto3.client("cloudformation")

        try:
            response = client.describe_stacks(StackName=stack_name)
        except Exception as exc:
            raise Exception(
                f"Cannot find stack {stack_name} \n"
                f'Please make sure a stack with the name "{stack_name}" exists'
            ) from exc

        stacks = response["Stacks"]
        stack_outputs = stacks[0]["Outputs"]
        api_outputs = [
            output for output in stack_outputs if output["OutputKey"] == "HelloWorldApi"
        ]

        if not api_outputs:
            raise KeyError(f"HelloWorldAPI not found in stack {stack_name}")

        return api_outputs[0]["OutputValue"]  # Extract url from stack outputs

    @pytest.mark.skip(reason="Not running integration tests ATM")
    def test_api_gateway(self, api_gateway_url):
        """Call the API Gateway endpoint and check the response"""
        response = requests.get(api_gateway_url, timeout=10000)

        assert response.status_code == 200
        assert response.json() == {"message": "hello world"}
