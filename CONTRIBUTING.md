# Contributing to krye.io

This document is more of a set of guidelines for me (@rye), but it is
always helpful to know what kinds of goals I have for this project.

## Branching

If you are working on solving a specific issue, or you are adding a feature or refactoring something, **make a branch *specifically* for your work solving that problem.**
<u>DO NOT</u> include anything else on that branch.
If you are not a core contributor to this project, helping maintainers by being very descriptive will help you get your changes merged immensely.

## Role of Branches

The `master` branch is considered the latest stable code.
Code that goes into the next major or minor versions&mdash;but not patch versions&mdash;should go into a separate branch. (e.g. `v6.1`)

The idea here is not to have a branch such as `vX.Y` be a separate `master`, but rather to keep *new features* separate from *bugfixes and slight tweaks.*
This branch will get merged when it is ready for release, never before.
Likewise, bugfixes and slight tweaks&mdash;either to boost performance through non-user-facing changes or something else&mdash;should be targeted at merging directly into master and being included in the next patch release.

## Refactoring

If you refactor something, the amount of change you make to the functionality of the code determines whether it goes in the next minor release or the next patch release.
