# # pylint: disable=redefined-outer-name
# import builtins
# import logging
# import os
# import sys
# import typing
# import pytest
# from app.functions.shared.auth_utils import encode_auth_key
# from app.functions.shared.stacks.usage_plan_stack import (UsagePlanStack)
# from app.tests.unit.fakes import (fake_tenant_db, fake_no_tenant_db)
# from app.functions.shared.infra_repository import BotoInfraRepository
# from app.functions.shared.cloudformation_boto_repository import CloudformationBotoRepository
# import boto3
# import aws_cdk as cdk
# import subprocess


# # class MyProducer(cli.ICloudAssemblyDirectoryProducer):

# #     def __init__(self, tenant_id: str) -> None:
# #         self._tenant_id = tenant_id
# #         super().__init__()

# #     def produce(self, context: typing.Mapping[str, typing.Any]) -> str:
# #         app = cdk.App({context})
# #         stack = UsagePlanStack(app, f"UsagePlanStack",  env=cdk.Environment(
# #             account='917039226361', region='eu-west-3'), tenant_id="test", api_id="4qnmcgc1lg", stage_name="default")
# #         return app.synth().directory

# #     @property
# #     def stack_name(self):
# #         return f"UsagePlanStack-{self._tenant_id}"


# # Access the CDK Cli via the terminal
# class CdkCli():
#     @staticmethod
#     def deploy(synthDir : str, profile: str) -> bool:
#         process = subprocess.Popen(['cdk', 'deploy', '--profile', profile, '--app', synthDir], 
#                         stdout=subprocess.PIPE, 
#                         universal_newlines=True)
#         while process.poll() == None:
#             try:
#                 output = process.stdout.readline()
#                 err = process.stderr.readline()
#                 print(output.strip())
#                 print(err.strip())
#             except AttributeError as e:
#                 pass
#                 # Ignore
        
#         return process.poll() == 0
    
#     @staticmethod
#     def destroy(synthDir : str, profile: str) -> bool:
#         process = subprocess.Popen(['cdk', 'destroy', '--force', '--profile', profile, '--app', synthDir], 
#                         stdout=subprocess.PIPE, 
#                         universal_newlines=True)
#         while process.poll() == None:
#             try:
#                 output = process.stdout.readline()
#                 err = process.stderr.readline()
#                 print(output.strip())
#                 print(err.strip())
#             except AttributeError as e:
#                 pass
#                 # Ignore        
#         return process.poll() == 0
            


# def test_create_api_key():
#     profile = os.environ.get('PROFILE_B2B_DEV')
#     boto3.setup_default_session(profile_name=profile)
#     infra = BotoInfraRepository(region="eu-west-3")
#     res = infra.create_usage_plan(
#         tenant_id="test", api_id="4qnmcgc1lg", stage_name="default")
#     assert (res.api_key_id != None and res.api_key_value != None)
#     res = infra.destroy_usage_plan(res)


# def test_cdk():
#     profile = os.environ.get('PROFILE_B2B_DEV')
#     boto3.setup_default_session(profile_name=profile)

#     # producer = MyProducer(tenant_id="test")
#     # mycli = cli.AwsCdkCli.from_cloud_assembly_directory_producer(producer)

#     # mycli.list()
#     # cdk_alpha._aws_cdk_ceddda9d
#     cdkboto = CloudformationBotoRepository(region="eu-west-3")

#     stack_name = "UsagePlanStack-test"
#     app = cdk.App(context={"tenant_id": "test", "api_id": "4qnmcgc1lg", "stage_name": "default"})
#     stack = UsagePlanStack(app, stack_name, env=cdk.Environment(account='917039226361', region='eu-west-3'))
#     synth = app.synth()
#     dir=synth.directory

#     print(dir)
#     # CdkCli.deploy(synthDir=dir, profile=profile)
   
#     cdkboto.create_update(stack_name=stack_name, template=f"{dir}/{stack_name}.template.json")
#     cdkboto.destroy(stack_name=stack_name)
    

#     # CdkCli.destroy(synthDir=dir, profile=profile)
    


# if __name__ == "__main__":
#     test_cdk()

