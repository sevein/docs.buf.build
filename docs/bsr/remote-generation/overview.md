---
id: overview
title: Overview
description: The BSR supports remote code generation, which means you fetch generated source code like any other dependency.
---

import Breaking from "@site/src/components/Breaking";

<Breaking 
  feature="Remote code generation"
  version="alpha"
/>

A common frustration when working with Protocol Buffers is that you need to generate code for each
language that you're working with. Many teams implement custom tooling and scripts to solve this
problem, but it can be difficult to ensure that every person who works on a given project has all
of the code generation tooling set up locally. And if you have Protobuf-based APIs, the consumers
of your APIs shouldn't have to deal with code generation.

The Buf Schema Registry solves this problem with **remote code generation**. With this feature, you
can eliminate code generation from your workflows and directly [install](#languages) code generated
from Protobuf definitions using standard package managers and build tools. This diagram illustrates
how remote generation works:

import Image from '@site/src/components/Image';

<Image alt="BSR module" src="/img/bsr/remote-code-gen.png" width={75} caption="The Buf Schema Registry's remote generation process" />

In essence, you can use generation [templates](#templates) to generate code stubs from [Buf
modules](../overview.md#modules) that you've pushed to the BSR. All code generation happens _on the
BSR itself_&mdash;not on your laptop, not in a CI/CD environment, only remotely on the BSR.

## Supported languages {#languages}

The BSR currently [supports](#registries) remote generation for these languages:

import BsrLanguages from "@site/src/components/BsrLanguages";
<BsrLanguages />

We plan to support remote generation for additional languages in the near future.

## Remote generation concepts {#concepts}

Remote generation for the BSR revolves around a few core concepts:

* Protobuf [plugins](#plugins) generate code from Protobuf definitions
* Generation [templates](#templates) are named and versioned collections of [plugins](#plugins)
* Remote generation [registries](#registries) provide interfaces for language-specific tools to install generated assets

### Plugins

The BSR uses Protobuf **plugins** to generate code stubs from Protobuf definitions. Examples of
Protobuf plugins include [`protoc-gen-go`][protoc-gen-go] and
[`protoc-gen-python`][protoc-gen-python].

:::info Creating your own plugins
See the documentation on [authoring plugins](./plugin-example.md) to see how you can create and
upload your own plugins to use as part of code generation.
:::

Plugins belong to an [owner](../user-management.md#owner) and may be public or private. Public plugins are available to anyone,
while private plugins are only available to the owner or members of the owning organization. Plugins
are often referenced together with their owner's name, for example, `library/plugins/protoc-gen-go` (or in some contexts just `library/protoc-gen-go`), is used to reference the `protoc-gen-go` plugin maintained by Buf.

A plugin has instantiations at different **versions**. These versions often map directly to the versions of the existing plugin executables. For example, the `protoc-gen-go` plugin has a version `v1.27.1-1` matching the [`v1.27.1` release](https://github.com/protocolbuffers/protobuf-go/releases/tag/v1.27.1) of the official Go Protobuf plugin.

Plugin version executables are managed as Docker images. The Docker image is expected to accept a [CodeGeneratorRequest](https://github.com/protocolbuffers/protobuf/blob/bd42fcc7a3e04504df895ce2fd0782c0e84b68a5/src/google/protobuf/compiler/plugin.proto#L68) in Protobuf binary format on standard in, and respond with a [CodeGeneratorResponse](https://github.com/protocolbuffers/protobuf/blob/bd42fcc7a3e04504df895ce2fd0782c0e84b68a5/src/google/protobuf/compiler/plugin.proto#L99) in Protobuf binary format on standard out when run. This matches exactly the contract used with existing Protobuf plugins in the ecosystem today, making migration of existing plugins to BSR hosted plugins straightforward.

A plugin version is created by pushing a tagged Docker image to the plugins Docker registry repository. For example, assuming the relevant `Dockerfile` and context was in the current directory, to push a new version `v1.1.0` of the plugin `protoc-gen-myplugin` owned by the user `myuser`, the user would run

```terminal
$ docker build -t plugins.buf.build/myuser/protoc-gen-myplugin:v1.1.0 .
```

followed by

```terminal
$ docker push plugins.buf.build/myuser/protoc-gen-myplugin:v1.1.0
```

Pushing plugins to the BSR requires authenticating your Docker CLI using a **token**:

```terminal
$ docker login -u myuser --password-stdin plugins.buf.build
```

A plugin version can describe runtime library dependencies of its generated assets using [Docker labels](https://docs.docker.com/config/labels-custom-metadata/). All labels are prefixed with `build.buf.plugins.runtime_library_versions.` followed by the index of the dependency, followed by the attribute being specified. For example, version `v1.27.1-1` of the `library/protoc-gen-go` plugin declares its runtime dependency on the Go module `google.golang.org/protobuf` using these labels in its `Dockerfile`:

```docker
LABEL "build.buf.plugins.runtime_library_versions.0.name"="google.golang.org/protobuf"
LABEL "build.buf.plugins.runtime_library_versions.0.version"="v1.27.1"
```

You need to give plugins a valid [semantic version][semver].

:::success Remote plugin execution
A feature that you may also find useful is [remote plugin execution](./hosted-plugins.md). While
remote code generation is geared toward eliminating the need to generate code stubs _at all_, remote
plugin execution enables you to generate code stubs locally without needing to install plugins
locally.
:::

### Templates

A **template** defines a collection of **plugins** and associated configuration to use when
generating code stubs from Protobuf. With templates, you can run multiple plugins together, such as
`protoc-gen-go` and `protoc-gen-go-grpc`, where the output of `protoc-gen-go-grpc` depends on the
output of `protoc-gen-go`.

:::info Creating your own templates
See the documentation on [authoring templates](./template-example.md) to see how you can upload your
own templates to use as part of code generation.
:::

Templates belong to an [owner](../user-management.md#owner) and can be public or private. Public
templates are available to anyone, while private templates are available only to the owner or
members of the owner's organization.

Buf maintains several official templates:

- [`protocolbuffers/go`][pb-go]
- [`protocolbuffers/js`][pb-js]
- [`grpc/go`][grpc-go]
- [`grpc/web`][grpc-web]

A template **version** defines the plugin versions to use. This enables you to keep templates up to
date with new versions of plugins in the template. A template version is of the form `v[1-9][0-9]*`.
The template version makes up part of the [synthetic version](#synthetic-versions) of remotely
generated artifacts.

Template management is designed to discourage introducing breaking changes to consumers. This is why plugin parameters are defined on the template itself rather than on a per-version basis.

### Registries

A remote generation **registry** is an artifact registry that enables language-specific dependency
management tools to install assets remotely generated by the BSR.

The BSR currently offers two registries:

Registry | Language(s) | URL
:--------|:------------|:---
[Go module proxy](go.md#proxy) | [Go](go.md) | `go.buf.build`
[npm] registry | [Javascript and TypeScript](js.md) | `npm.buf.build`

### Synthetic versions

A **synthetic version** combines the [template](#templates) and [module](../overview.md#modules) versions into a [semantic version](https://semver.org/spec/v2.0.0.html) of this form:

import Syntax from "@site/src/components/Syntax";

<Syntax
  title="Synthetic version syntax"
  examples={["v1.3.5", "v1.2.26"]}
  segments={[
    {label: "v1", kind: "constant"},
    {separator: "."},
    {label: "templateVersion", kind: "variable", href: "/bsr/remote-generation/overview#templates"},
    {separator: "."},
    {label: "commitSequenceID", kind: "variable", href: "/bsr/remote-generation/overview#commits"},
  ]}
/>

Within this scheme:

* There's always a **v** prefix.
* The major version is always **1**.
* The minor version (**3** in the example) corresponds to the [template](#templates) version (without the `v` prefix). Template versions increase monotonically and have the form `v1`, `v2`, `v3`...
* The patch version (**5** in the example) corresponds to the module, which is identified by a [commit sequence ID](#commits) that's incremented each time a new version of a module is pushed.

The synthetic version `v1.2.10`, for example, means that the artifact was generated using `v2` of
the template and using the commit sequence ID `10` for the module.

#### Where synthetic versions are used

The BSR applies synthetic versions to all remote-generated code artifacts in the **remote generation
registry**. That currently includes [Go packages](../../tour/use-remote-generation.md) but will be
expanded to other languages.

#### Enforcing semantic versioning

Although we describe synthetic versions as [semantic versions](https://semver.org/spec/v2.0.0.html),
the BSR doesn't _enforce_ semantic versioning. If you make breaking changes to an asset and push
that asset to the BSR, the patch version is incremented in spite of the breaking change, which
violates semantic versioning.

In order to preserve semver guarantees in your own generated assets, we recommend performing
[breaking change detection](../../breaking/usage.md) _before_ pushing a new version of a Buf module,
potentially as part of your [CI/CD pipeline](../../ci-cd/setup.md#checks).

#### Commits

Every time you push a Buf module to the BSR, a new **commit** is created. Each commit has two pieces
of information attached to it:

* A **commit name**. This is a randomly generated, fixed-size [hexadecimal] string that's visible in
  the BSR's UI. Note that the commit name is _not_ a hash of the commit's content.
* A **commit sequence ID**. This is a monotonically increasing integer that begins at 1 and is
  incremented with each new module push. Commit sequence IDs are _not_ visible in the BSR UI.

#### How we implemented synthetic versions

The challenge with versioning remote-generated code is that unlike versioning schemes that only deal
with one artifact, such as a Python library, BSR versions are the product of two logical inputs:

* The template version
* The Protobuf module

When implementing our versioning scheme, we surveyed some popular language registries and found that
the most common scheme was semantic versioning but _without_ [pre-release and build][scheme] labels.
In other words, we found that versions like `v1.2.3` were common whereas `v1.2.3-alpha.1` were not,
and we opted for the former.

[go-mod]: https://golang.org/ref/mod
[grpc-go]: https://buf.build/grpc/templates/go
[grpc-web]: https://buf.build/grpc/templates/web
[hexadecimal]: https://en.wikipedia.org/wiki/Hexadecimal
[npm]: https://npmjs.org
[pb-go]: https://buf.build/protocolbuffers/templates/go
[pb-js]: https://buf.build/protocolbuffers/templates/js
[protoc-gen-go]: https://pkg.go.dev/google.golang.org/protobuf@v1.27.1/cmd/protoc-gen-go
[protoc-gen-python]: https://developers.google.com/protocol-buffers/docs/reference/python-generated
[scheme]: https://www.baeldung.com/cs/semantic-versioning#4-pre-release-and-build
[semver]: https://semver.org/spec/v2.0.0.html
