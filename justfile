set dotenv-load := true
set shell := ["bash", "-euxc", "-o", "pipefail"]

default:
    @{{just_executable()}} --list

# Formats all terraform files
tf-fmt:
    terraform fmt -recursive

# Checks formating of terraform files
tf-fmt-check:
    terraform fmt -check -diff -recursive

# Runs tflint over modules
tflint:
    #!/usr/bin/env bash
    set -eux -o pipefail
    for dir in $(find . -type d -not -path */node_modules*); do
        if [ -d "$dir" ]; then
            tflint $dir
        fi
    done
