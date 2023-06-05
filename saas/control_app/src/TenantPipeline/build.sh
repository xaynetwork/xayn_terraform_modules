#!/bin/bash

WORKDIR=$1

pushd $WORKDIR
ARTIFACTS_DIR=$(mktemp -d)
ARTIFACTS_DIR=$ARTIFACTS_DIR make
pushd $ARTIFACTS_DIR && deterministic-zip -r function.zip . && popd
echo { \"output\": \"$ARTIFACTS_DIR/function.zip\" }
