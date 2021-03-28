# buildx-push-action [![e2e](https://github.com/int128/buildx-push-action/actions/workflows/e2e.yaml/badge.svg)](https://github.com/int128/buildx-push-action/actions/workflows/e2e.yaml)

This is an action to build and push an image with the following features:

- Load and save the cache of all layers for multi-stage build
- Build on a pull request
- Build and push `latest` tag on a push of branch
- Build and push the corresponsing tag on a push of tag (such as `v1.2.3`)


## Getting Started

```yaml
on:
  push:
    branches:
      - master
    paths:
      - .github/workflows/docker.yaml
      - Dockerfile
      - src/** # depend on your application
    tags:
      - v*
  pull_request:
    branches:
      - master
    paths:
      - .github/workflows/docker.yaml
      - Dockerfile
      - src/** # depend on your application

jobs:
  build-push:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: docker/setup-buildx-action@v1
      - uses: actions/cache@v2
        with:
          path: /tmp/buildx
          key: buildx-${{ runner.os }}-${{ github.sha }}
          restore-keys: |
            buildx-${{ runner.os }}-
      - uses: docker/login-action@v1
        with:
          registry: ghcr.io
          username: ${{ github.repository_owner }}
          password: ${{ secrets.GITHUB_TOKEN }}
      - uses: int128/buildx-push-action@v1
```

For multi-platforms build:

```yaml
      - uses: docker/setup-qemu-action@v1
      - uses: docker/setup-buildx-action@v1

      - uses: int128/buildx-push-action@v1
        with:
          extra-args: --platform=linux/amd64,linux/arm64
```


## Inputs

| Name | Required | Default | Description
|------|----------|---------|------------
| `cache`               | `true`  | `/tmp/buildx` | buildx cache directory
| `repository`          | `true`  | `ghcr.io/${{ github.repository }}` | repository to push (default to GHCR)
| `working-directory`   | `false` | | working directory where the action is run (default to current directory)
| `extra-args`          | `false` | | extra arguments to pass to `docker buildx build`


## Outputs

None
