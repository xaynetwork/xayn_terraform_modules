# Prerequisite

For working with lambda you need the following tools:

- terraform
- [aws sam cli](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-sam-cli.html)
- [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- python 3.9
- pip
- [just](https://github.com/casey/just)

# Build and run it locally

First, you need to set the `AWS_PROFILE` to `DeveloperAccess-917039226361`. The profile has various permissions
to run, deploy and test lambdas.

```shell
export AWS_PROFILE=DeveloperAccess-917039226361
# you can also place it before the just commands
AWS_PROFILE=DeveloperAccess-917039226361 just sam-build
```

## Build it locally

```shell
just sam-build
```

## Run it locally

The command below executes the lambda with the event defined in `events/event.json`.

```shell
just sam-local-invoke
```

You can also run it via the local lambda server:

```shell
just sam-start-lambda
```

After that you can use the aws cli to call the lambda locally:

```shell
just lambda-invoke <function_name>
```
