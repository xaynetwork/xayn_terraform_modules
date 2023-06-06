#!/bin/bash

WORKDIR=$1
pushd $WORKDIR > /dev/null 2>&1
ARTIFACTS_DIR="$(pwd)/build/pipeline_lambda"
mkdir -p $ARTIFACTS_DIR
rm -rf ${ARTIFACTS_DIR}/* > /dev/null 2>&1
ARTIFACTS_DIR=$ARTIFACTS_DIR make > /dev/null 2>&1
pushd $ARTIFACTS_DIR > /dev/null 2>&1 && deterministic-zip -r function.zip . > /dev/null 2>&1 && popd > /dev/null 2>&1
echo { \"output\": \"$ARTIFACTS_DIR/function.zip\" }
