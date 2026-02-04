## ADDED Requirements

### Requirement: Authenticate to GitHub Container Registry
The workflow SHALL authenticate to GitHub Container Registry (GHCR) using the built-in GITHUB_TOKEN.

#### Scenario: Successful GHCR authentication
- **WHEN** the workflow prepares to push images
- **THEN** authentication to ghcr.io is performed using GITHUB_TOKEN
- **THEN** authentication succeeds with write permissions to the repository's package namespace

#### Scenario: Authentication uses built-in token
- **WHEN** the workflow authenticates
- **THEN** the GITHUB_TOKEN secret is used (not a PAT or other credential)
- **THEN** no manual secret configuration is required

### Requirement: Image tagged with release version
The workflow SHALL tag the Docker image with the release version derived from the Git tag, with the leading 'v' prefix removed.

#### Scenario: Version tag extraction
- **WHEN** the Git tag is `v1.2.3`
- **THEN** the Docker image is tagged as `1.2.3`

#### Scenario: Version tag without 'v' prefix
- **WHEN** the Git tag is `v2.0.0-beta.1`
- **THEN** the Docker image is tagged as `2.0.0-beta.1`

### Requirement: Image pushed to GHCR namespace
The workflow SHALL push the Docker image to GitHub Container Registry under the repository's package namespace.

#### Scenario: Image pushed to correct namespace
- **WHEN** the image is pushed
- **THEN** the image is available at `ghcr.io/<owner>/<repository>:<version>`
- **THEN** the image is linked to the GitHub repository

### Requirement: Multi-architecture manifest published
The workflow SHALL publish a multi-architecture manifest that references both amd64 and arm64 images.

#### Scenario: Manifest includes both architectures
- **WHEN** the multi-platform image is pushed
- **THEN** a manifest list is created referencing both linux/amd64 and linux/arm64 images
- **THEN** pulling the image automatically selects the correct architecture for the host platform

#### Scenario: Single tag points to multi-arch manifest
- **WHEN** a user pulls `ghcr.io/<owner>/<repository>:1.2.3`
- **THEN** the appropriate architecture image is downloaded based on the user's platform

### Requirement: Push only after successful build
The workflow SHALL push images to GHCR only after all platform builds complete successfully.

#### Scenario: Build failure prevents push
- **WHEN** any platform build fails
- **THEN** no images are pushed to GHCR
- **THEN** the workflow exits with failure status

#### Scenario: Successful build triggers push
- **WHEN** all platform builds succeed
- **THEN** all platform images and the manifest are pushed to GHCR

### Requirement: Workflow provides clear status feedback
The workflow SHALL provide clear status feedback in the GitHub Actions UI showing build and push progress.

#### Scenario: Build progress visible
- **WHEN** the workflow is running
- **THEN** the GitHub Actions UI shows which platform is being built
- **THEN** build logs are accessible for debugging

#### Scenario: Push status visible
- **WHEN** images are being pushed
- **THEN** the GitHub Actions UI shows push progress
- **THEN** the final image URL is displayed upon success
