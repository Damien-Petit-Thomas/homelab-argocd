# Contributing

## Toolchain

Every tool is pinned in `mise.toml` and locked in `mise.lock`; CI installs
the same versions with `jdx/mise-action`.

```bash
mise trust && mise install   # pinned versions, checksums verified
pre-commit install           # git hooks, run from a mise-activated shell
mise run lint                # every hook on the whole tree, as in CI
mise run chart:lint          # helm lint --strict with the test values
mise run chart:test          # helm-unittest
```

## Commits and releases

[Conventional Commits](https://www.conventionalcommits.org/). Releases are
immutable tags `vX.Y.Z` (protected by the `release-tags` ruleset), which the
`root` Application of a consumer pins. Renaming a rendered object is a
breaking change ([ADR 0001](docs/adr/0001-same-object-names.md)).

## Pull requests

`main` accepts pull requests only; they merge when `ci-ok` and `zizmor`
pass. A new CI job joins the `needs` of `ci-ok`, never the ruleset.

## Tests

Every template change comes with unit tests; every validation comes with a
negative test that checks the error message.
