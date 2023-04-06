exports.handler = async (event) => {
  console.log("EVENT: \n" + JSON.stringify(event, null, 2));

  const apiToken = event.authorizationToken;
  const internalApiKey = "NOT_SET";
  const methodArn = event.methodArn;

  return build_policy(internalApiKey, methodArn, "Deny");
};

// https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-lambda-authorizer-output.html
function build_policy(api_token, methodArn, effect) {
  return {
    principalId: "customer_id_" + api_token,
    // used by the usage plan
    usageIdentifierKey: api_token,
    policyDocument: {
      Version: "2012-10-17",
      Statement: [
        {
          Action: "execute-api:Invoke",
          Effect: effect,
          Resource: methodArn,
        },
      ],
    },
  };
}
