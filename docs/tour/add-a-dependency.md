---
id: add-a-dependency
title: 9 Add a dependency
---

Without the [BSR](../bsr/overview.md), you can only depend on other Protobuf APIs by manually
fetching the `.proto` files you need. If you wanted to use
[`googleapis`](https://github.com/googleapis/googleapis), for example, you'd need to clone the right
Git repository and copy the `.proto` file(s) you need in order to compile your own `.proto` files.
And if `googleapis` has its own external dependencies, then you need to fetch those as well.

Even worse, this way of managing dependencies is prone to API drift, where the `googleapis`
code may evolve over time, leaving your local copies inconsistent with the latest version and your
modules thus out of date. It turns out that this is exactly what you did with the `PetStoreService`:
the `google/type/datetime.proto` file is actually present in your local directory and currently
used to build your [module](../bsr/overview.md#modules).

Now that you're familiar with the BSR, you can simplify this entire workflow immensely.

## 9.1 Remove the `datetime.proto` file {#remove-datetime-proto}

Start by removing the `google/type/datetime.proto` file from your module altogether.
From within the `petapis` directory, run this command to remove _all_ of the local `google`
dependencies:

```terminal
$ rm -rf google
```

Now remove the `google/type/datetime.proto` reference from your [`buf.yaml`](../configuration/v1/buf-yaml.md):

```yaml title="buf.yaml" {5-6}
 version: v1
 name: buf.build/$BUF_USER/petapis
 lint:
   use:
     - DEFAULT
-  ignore:
-    - google/type/datetime.proto
 breaking:
   use:
     - FILE
```

If you try to build the module in its current state, you will notice an error:

```terminal
$ buf build
---
pet/v1/pet.proto:7:8:google/type/datetime.proto: does not exist
```

## 9.2 Depend on `googleapis` {#depend-on-googleapis}

You can resolve this error by configuring a dependency in your `buf.yaml`'s
[`deps`](/configuration/v1/buf-yaml#deps) key. The `google/type/datetime.proto` file is provided by
the `buf.build/googleapis/googleapis` module, so you can configure it like this:

```yaml title="buf.yaml" {2-3}
 version: v1
 name: buf.build/$BUF_USER/petapis
+deps:
+  - buf.build/googleapis/googleapis
 lint:
   use:
     - DEFAULT
 breaking:
   use:
     - FILE
```

Now, if you try to build the module again, you'll notice this:

```terminal
$ buf build
---
WARN	Specified deps are not covered in your buf.lock, run "buf mod update":
	- buf.build/googleapis/googleapis
pet/v1/pet.proto:7:8:google/type/datetime.proto: does not exist
```

`buf` detected that you specified a dependency that isn't included in the module's
[`buf.lock`](../configuration/v1/buf-lock.md) file. This file is a dependency manifest for your
module, representing a single reproducible build of your module's dependencies. You don't have a
`buf.lock` file yet because you haven't specified any external dependencies, but you can create one with
the command that `buf` recommended above:

```terminal
$ buf mod update
```

The `buf mod update` command updates all of your `deps` to their latest version. The generated
`buf.lock` should look similar to this (the `commit` may vary):

```yaml title="buf.lock"
# Generated by buf. DO NOT EDIT.
version: v1
deps:
  - remote: buf.build
    owner: googleapis
    repository: googleapis
    commit: 1c473ad9220a49bca9320f4cc690eba5
```

Now, if you try to build the module again, you'll notice that it's successful:

```terminal
$ buf build
---
buf: downloading buf.build/googleapis/googleapis:1c473ad9220a49bca9320f4cc690eba5
```

This is the BSR's dependency management in action! A few things happened here, so let's break it down:

  1. `buf` noticed that a new dependency was added to the `deps` key.
  2. `buf` resolved the latest version of the `buf.build/googleapis/googleapis` module and wrote it to the
      module's `buf.lock`.
  3. When another `buf` command is run, `buf` downloads the `buf.build/googleapis/googleapis` module to the
     local [module cache](../bsr/overview.md#module-cache).
  4. Finally, now that `buf` has all of the dependencies it needs, it can successfully build the module
     (as `google/type/datetime.proto` is included).

In summary, `buf` can resolve the dependencies specified in your `buf.yaml`'s `deps` key and include
the imports required to build your module. **You don't have to manually copy `.proto` files anymore!**

## 9.3 Pin Your Dependencies {#pin-your-dependencies}

You can pin to a specific tag or commit by specifying it in your `deps` after the `:` delimiter. For example,
if you want to depend on the same commit you resolved above and prevent `buf` from updating it in the future,
you can specify it like this:

```yaml title="buf.yaml" {3-4}
 version: v1
 name: buf.build/$BUF_USER/petapis
 deps:
-  - buf.build/googleapis/googleapis
+  - buf.build/googleapis/googleapis:4bdf33e750fb409da9d403e1e98031f4
 lint:
   use:
     - DEFAULT
 breaking:
   use:
     - FILE
```

This is **not recommended** in general since you should _always_ be able to update to the latest version of
your dependencies if they remain backwards compatible. But in some situations it's unavoidable.
With that said, restore the `buf.yaml` file to its previous state before you continue:

```yaml title="buf.yaml" {3-4}
 version: v1
 name: buf.build/$BUF_USER/petapis
 deps:
-  - buf.build/googleapis/googleapis:4bdf33e750fb409da9d403e1e98031f4
+  - buf.build/googleapis/googleapis
 lint:
   use:
     - DEFAULT
 breaking:
   use:
     - FILE
```

## 9.4 Push Your Changes {#push-your-changes}

Now that you've updated your module to depend on `buf.build/googleapis/googleapis` instead of vendoring
the `google/type/datetime.proto` yourself, you can push the module to the BSR:

```terminal
$ buf push
---
b2917eb692064beb92ad1e38dba6c25e
```
