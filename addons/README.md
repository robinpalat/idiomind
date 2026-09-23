# Idiomind Add-on Architecture

## Overview

Idiomind uses a modular add-on architecture based on **filesystem
conventions, automatic discovery, and distributed extension points**.

-   Add-ons live under `addons/`.
-   Each add-on has a mandatory `conf.sh`.
-   Idiomind discovers add-ons by iterating `addons/`.
-   Integration occurs through extension points under `ifs/extensions/`.
-   An add-on can participate in one or more extension points.
-   The filesystem acts as a lightweight registration mechanism.

## Directory structure

``` text
/usr/share/idiomind/
├── addons/
│   ├── AddonA/
│   │   ├── conf.sh
│   │   └── ...
│   └── AddonB/
│       ├── conf.sh
│       └── ...
├── ifs/
│   ├── cmns.sh
│   └── extensions/
│       ├── add/
│       ├── add_processors/
│       ├── change/
│       ├── commands/
│       ├── export/
│       ├── main/
│       ├── manager/
│       ├── play/
│       ├── practice/
│       └── start/
└── ...
```

The installation prefix may vary; the important distinction is between
the add-on layer and the extension-point tree.

## `addons/`

Each directory directly under `addons/` represents one logical add-on.

Example:

``` text
addons/Feeds/
├── conf.sh
├── feeds.sh
├── ch.xml
└── tmpl.xml
```

### `conf.sh`

`conf.sh` is mandatory. It provides the information and configuration
needed for Idiomind to recognize and expose the add-on.

### Add-on-local resources

Static resources that belong exclusively to an add-on should remain
inside that add-on:

``` bash
DSP="$DS_a/Feeds"
xsltproc "$DSP/ch.xml" "$input"
xsltproc "$DSP/tmpl.xml" "$input"
```

This keeps the add-on self-contained and avoids unnecessary dependencies
on global `default/` resources.

## `ifs/extensions/`

`ifs/extensions/` is a collection of **extension points**, not
conventional modules.

Idiomind knows these operational contracts and scans the corresponding
directory when an operation occurs.

  Extension point     Purpose
  ------------------- -------------------------------------------------
  `add/`              Direct integrations with Add operations
  `add_processors/`   Specialized processing associated with Add
  `change/`           Change/modification integrations
  `commands/`         Command integrations
  `export/`           Export integrations
  `main/`             Main-interface/list initialization integrations
  `manager/`          Manager-related integrations
  `play/`             Playback integrations
  `practice/`         Practice/learning integrations
  `start/`            Startup scripts

The name of an extension point describes **where an add-on integrates**,
not what the add-on is.

## Discovery model

There are two related discovery mechanisms.

### Add-on discovery

``` text
addons/
   ├── Addon A/
   ├── Addon B/
   └── Addon C/
          └── conf.sh
```

### Extension discovery

``` text
operation
    ↓
ifs/extensions/<extension-point>/
    ↓
execute the scripts registered there
```

For example:

``` text
start
  → ifs/extensions/start/
```

or:

``` text
export
  → ifs/extensions/export/
```

The same logical add-on can therefore have integration scripts in
several extension points.

## Add-on contracts

The architecture is convention-based rather than SDK-based.

A developer needs to understand:

1.  The required add-on structure.
2.  The purpose of each extension point.
3.  The arguments/environment supplied to its scripts.
4.  The common Idiomind functions available to it.
5.  The expected side effects of the extension point.
6.  Which files are static resources and which are user
    configuration/data.

The practical contract is defined by the existing extension points and
add-ons.

## Reusing Idiomind services

Add-ons should reuse existing Idiomind functionality rather than
duplicate core behavior.

Depending on the operation, existing infrastructure provides functions
for:

-   topic and item creation;
-   words and sentences;
-   database operations;
-   translations;
-   text-to-speech;
-   resource fetching;
-   filesystem validation;
-   cleanup;
-   review calculations;
-   learning-list rebuilding;
-   locking and error handling.

Preferred model:

``` text
Add-on
   ↓
existing Idiomind functions/services
   ↓
Idiomind data model
```

## Example: Feeds

The Feeds add-on can keep its resources together:

``` text
addons/Feeds/
├── conf.sh
├── feeds.sh
├── ch.xml
└── tmpl.xml
```

Its script can define:

``` bash
DSP="$DS_a/Feeds"
```

and access:

``` bash
xsltproc "$DSP/ch.xml" ...
xsltproc "$DSP/tmpl.xml" ...
```

If it needs startup integration, that integration belongs under the
appropriate extension point, for example:

``` text
ifs/extensions/start/
```

The logical add-on remains under `addons/Feeds/`.

## `add_processors/`

`add_processors/` is intended for specialized processing associated with
the Add operation.

Examples include:

-   speech-to-text processing;
-   audio segmentation;
-   attaching audio to sentences;
-   URL/feed detection;
-   other specialized processing triggered while adding content.

The distinction is:

``` text
add/
    direct Add integrations

add_processors/
    specialized processing performed as part of Add
```

## Configuration and user data

Static application resources belong in the installed application tree,
while mutable user configuration belongs in the user's configuration
area.

Conceptually:

``` text
/usr/share/idiomind/
    installed application + static resources

~/.config/idiomind/
    user configuration

user data directories
    topics and other mutable data
```

An add-on should not normally write mutable user configuration into
`/usr/share/idiomind`.

## Design principles

### Convention over central registration

An add-on follows a known directory/file convention instead of
registering itself in a central database.

### Distributed extension points

A single add-on may integrate into several independent parts of
Idiomind.

### Low coupling

The core knows the extension-point contracts, not the internal
implementation of each add-on.

### Reuse of core services

Existing Idiomind functions should be preferred over duplicated
implementations.

### Add-on locality

Resources belonging exclusively to an add-on should stay with that
add-on.

### Filesystem as registration

The presence of the expected script in the appropriate extension
directory is part of the registration mechanism.

## Adding a new extension point

Adding a new add-on and adding a new extension point are different
operations.

``` text
new add-on
    → normally no core modification

new integration phase
    → requires a corresponding core extension point
```

An add-on can normally be developed without modifying the core when an
existing extension point already provides the required integration.

## Developer checklist

Before creating an add-on:

-   Identify the operation being extended.
-   Find its corresponding directory under `ifs/extensions/`.
-   Inspect an existing add-on using that extension point.
-   Create the add-on directory under `addons/`.
-   Add the mandatory `conf.sh`.
-   Keep add-on-specific static resources inside the add-on directory.
-   Reuse existing Idiomind functions.
-   Store mutable user configuration outside the installed static tree.
-   Avoid hard-coded references to unrelated global resources.
-   Test the add-on in the source tree and after `.deb` installation.

## Architectural summary

``` text
                         IDIOMIND CORE
                              │
              ┌───────────────┴───────────────┐
              │                               │
        discovers addons               invokes extension
              │                       points by operation
              ▼                               ▼
        addons/                        ifs/extensions/
              │                               │
       ┌──────┼──────┐             ┌─────────┼─────────┐
       ▼      ▼      ▼             ▼         ▼         ▼
     Feeds   TTS   Other          add      start     export
       │
       ├── conf.sh
       ├── scripts
       └── private resources
```

> **Add-ons are logical units discovered under `addons/`; extension
> points under `ifs/extensions/` provide the contracts through which
> those add-ons integrate with Idiomind.**

The architecture is modular and decoupled even though it does not use a
formal plug-in SDK or manifest system. Its primary mechanisms are
convention, filesystem discovery, and operational extension points.
