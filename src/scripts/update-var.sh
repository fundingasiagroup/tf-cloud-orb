#!/bin/bash
set -eo pipefail

GetVariableId(){
  TF_VARIABLE_ID=$(curl -s \
    --header "Authorization: Bearer $TF_TOKEN" \
    --header "Content-Type: application/vnd.api+json" \
  "https://app.terraform.io/api/v2/vars?filter%5Borganization%5D%5Bname%5D=$TF_ORG_NAME&filter%5Bworkspace%5D%5Bname%5D=$TF_WORKSPACE_NAME" \
  | jq '.data[] | select (.attributes.key == '\"$TF_VARIABLE_NAME\"') | .id' | tr -d \")

  echo "IMAGE TAG VARIABLE ID - $TF_VARIABLE_ID"
}

UpdateVariable(){
  TF_VARIABLE_UPDATE_PAYLOAD='{
    "data": {
      "id":"'$TF_VARIABLE_ID'",
      "attributes": {
        "key":"'$TF_VARIABLE_NAME'",
        "value":"'$TF_VARIABLE_VALUE'",
        "description": "'$TF_VARIABLE_NAME'",
        "category":"'$TF_VARIABLE_CATEGORY'",
        "hcl": "'$TF_VARIABLE_HCL'",
        "sensitive": "'$TF_VARIABLE_SENSITIVE'",
      },
      "type":"vars"
    }
  }'
  echo "VARIABLE Update Payload - $TF_VARIABLE_UPDATE_PAYLOAD"
  VAR_UPDATE_URL="https://app.terraform.io/api/v2/vars/$TF_VARIABLE_ID"
  VAR_UPDATE_RESPONSE=$(curl -s \
    --header "Authorization: Bearer $TF_TOKEN" \
    --header "Content-Type: application/vnd.api+json" \
    --request PATCH \
    --data "$TF_VARIABLE_UPDATE_PAYLOAD" \
    "$VAR_UPDATE_URL")
  echo "$VAR_UPDATE_RESPONSE"
}

CheckEnvVars(){
  if [[ -z $TF_ORG_NAME || -z $TF_WORKSPACE_NAME || -z $TF_TOKEN || -z $TF_VARIABLE_NAME || -z $TF_VARIABLE_VALUE || -z $TF_VARIABLE_CATEGORY ||  -z $TF_VARIABLE_HCL || -z $TF_VARIABLE_SENSITIVE ]]; then
    echo 'one or more required variables (TF_ORG_NAME, TF_WORKSPACE_NAME, TF_TOKEN, TF_VARIABLE_NAME, TF_VARIABLE_VALUE, TF_VARIABLE_CATEGORY, TF_VARIABLE_HCL, TF_VARIABLE_SENSITIVE ) are undefined'
    exit 1
  fi
}

PrintVars(){
  echo "$TF_ORG_NAME - $TF_WORKSPACE_NAME - $TF_VARIABLE_NAME - $TF_VARIABLE_VALUE - $TF_TOKEN - $TF_VARIABLE_CATEGORY - $TF_VARIABLE_HCL - $TF_VARIABLE_SENSITIVE"
}
TF_TOKEN=$(eval echo "\$$TF_TOKEN")
TF_VARIABLE_VALUE=$(eval echo "\$$TF_VARIABLE_VALUE")

# CheckEnvVars
# PrintVars
GetVariableId
UpdateVariable
