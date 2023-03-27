#!/bin/bash

invoke_lambda() {
    local FUNCTION_NAME=$1
    local PAYLOAD=$2
    local OUTPUT=$3
    local PROFILE=$4
    local REGION=$5

    aws lambda invoke --function-name "$FUNCTION_NAME" --payload "$PAYLOAD" "$OUTPUT" --profile "$PROFILE" --region "$REGION"

    local CODE
    CODE=$(jq '.statusCode' "$OUTPUT")
    if [ "$CODE" == "200" ]; then
        cat "$OUTPUT"
        rm "$OUTPUT"
    else
        exit 1
    fi
}

invoke_lambda "$1" "$2" "$3" "$4" "$5"
