# CI/CD Tools and Practices Final Project

This project builds a continuous integration and continuous delivery pipeline for the Node.js Counter Service from IBM Skills Network.

GitHub Actions checks out the project, sets up Node.js 24, installs the locked dependencies, lints with ESLint, and runs the Jest unit tests. OpenShift Pipelines uses six tasks in order: cleanup, git-clone, eslint, jest, buildah, and deploy. The deployment serves HTTP on port 8000 and responds to a readiness check at `/health`.

## Run locally

```sh
npm ci --no-audit --no-fund
npm run lint
npm test -- --ci --runInBand
npm start
```

The service provides `GET /` and `GET /health`, and supports creating, reading, incrementing, listing, and deleting in-memory counters under `/counters`.

## Run in the OpenShift lab

Open the final project lab and use its authenticated terminal. The current OpenShift project must provide the `pipeline` service account, the `skills-network-learner` storage class, the internal image registry, and the operator-installed Buildah task.

```sh
git clone https://github.com/vedant412/ci-cd-final-project.git
cd ci-cd-final-project
oc project -q
bash bin/run-openshift.sh
```

The script applies the claim and definitions and starts one PipelineRun. With its printed run name, check execution and capture the application output.

```sh
oc get pipelinerun
oc describe pvc pipeline-pvc
oc logs deployment/counter-service | tee oc-pipeline-application-logs
```

Save the claim Details page as `oc-pipelines-console-pvc-details.png`, the `cd-pipeline` task view as `oc-pipelines-oc-final.png`, and the successful PipelineRun task graph as `oc-pipelines-oc-green.png`. The application logs contain `SERVICERUNNING` and port `8000` when the service starts.

Adapted from the [IBM Skills Network JavaScript starter](https://github.com/ibm-developer-skills-network/hdjqg-ci-cd-final-project-template). See [LICENSE](LICENSE).
