#!/bin/bash

AI_CONFIG=~/.config/ai/config.json
CONTEXT_FILE=~/.local/share/ai/context.json

#INIT--------------------------------------------------------------------

CONFIG=$(jq '.' "$AI_CONFIG")

ENDPOINT=$(jq -r ".endpoint" <<< "$CONFIG")
KEY=$(jq -r ".key" <<< "$CONFIG")
MODEL=$(jq -r ".model" <<< "$CONFIG")
PERSONA=$(jq -r ".persona" <<< "$CONFIG")

#API----------------------------------------------------------------------

call_api(){
curl -s "${ENDPOINT?Endpoint configuration is missing}" \
    -H "Authorization: Bearer ${KEY?Api key configuration is missing}" \
    -H 'Content-Type: application/json' \
    -H "HTTP-Referer: http://localhost:3000" \
    -d "$1"
}
#CONTEXT---------------------------------------------------------------
get_context(){
  if [[ -n "$MEMORY" ]]; then
    if [[ ! -n $(cat "$CONTEXT_FILE") ]]; then
      echo '{"messages": []}' > "$CONTEXT_FILE"
    fi
  	jq -r '.' "$CONTEXT_FILE"
  else
    echo '{"messages": []}'
fi
}

save_context(){
if [[ ! -n "$MEMORY" ]]; then
   exit 0
fi
  echo "$CONTEXT" | jq '.' > "$CONTEXT_FILE.tmp" && mv "$CONTEXT_FILE.tmp" "$CONTEXT_FILE"
}

append_context(){
  NEW_MESSAGE=$(jq -n --arg role "$1" --arg content "$2" '{role: $role, content: $content}')
  CONTEXT=$(jq --argjson msg "$NEW_MESSAGE" '.messages += [$msg]' <<< "$CONTEXT")
}

#FORM_PAYLOAD------------------------------------------------------------------

getRequestPayload(){
  SYSTEM_MESSAGE=$(jq -n -c --arg persona "${PERSONA:- }" '{"role": "system", "content": $persona}')
  REQUEST_PAYLOAD=$(jq -n --argjson systemMessage "$SYSTEM_MESSAGE" --arg model "$MODEL" \
    '{"model": $model, "stream": false, "messages": [ $systemMessage ]}')
  CONTEXT_MESSAGES=$(echo "$CONTEXT" | jq '.messages')
  echo "$REQUEST_PAYLOAD" | jq --argjson context "$CONTEXT_MESSAGES" '.messages += $context'
}

#ACTION---------------------------------------------------------------------------------
MEMORY="enabled"

CONTEXT=$(get_context)

USER_MESSAGE="$*"

append_context "user" "$USER_MESSAGE"
save_context

REQUEST_PAYLOAD=$(getRequestPayload)

RESPONSE_PAYLOAD=$(call_api "$REQUEST_PAYLOAD")

RESPONSE_MESSAGE=$(echo "$RESPONSE_PAYLOAD" | jq -r '.choices.[0].message.content')

append_context "assistant" "$RESPONSE_MESSAGE"
save_context

if [[ "$RESPONSE_MESSAGE" == "null" ]]; then
  echo "$RESPONSE_PAYLOAD"
else
  echo "$RESPONSE_MESSAGE" | glow
fi
