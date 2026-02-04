## Why

This repository needs to be moved to GitHub with CI/CD automation for building and publishing Docker images. Currently, there's no automated build pipeline, which makes releasing new versions manual and error-prone. A GitHub Actions workflow will automate multi-architecture Docker image builds (amd64 and arm64) and push them to GitHub Container Registry (GHCR) on release tags.

## What Changes

- Add GitHub Actions workflow for Docker image builds
- Configure multi-architecture builds (linux/amd64 and linux/arm64)
- Set up automatic push to GitHub Container Registry (GHCR)
- Trigger builds only on release tags (e.g., v1.2.3)
- Use release tag as Docker image tag (stripping the 'v' prefix)

## Capabilities

### New Capabilities
- `github-actions-multiarch-build`: GitHub Actions workflow that builds multi-architecture Docker images using buildx and QEMU emulation, triggered on release tags
- `ghcr-publish`: Automated publishing of Docker images to GitHub Container Registry with proper authentication and tagging

### Modified Capabilities
<!-- No existing capabilities are being modified -->

## Impact

- **New files**: `.github/workflows/docker-build.yml` (or similar)
- **Authentication**: Uses GitHub's built-in `GITHUB_TOKEN` for GHCR authentication
- **Build time**: Multi-arch builds may take longer due to QEMU emulation for ARM builds
- **Release process**: Pushing a release tag will automatically trigger Docker image build and publish
- **No code changes**: Existing Dockerfile is already multi-arch ready with `TARGETARCH` support
