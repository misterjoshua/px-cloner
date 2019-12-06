#!/bin/bash -e

function testCommands() {
  [ -z "$(command -v kubectl)" ] && die "Script requires the 'kubectl' command"

  kubectl version &>/dev/null || die "Kubectl can't get the server version"
}

function die() {
  echo "$*"
  exit 1
}

function cloneFromTo() {
  FROM=$1
  TO=$2

  if [[ -z "$FROM" ]]; then
      echo "FROM is missing"
      return 1
  fi

  if [[ -z "$TO" ]]; then
      echo "TO is missing"
      return 1
  fi

  if [[ "$FROM" = "$TO" ]]; then
      echo "FROM and TO are the same"
      return 1
  fi

  CLONE_NAME=clone-$FROM-to-$TO-$(date +%s)

  CONFIG=$(cat <<EOF
apiVersion: stork.libopenstorage.org/v1alpha1
kind: ApplicationClone
metadata:
    name: $CLONE_NAME
    namespace: kube-system
spec:
    sourceNamespace: $FROM
    destinationNamespace: $TO
    replacePolicy: Delete
EOF
  )

  echo "Submitting ApplicationClone request."
  kubectl -n kube-system apply -f- <<<"$CONFIG"

  DELAY=${DELAY:-1}
  until [ "$STAGE" = "Final" ]; do
    sleep $DELAY
    STAGE=$(kubectl -n kube-system get applicationclone $CLONE_NAME -o jsonpath="{ .status.stage }")
    echo "Application clone stage: $STAGE"
  done

  echo "Restarting pods"
  kubectl -n $TO delete pods --all
}

#######
# Script begins
########

FROM=$1
TO=$2

while getopts "v" OPTION; do
  case "${OPTION}" in
    v) echo "%%VERSION%%"; exit ;;
  esac
done

testCommands
cloneFromTo "$FROM" "$TO"
