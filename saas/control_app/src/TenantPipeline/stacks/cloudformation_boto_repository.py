from __future__ import division, print_function, unicode_literals

from datetime import datetime
import logging
import json

import boto3
import botocore
import botocore.exceptions

log = logging.getLogger("deploy.cf.create_or_update")


class CloudformationBotoRepository:
    def __init__(self, region: str, endpoint_url: str | None = None) -> None:
        self._endpoint_url = endpoint_url
        self._region = region
        self._cf = boto3.client(
            "cloudformation", region_name=self._region, endpoint_url=self._endpoint_url
        )

    def create_update(self, stack_name: str, template: str):
        "Update or create stack"

        template_data = self._parse_template(template)
        # parameter_data = _parse_parameters(parameters) if parameter_data is not None

        params = {
            "StackName": stack_name,
            "TemplateBody": template_data,
            # 'Parameters': parameter_data,
        }

        try:
            if self._stack_exists(stack_name):
                print("Updating {}".format(stack_name))
                stack_result = self._cf.update_stack(**params)
                waiter = self._cf.get_waiter("stack_update_complete")
            else:
                print("Creating {}".format(stack_name))
                stack_result = self._cf.create_stack(**params)
                waiter = self._cf.get_waiter("stack_create_complete")
            print("...waiting for stack to be ready...")
            waiter.wait(StackName=stack_name)
        except botocore.exceptions.ClientError as ex:
            error_message = ex.response["Error"]["Message"]
            if error_message == "No updates are to be performed.":
                print("No changes")
            else:
                raise
        else:
            print(
                json.dumps(
                    self._cf.describe_stacks(StackName=stack_result["StackId"]),
                    indent=2,
                    default=self._json_serial,
                )
            )
            return True

    def destroy(self, stack_name: str) -> bool:
        "Remove a stack"

        # template_data = _parse_template(cf, template)
        # parameter_data = _parse_parameters(parameters) if parameter_data is not None

        params = {
            "StackName": stack_name,
        }

        try:
            stack_result = ""
            if self._stack_exists(stack_name):
                print("Deleting {}".format(stack_name))
                stack_result = self._cf.delete_stack(**params)
                waiter = self._cf.get_waiter("stack_delete_complete")
                print("...waiting for stack to be destroyed...")
                waiter.wait(StackName=stack_name)
                return True
        except botocore.exceptions.ClientError as ex:
            error_message = ex.response["Error"]["Message"]
            if error_message == "No updates are to be performed.":
                print("No changes")
                return True
            else:
                raise
        else:
            print(json.dumps(stack_result))
            return True

    def _parse_template(self, template: str):
        with open(template) as template_fileobj:
            template_data = template_fileobj.read()
        self._cf.validate_template(TemplateBody=template_data)
        return template_data

    def _parse_parameters(self, parameters):
        with open(parameters) as parameter_fileobj:
            parameter_data = json.load(parameter_fileobj)
        return parameter_data

    def _stack_exists(self, stack_name):
        stacks = self._cf.list_stacks()["StackSummaries"]
        for stack in stacks:
            if stack["StackStatus"] == "DELETE_COMPLETE":
                continue
            if stack_name == stack["StackName"]:
                return True
        return False

    def _json_serial(self, obj):
        """JSON serializer for objects not serializable by default json code"""
        if isinstance(obj, datetime):
            serial = obj.isoformat()
            return serial
        raise TypeError("Type not serializable")
