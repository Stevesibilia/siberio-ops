## Context

The repository contains a Dockerfile that builds a multi-tool container for Kubernetes/infrastructure operations. The Dockerfile is already well-prepared for multi-architecture builds using the `TARGETARCH` build argument. The repository needs to move to GitHub with automated CI/CD for building and publishing Docker images to GitHub Container Registry (GHCR).

**Current state:**
- Dockerfile uses `TARGETARCH` for all binary downloads (kubectl, helm, terraform, etc.)
- Base image is Alpine Linux (multi-arch ready)
- No existing CI/CD automation
- Manual build and push process

**Constraints:**
- Must support both linux/amd64 and linux/arm64 platforms
- Build should only trigger on release tags (not every commit)
- Use GitHub's built-in authentication (GITHUB_TOKEN)
- No secrets required for build (verified in codebase exploration)

## Goals / Non-Goals

**Goals:**
- Automate Docker image builds on release tag creation
- Build multi-architecture images (amd64 and arm64) in a single workflow
- Push images to GHCR with proper tagging (using release version)
- Use modern Docker buildx tooling with QEMU emulation
- Minimal workflow configuration, leveraging GitHub Actions best practices

**Non-Goals:**
- Building on every commit or PR (only release tags)
- Supporting additional architectures beyond amd64/arm64
- Image vulnerability scanning or SBOM generation (can be added later)
- Pushing to multiple registries (only GHCR for now)
- Advanced caching strategies (keep workflow simple initially)

## Decisions

### Decision 1: Use docker/build-push-action with buildx

**Rationale:**
- Official GitHub Action maintained by Docker
- Native support for multi-platform builds
- Handles buildx setup and manifest creation automatically
- Well-documented and widely adopted

**Alternatives considered:**
- Manual docker buildx commands: More complex, error-prone
- Matrix strategy with separate builds: Requires manual manifest creation, more YAML

### Decision 2: QEMU emulation for ARM builds

**Rationale:**
- GitHub-hosted runners are amd64 only
- QEMU allows building ARM images on amd64 runners
- Acceptable build time trade-off for this use case
- Simpler than managing self-hosted ARM runners

**Alternatives considered:**
- Self-hosted ARM runners: Added infrastructure complexity, cost
- External build services: Adds external dependency

### Decision 3: Trigger only on tags matching `v*` pattern

**Rationale:**
- Aligns with semantic versioning convention (v1.2.3)
- Prevents builds on development commits
- Clear signal for release intent
- Common pattern in open-source projects

**Alternatives considered:**
- Build on every push to main: Wastes resources, unnecessary builds
- Manual workflow dispatch: Requires manual intervention, error-prone

### Decision 4: Use docker/metadata-action for tag and label generation

**Rationale:**
- Official Docker action for extracting metadata from Git refs
- Automatically strips 'v' prefix from tags (v1.2.3 → 1.2.3)
- Generates OCI Image Format labels automatically
- Handles semantic versioning patterns
- Well-maintained and follows Docker best practices

**Alternatives considered:**
- Manual tag extraction with shell scripts: Error-prone, harder to maintain
- Keep 'v' prefix: Non-standard for Docker images

### Decision 5: Use GITHUB_TOKEN for GHCR authentication

**Rationale:**
- Built-in, no secret management required
- Automatically has correct permissions for packages in same repo
- Follows GitHub's recommended approach
- No additional setup or rotation needed

**Alternatives considered:**
- Personal Access Token (PAT): Requires creation, rotation, and secret storage
- Organization token: More complex permission management

### Decision 6: Use official Docker GitHub Actions v3/v5/v6

**Rationale:**
- Maintained by Docker organization
- Well-tested and widely used
- Follow semantic versioning for stability
- Specific versions: setup-qemu-action@v3, setup-buildx-action@v3, login-action@v3, metadata-action@v5, build-push-action@v6

**Alternatives considered:**
- Using `@latest` or `@master`: Less stable, breaking changes
- Third-party actions: Less support, potential security risks

## Risks / Trade-offs

### Risk: ARM builds via QEMU can be slow
**Mitigation:** Acceptable for release-only builds (not on every commit). Can add layer caching or migrate to native ARM runners later if needed.

### Risk: QEMU emulation may fail for certain binary downloads
**Mitigation:** Dockerfile already tested and uses `TARGETARCH` correctly. All tools download platform-specific binaries rather than compiling from source.

### Risk: GitHub Container Registry rate limits or authentication failures
**Mitigation:** GHCR has generous limits for authenticated users. GITHUB_TOKEN automatically rotates and has appropriate permissions.

### Risk: Tag push without corresponding Dockerfile changes could fail build
**Mitigation:** Workflow will fail gracefully and clearly in GitHub Actions UI. Release process should verify Dockerfile builds locally before tagging.

### Trade-off: Single workflow file vs. reusable workflows
**Decision:** Single workflow file for simplicity. Can refactor to reusable workflows later if needed for multiple images.

### Trade-off: No build caching initially
**Decision:** Simpler initial implementation. Can add layer caching or registry cache later if build times become problematic.
