# 0001. The chart renders the objects of an existing bootstrap unchanged

**Status:** Accepted

## Context
This chart was extracted from a working overlay whose `bootstrap/` directory
held the AppProjects, the ApplicationSet, a repository declaration and a
repository credential template, all managed by a `root` Application. ArgoCD
identifies a managed object by its tracking annotation, built from the
Application name and the object's group, kind, namespace and name. If any of
these changes, ArgoCD prunes the old object and creates a new one: deleting an
AppProject orphans its Applications, deleting the ApplicationSet deletes the
Applications it generated.

## Decision
- Object names come from values whose defaults are the names used before the
  extraction (`bootstrap`, `apps`); the Application stays `root`.
- Version 0.1.0 renders objects identical, field for field, to the ones it
  replaces: no added label, no reordered list. Improvements come in later
  versions, each one reviewed on its own ArgoCD diff.
- Before the switch, the chart rendered with the overlay's values was compared
  object by object (normalized JSON) with the manifests it replaces: five
  objects, five identical. The comparison was itself checked by removing one
  denied namespace from the values, which it reported.
- The switch is then a source change of `root`: the ArgoCD diff must show no
  deletion and no creation.

## Consequences
- Renaming an object is a breaking change of this chart (major version), with
  a migration note.
- The AppProjects and the credential template carry
  `Prune=false,Delete=false`: even a wrong rename cannot delete them.
