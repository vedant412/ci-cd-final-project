#!/usr/bin/env bash
set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."
namespace=$(oc project -q)
revision=$(git rev-parse HEAD)
image="image-registry.openshift-image-registry.svc:5000/${namespace}/counter-service:${revision:0:12}"
run="cd-pipeline-$(date -u +%Y%m%d%H%M%S)"

# This pipeline clears a shared checkout. Avoid starting a second run on this claim.
oc apply -f .tekton/pvc.yml -f .tekton/tasks.yml
if oc get clustertask buildah >/dev/null 2>&1; then
    oc apply -f .tekton/pipeline.yml
else
    awk '
      /^        name: buildah$/ {
        getline
        if ($0 != "        kind: ClusterTask") exit 1
        print "        resolver: cluster"
        print "        params:"
        print "          - name: kind"
        print "            value: task"
        print "          - name: name"
        print "            value: buildah"
        print "          - name: namespace"
        print "            value: openshift-pipelines"
        next
      }
      { print }
    ' .tekton/pipeline.yml | oc apply -f -
fi

oc create -f - <<EOF
apiVersion: tekton.dev/v1
kind: PipelineRun
metadata:
  name: $run
spec:
  pipelineRef:
    name: cd-pipeline
  taskRunTemplate:
    serviceAccountName: pipeline
  params:
    - name: repo-url
      value: https://github.com/vedant412/ci-cd-final-project.git
    - name: revision
      value: "$revision"
    - name: image
      value: "$image"
  workspaces:
    - name: source
      persistentVolumeClaim:
        claimName: pipeline-pvc
EOF

printf 'PipelineRun: %s\n' "$run"
printf 'Monitor it with: oc get pipelinerun %s -w\n' "$run"
