# import aws_cdk as core
# import aws_cdk.assertions as assertions
# import aws_cdk as cdk

# import aws_cdk.aws_sns_subscriptions


# def test_sqs_queue_created():
#     tenant_id = 'abcd'
#     stack_name = f"UsagePlanStack-{tenant_id}"
#     api_key_value ='sdlfkjsdlgjwsldfkds'
#     api_id = '2332'
#     stage_name = 'default'
#     account_id = '23234324'
#     region = 'eu-west-3'
#     app = cdk.App(context={
#         "tenant_id": tenant_id,
#         "api_id": api_id,
#         "stage_name": stage_name,
#         "api_key_value": api_key_value
#     })
#     UsagePlanStack(app, stack_name, env=cdk.Environment(
#         account=account_id, region=region))
#     synth = app.synth()
#     synth_dir = synth.directory
#     assert synth_dir == ''