# DATASCIENTEST JENKINS EXAM
# python-microservice-fastapi
Learn to build your own microservice using Python and FastAPI

## How to run??
 - Make sure you have installed `docker` and `docker-compose`
 - Run `docker-compose up -d`
 - Head over to http://localhost:8080/api/v1/movies/docs for movie service docs 
   and http://localhost:8080/api/v1/casts/docs for cast service docs

# Deployment Process

This repository uses Jenkins, Docker Hub, Helm, and Kubernetes to build and deploy the application.

## Prerequisites

- Jenkins with Docker, Helm, and kubectl installed on the agent
- Docker Hub credentials configured in Jenkins
- Kubernetes cluster access configured for Jenkins
- Helm chart files in the `charts/` directory

## Project Structure

- `movie-service/` - movie microservice
- `cast-service/` - cast microservice
- `charts/` - Helm chart and values files for each environment
- `Jenkinsfile` - CI/CD pipeline definition

## Deployment Workflow

The pipeline runs from the `master` branch and performs these steps:

1. **Checkout source code**
2. **Build Docker images**
   - `roxanaiuliamiu/movie-service:<BUILD_NUMBER>`
   - `roxanaiuliamiu/cast-service:<BUILD_NUMBER>`
3. **Log in to Docker Hub**
4. **Push Docker images**
5. **Deploy to Dev**
   - Uses `charts/values-dev.yaml`
   - Namespace: `dev`
6. **Deploy to QA**
   - Uses `charts/values-qa.yaml`
   - Namespace: `qa`
7. **Deploy to Staging**
   - Uses `charts/values-staging.yaml`
   - Namespace: `staging`
8. **Approve Production**
   - Manual approval in Jenkins
9. **Deploy to Production**
   - Uses `charts/values-prod.yaml`
   - Namespace: `prod`

## Jenkins Pipeline Summary

The pipeline executes in this order:

- Checkout
- Build Images
- Docker Hub Login
- Push Images
- Deploy Dev
- Deploy QA
- Deploy Staging
- Approve Production
- Deploy Production

## How to Deploy

1. Make your changes locally
2. Commit them to `master`
3. Push to GitHub
4. Jenkins starts the pipeline
5. Approve the production step when prompted

Example:

```bash
git checkout master
git add .
git commit -m "Update application"
git push origin master
```

## How to Verify Deployment

### In Jenkins

Check that the pipeline ends with:

```text
Finished: SUCCESS
```

### In Docker Hub

Verify that new image tags exist for:

- `roxanaiuliamiu/movie-service`
- `roxanaiuliamiu/cast-service`

### In Kubernetes

Check pods in all namespaces:

```bash
kubectl get pods -n dev
kubectl get pods -n qa
kubectl get pods -n staging
kubectl get pods -n prod
```

Check Helm releases:

```bash
helm list -A
```

## Notes

- The Docker image tag is the Jenkins build number
- Production deployment requires manual approval
- Jenkins logs out from Docker Hub after the pipeline finishes