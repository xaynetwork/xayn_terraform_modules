#!/bin/bash

# we need to return a valid JSON object otherwise:
# > if a change occurs that would trigger an update,
# the resource will be instead be destroyed and then recreated
# https://registry.terraform.io/providers/scottwinkler/shell/latest/docs/resources/shell_script_resource
echo "{\"body\"=\"Skip update\",\"statusCode\"=\"200\"}"
