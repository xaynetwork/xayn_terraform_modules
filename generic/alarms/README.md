# AWS Cross Account Alarms

## Usage

```hcl
module "alarm" {
  providers = {
    aws = aws.monitoring-account
    # some modules may deploy resources in the local as well as the
    # monitoring account (see ecs-service).
    # in this case we need to specify:
    aws.monitoring-account = aws.monitoring-account
  }
  source = "../../modules/alarms"

  account_id = "1234567890"
  prefix = "project_env"

  metric = {
    create_alarm    = true    # default: true
    threshold       = 0       # default: depends on the metric
    actions_enabled = true    # default: true
    alarm_actions   = ["arn"] # default: []
    ok_actions      = ["arn"] # default: []
  }

  tags = {
    Tag = "Value"
  }
}
```
