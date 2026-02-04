## 1. GitHub Actions Workflow Setup

- [x] 1.1 Create `.github/workflows` directory structure
- [x] 1.2 Create workflow file `.github/workflows/docker-build.yml`
- [x] 1.3 Configure workflow name and trigger on tags matching `v*` pattern

## 2. Workflow Job Configuration

- [x] 2.1 Define job name and runner (ubuntu-latest)
- [x] 2.2 Add checkout step using actions/checkout@v4
- [x] 2.3 Add Docker metadata step using docker/metadata-action@v5 to extract tags and labels

## 3. Docker Buildx and QEMU Setup

- [x] 3.1 Add step to set up QEMU using docker/setup-qemu-action@v3
- [x] 3.2 Add step to set up Docker Buildx using docker/setup-buildx-action@v3

## 4. GHCR Authentication

- [x] 4.1 Add login step using docker/login-action@v3
- [x] 4.2 Configure registry as ghcr.io
- [x] 4.3 Set username to ${{ github.actor }} and password to ${{ secrets.GITHUB_TOKEN }}

## 5. Docker Build and Push

- [x] 5.1 Add build and push step using docker/build-push-action@v6
- [x] 5.2 Configure platforms: linux/amd64,linux/arm64
- [x] 5.3 Set push to true
- [x] 5.4 Use tags from docker/metadata-action output (${{ steps.meta.outputs.tags }})
- [x] 5.5 Use labels from docker/metadata-action output (${{ steps.meta.outputs.labels }})
- [x] 5.6 Set context to . (repository root)
- [x] 5.7 Set file to ./Dockerfile

## 6. Workflow Configuration

- [x] 6.1 Configure workflow to show build progress in GitHub Actions UI (automatic with build-push-action@v6)
