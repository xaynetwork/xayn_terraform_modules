import aws_cdk as core
import aws_cdk.assertions as assertions
from app.functions.shared.stacks.usage_plan_stack import UsagePlanStack


# example tests. To run these tests, uncomment this file along with the example
# resource in usage_plan/usage_plan_stack.py
def test_sqs_queue_created():
    app = core.App()
    stack = UsagePlanStack(app, "usage-plan")
    template = assertions.Template.from_stack(stack)

#     template.has_resource_properties("AWS::SQS::Queue", {
#         "VisibilityTimeout": 300
#     })
