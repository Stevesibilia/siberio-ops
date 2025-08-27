#!/usr/bin/env bash
set -euo pipefail

# scale-deployments.sh
# Scales all Deployments in selected namespaces.
# Selection: namespaces passed with -n (comma separated) OR namespaces with label scalable=true.
# Actions: up | down
# Options:
#   -n NAMESPACES   comma-separated list of namespaces (overrides label selection)
#   --replicas N    set absolute replicas for all deployments (required)
#   --context CTX   kubectl context to use
#   --dry-run       perform a client-side dry run
#   -h|--help       print this help

usage() {
  cat <<EOF
Usage: $(basename "$0") [options] <up|down>

Select namespaces with -n ns1,ns2 or let the script pick namespaces labeled 'scalable=true'.
Examples:
  $(basename "$0") up                     # increment replicas by 1 in all scalable namespaces
  $(basename "$0") -n default,tools down  # decrement by 1 in namespaces default and tools
  $(basename "$0") --replicas 3 up       # set replicas to 3 for all matched deployments
  $(basename "$0") --step 2 down         # decrease by 2 (min 0)
  $(basename "$0") --dry-run up

Notes:
  - The script requires 'kubectl' and 'jq' in PATH.
  - Deployments managed by an HPA are skipped.
  - If a Deployment has null .spec.replicas, it is treated as 1.
EOF
}

if ! command -v kubectl >/dev/null 2>&1; then
  echo "kubectl not found in PATH" >&2
  exit 2
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq not found in PATH (required)" >&2
  exit 2
fi

# defaults
DRY_RUN=false
NAMESPACES_ARG=""
REPLICAS_SET=""
KCTX=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -n|--namespaces)
      NAMESPACES_ARG="$2"; shift 2;;
    --replicas)
      REPLICAS_SET="$2"; shift 2;;
    --context)
      KCTX="--context $2"; shift 2;;
    --dry-run)
      DRY_RUN=true; shift;;
    -h|--help)
      usage; exit 0;;
    up|down)
      # legacy positional actions ignored: scaling is driven by --replicas
      shift;;
    *)
      echo "Unknown argument: $1" >&2; usage; exit 1;;
  esac
done


if [[ -z "$REPLICAS_SET" ]]; then
  echo "--replicas is required: specify the desired number of replicas" >&2
  usage
  exit 1
fi

if ! [[ "$REPLICAS_SET" =~ ^[0-9]+$ ]]; then
  echo "--replicas must be a non-negative integer" >&2; exit 1
fi

DRY_RUN_FLAG=""
if $DRY_RUN; then
  DRY_RUN_FLAG="--dry-run=client"
fi

# Get namespaces
if [[ -n "$NAMESPACES_ARG" ]]; then
  IFS=',' read -r -a NAMESPACES <<<"$NAMESPACES_ARG"
else
  # produce one namespace per line so mapfile creates a proper array element per namespace
  mapfile -t NAMESPACES < <(kubectl $KCTX get ns -l scalable=true -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}')
fi

if [[ ${#NAMESPACES[@]} -eq 0 ]]; then
  echo "No namespaces selected" >&2
  exit 0
fi

echo "Selected namespaces: ${NAMESPACES[*]}"

for ns in "${NAMESPACES[@]}"; do
  echo "--- namespace: $ns ---"

  # collect HPAs scale targets in this namespace as KIND/NAME
  mapfile -t HPA_TARGETS < <(kubectl -n "$ns" $KCTX get hpa -o json 2>/dev/null | jq -r '.items[]? | (.spec.scaleTargetRef.kind + "/" + .spec.scaleTargetRef.name)' || true)

  # process both Deployments and StatefulSets
  for res in deploy statefulset; do
    if [[ "$res" == "deploy" ]]; then
      res_kind="Deployment"
      res_label="deployments"
    else
      res_kind="StatefulSet"
      res_label="statefulsets"
    fi

    resources_json=$(kubectl -n "$ns" $KCTX get $res -o json 2>/dev/null || echo '{"items":[]}')
    names_and_replicas=$(jq -r '.items[] | [.metadata.name, (.spec.replicas // 1)] | @tsv' <<<"$resources_json" || true)

    if [[ -z "$names_and_replicas" ]]; then
      echo "No $res_label in $ns"
      continue
    fi

    while IFS=$'\t' read -r name cur_replicas; do
      # skip HPA-managed targets matching kind/name
      skip=false
      for h in "${HPA_TARGETS[@]:-}"; do
        if [[ "$h" == "$res_kind/$name" ]]; then skip=true; break; fi
      done
      if $skip; then
        echo "Skipping $res_kind/$name (managed by HPA)"
        continue
      fi

    # target is always the absolute replicas value
    target=$REPLICAS_SET

      if [[ "$target" -eq "$cur_replicas" ]]; then
        echo "$res_kind/$name: replicas unchanged ($cur_replicas)"
        continue
      fi

      echo "Scaling $res_kind/$name: $cur_replicas -> $target"
      kubectl -n "$ns" $KCTX scale $res "$name" --replicas="$target" $DRY_RUN_FLAG || {
        echo "Failed to scale $res_kind/$name in $ns" >&2
      }
    done <<<"$names_and_replicas"
  done
done

echo "Done."
