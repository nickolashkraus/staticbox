# Staticbox

[![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/nickolashkraus/staticbox?color=blue)](https://cloud.docker.com/u/nickolashkraus/repository/docker/nickolashkraus/staticbox)
[![Releases](https://img.shields.io/github/v/release/NickolasHKraus/staticbox?color=blue)](https://github.com/NickolasHKraus/staticbox/releases)
[![MIT License](https://img.shields.io/badge/License-MIT-blue.svg)](https://github.com/NickolasHKraus/staticbox/blob/master/LICENSE)

[Docker Hub](https://cloud.docker.com/u/nickolashkraus/repository/docker/nickolashkraus/staticbox)

Staticbox is a static compilation of [BusyBox](https://busybox.net/).

## Why?

If your filesystem is corrupted or deleted, a dynamically linked executable such as the default `busybox` binary on Alpine Linux will cease to function. Having a statically linked executable allows `busybox` to function even after, for example, the C standard library is deleted (i.e. `ld-musl-x86_64.so.1`).

## Usage

Staticbox can be used as a standalone Docker image or added to an existing Docker image:

```Dockerfile
FROM nickolashkraus/staticbox:latest as staticbox

COPY --from=staticbox /staticbox /staticbox

ENV PATH=/staticbox/bin:$PATH
```

## Use Case

The impetus for creating Staticbox came from the inability to use the [durable-task-plugin](https://github.com/jenkinsci/durable-task-plugin) Jenkins Plugin with [kaniko](https://github.com/GoogleContainerTools/kaniko). The Durable Task Plugin allows processes to be run asynchronously on a build node and withstand disconnection of the slave agent. As such, this plugin assumes `touch` and `sleep` binaries are available and functioning on the agent. When kaniko deletes the filesystem between build stages, it eliminates these binaries and the libraries they depend on causing a deluge of error logs:

```
sh: touch: not found
sh: sleep: not found
```

Using Staticbox and adding its directory as a Docker volume fixes this issue. Docker volumes are whitelisted by kaniko, meaning that they are neither deleted between stages, nor added to the Docker image.

## Testing

```bash
while true; do echo "Hello, Staticbox!"; sleep 3; done
```

```bash
ls | grep -v staticbox | xargs rm -rf 2> /dev/null
```

**Note**: The above command will attempt to delete *all* files under `/` except for `/staticbox`.
