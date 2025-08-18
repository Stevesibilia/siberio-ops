#!/bin/bash

# Add autocomplete for kubens
if kubectl get namespaces >/dev/null 2>&1; then
  NAMESPACES_LIST=$(kubectl get namespaces -o json | jq --raw-output 'if .items != [] then [ .items[] | .metadata.name ] | join(" ") else "" end')
  if [ -n "${NAMESPACES_LIST}" ]; then
    echo "complete -W \"${NAMESPACES_LIST}\" kubens" >>/etc/profile
  fi
fi

if [ -z "${*}" ]; then
  exec bash -il 
else
  exec "$@"
fi