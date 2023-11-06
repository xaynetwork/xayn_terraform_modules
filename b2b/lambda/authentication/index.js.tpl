exports.handler = async (event) => {
  console.log("EVENT: \n" + JSON.stringify(event, null, 2));

  const apiToken = event.authorizationToken;
  const methodArn = event.methodArn;
  const internalApiKey = "${api_key}";

  const tmp = methodArn.split(':');
  // i.e. arn:aws:execute-api:eu-central-1:917039226361:aidokeulnk/default/DELETE/documents
  // 3: region
  // 4: awsAccountId
  // 5: path
  // path:
  //  0: restId
  //  1: stage
  //  2: method
  //  3..path.size: resource segments
  const apiGatewayArnTmp = tmp[5].split('/');
  var resource = '/'; // root resource
  if (apiGatewayArnTmp[3]) {
    resource += apiGatewayArnTmp[3];
  }

  const allowMap = {
    "${api_key_documents}": ["/documents","/candidates"],
    "${api_key_users}": ["/users", "/semantic_search", "/recommendations", "/rag"],
  }

  if (apiToken in allowMap) {
    const restId = apiGatewayArnTmp[0];
    const stage = apiGatewayArnTmp[1];
    const method = '*'; //apiGatewayArnTmp[2];
    const methodArnBase = tmp[0] + ":" + tmp[1] + ":" + tmp[2] + ":" + tmp[3] + ":" + tmp[4] + ":" + restId + "/" + stage + "/" + method;
    const allowedResources = allowMap[apiToken]
      .map((res) => [methodArnBase + res, methodArnBase + res + "/*"])
      .flat();
    return build_policy(internalApiKey, allowedResources, "Allow");
  }

  return build_policy(internalApiKey, methodArn, "Deny");
};

// https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-lambda-authorizer-output.html
function build_policy(api_token, methodArn, effect) {
  return {
    principalId: "${tenant_id}",
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
