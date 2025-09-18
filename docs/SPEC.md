# Implementation Plan: Secure, Hermetic Docker Image Factory

**Date**: 2025-09-18
**Spec**: [link to PRD.md]

## Technical Context
**Language/Version**: Dockerfile, Bash, Python 3.11, CUDA 12.5
**Primary Dependencies**: Docker (with buildx), Git, PyTorch, vLLM
**Storage**: GitHub (source), Docker Registry (images)
**Testing**: container-structure-tests, smoke tests
**Target Platform**: linux/amd64, linux/arm64
**Project Type**: Docker Image Factory

## Project Structure

### Documentation
```
docs/
├── PRD.md
└── SPEC.md
```

### Source Code
```
/
├── .github/
├── docs/
├── images/
│   └── vllm/
├── bases/
│   └── cuda/
├── mixins/
├── policies/
├── registry/
├── ci/
├── tests/
├── scans/
├── sbom/
├── attest/
├── cache/
├── hooks/
├── scripts/
├── templates/
├── reports/
└── risk/
```

## Phase 1: Foundational Repository and First Golden Image (In Progress)
1. **Repository Scaffolding**: Create the complete, top-level directory structure. (DONE)
2. **"Golden" CUDA Base Image**:
   - Create a minimal, digest-pinned `Dockerfile` for the CUDA base image. (IN PROGRESS)
   - Create `build.hcl`, `labels.yaml`, and `README.md` for the base image. (IN PROGRESS)
3. **Initial `vllm` Application Image**:
   - Create a multi-stage `Dockerfile` for `vllm` using the golden base. (TODO)
   - Create all supporting files (`build.hcl`, `labels.yaml`, etc.). (TODO)
4. **Build the Images**:
   - Build the golden CUDA base image. (TODO)
   - Build the `vllm` application image. (TODO)

## Phase 2: CI/CD Automation, Security Scanning, and Policy Enforcement
- Set up a basic GitHub Actions workflow to build images.
- Integrate `hadolint` and `conftest` for linting and policy checks.
- Add vulnerability scanning with Trivy/Grype.
- Add SBOM generation with Syft.

## Phase 3: Supply Chain Security: Signing, Attestation, and Promotion
- Integrate `cosign` for image signing.
- Create attestations for images, SBOMs, and provenance.
- Implement a promotion strategy for moving images from staging to production.

## Phase 4: Advanced Automation, Multi-Arch, and Reporting
- Extend the build process to support multi-arch builds (`linux/arm64`).
- Configure advanced `buildx` caching.
- Set up reporting for CVE drift and build metrics.