#!/bin/bash
set -o xtrace

NAMESPACE=$1
shift
READ_TOKEN=$1
shift
DEPL_NAME=$1


URL="https://api.endpoints.huggingface.cloud/v2/endpoint/$NAMESPACE/$DEPL_NAME"

CURL_RESULT=$(curl $URL \
    --header "Authorization: Bearer $READ_TOKEN" \
    --write-out %{http_code})

# Extract JSON error message
JSON_ERROR_MESSAGE=$(echo "$CURL_RESULT" | sed -n 's/{\(.*\)}.*/{\1}/p')

# Extract HTTP status code
HTTP_STATUS_CODE=$(echo "$CURL_RESULT" | sed 's/.*\([0-9]\{3\}\)$/\1/')

# Check if HTTP status code is different from 200 and exit with an error code
if [ "$HTTP_STATUS_CODE" -ne 200 ]; then
  echo "Error Message: $JSON_ERROR_MESSAGE"
  exit 1
fi

echo $JSON_ERROR_MESSAGE | jq '{name:.name, model:.model.repository}'
