## ADDED Requirements

### Requirement: Workflow triggers on release tags only
The GitHub Actions workflow SHALL trigger only when a Git tag matching the pattern `v*` is pushed to the repository.

#### Scenario: Release tag pushed
- **WHEN** a Git tag `v1.2.3` is pushed to the repository
- **THEN** the workflow is triggered and begins execution

#### Scenario: Non-release tag ignored
- **WHEN** a Git tag `test-tag` (not matching `v*` pattern) is pushed
- **THEN** the workflow does NOT trigger

#### Scenario: Regular commit ignored
- **WHEN** a commit is pushed to main branch without a tag
- **THEN** the workflow does NOT trigger

### Requirement: Multi-architecture build support
The workflow SHALL build Docker images for both linux/amd64 and linux/arm64 platforms in a single workflow run.

#### Scenario: Multi-platform build succeeds
- **WHEN** the workflow executes
- **THEN** Docker images are built for both linux/amd64 and linux/arm64 platforms
- **THEN** a multi-platform manifest is created linking both architecture images

#### Scenario: QEMU emulation configured
- **WHEN** the workflow starts
- **THEN** QEMU emulation is set up to enable ARM64 builds on AMD64 runners

### Requirement: Buildx configuration
The workflow SHALL use Docker buildx for building multi-architecture images.

#### Scenario: Buildx builder configured
- **WHEN** the workflow prepares to build
- **THEN** Docker buildx is installed and configured
- **THEN** a builder instance supporting multi-platform builds is created

### Requirement: Image built from repository Dockerfile
The workflow SHALL build the Docker image using the Dockerfile in the repository root with the TARGETARCH build argument properly passed.

#### Scenario: Dockerfile build with TARGETARCH
- **WHEN** building for linux/amd64 platform
- **THEN** the build uses the Dockerfile from repository root
- **THEN** the TARGETARCH build argument is set to "amd64"

#### Scenario: Dockerfile build for ARM
- **WHEN** building for linux/arm64 platform
- **THEN** the build uses the Dockerfile from repository root
- **THEN** the TARGETARCH build argument is set to "arm64"

### Requirement: Build success validation
The workflow SHALL fail if any platform build fails, preventing partial multi-arch images.

#### Scenario: One platform build fails
- **WHEN** the amd64 build succeeds but arm64 build fails
- **THEN** the entire workflow fails
- **THEN** no images are pushed to the registry

#### Scenario: All platform builds succeed
- **WHEN** both amd64 and arm64 builds complete successfully
- **THEN** the workflow proceeds to push the images
