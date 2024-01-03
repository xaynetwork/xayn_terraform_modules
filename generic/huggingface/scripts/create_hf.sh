#!/bin/bash
set -o xtrace

NAMESPACE=$1
shift
WRITE_TOKEN=$1
shift
JSON_CONF_64=$1

JSON_CONF=$(echo "$JSON_CONF_64" | base64 --decode)

URL="https://api.endpoints.huggingface.cloud/v2/endpoint/$NAMESPACE"

CURL_RESULT=$(curl $URL \
  --header 'Content-Type: application/json' \
  --header "Authorization: Bearer $WRITE_TOKEN" \
  --write-out %{http_code} \
  --data-raw "$JSON_CONF")

# Extract JSON error message
JSON_ERROR_MESSAGE=$(echo "$CURL_RESULT" | sed -n 's/{\(.*\)}.*/{\1}/p')

# Extract HTTP status code
HTTP_STATUS_CODE=$(echo "$CURL_RESULT" | sed 's/.*\([0-9]\{3\}\)$/\1/')

# Check if HTTP status code is different from 201 and exit with an error code
if [ "$HTTP_STATUS_CODE" -ne 202 ]; then
  echo "Error Message: $JSON_ERROR_MESSAGE"
  exit 1
fi
exit 0 
