## Prerequisites

```shell
brew install minio-mc just colima
```

## Colima

```shell
just colima-start
```

## Minio

```shell
just minio
```

Create a `local` alias for `MinIO`:

```shell
just minio-local-alias
```

Create the `tansu` bucket:

```shell
just minio-tansu-bucket
```

```shell
just minio-ls-local
```

## Tansu

```shell
just tansu
```

Leave the following running so that we can capture logs from `tansu`:

```shell
just tansu-logs
```

## Knative

```shell
just knative-operator
```

```shell
just knative-serving
```

```shell
just knative-eventing
```

```shell
just kafka-broker-controller
```

```shell
just broker
```

```shell
just kafka-broker-data-plane
```

```shell
just sink
```

```shell
just trigger
```

```shell
just source
```
