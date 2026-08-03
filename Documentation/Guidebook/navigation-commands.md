# Navigation commands

All programmatic path mutations go through `NavigationController`. The same
commands support NavigationKit's native view and custom navigation views.

## Root commands

| Capability | Command |
| --- | --- |
| Select a configured root | `navigation.select(root: .library)` |
| Navigate on the selected root | `navigation.navigate(to: .article(id: 42))` |
| Navigate on another root | `navigation.navigate(to: .article(id: 42), on: .library)` |
| Navigate backward | `navigation.navigateBack()` |
| Navigate backward several steps | `navigation.navigateBack(2, on: .library)` |
| Return to a root destination | `navigation.returnToRoot(on: .library)` |
| Read a root path | `navigation[.library]` |
| Replace a complete path | `navigation.replacePath(with: path, on: .library)` |

When `on:` is omitted, commands target the selected root. A successful command
with an explicit root also selects that root. Unconfigured roots are ignored,
and reading one returns an empty path.

Paths are publicly readable but mutate through controller commands. This keeps
native and custom views synchronized and preserves controller invariants.

## Navigation semantics

`navigate(to:)` uses first-match reuse:

- If the destination is absent, it is appended.
- If the destination is already present, everything after its first occurrence
  is removed.
- If the destination is already the last path element, the path is unchanged.

This provides idempotent programmatic navigation and avoids ordinary commands
building duplicate copies of the same typed location.

`navigateBack(_:)` removes up to the requested number of path entries. A
nonpositive count is ignored; a count larger than the path depth safely lands
on the root.

`returnToRoot(on:)` removes the complete path for one root.

`replacePath(with:on:)` installs an exact typed path. Equal paths avoid an
unnecessary observation update. This is useful when an app has already parsed
or restored navigation state, although NavigationKit 1.0 does not provide a
deep-link parser or persistence format.

## Paths remain independent

Commands can target a root that is not currently selected:

```swift
navigation.navigate(
    to: .article(id: 42),
    on: .library
)
```

The Library path changes and Library becomes selected. Other configured root
paths are not rewritten.

Modal occurrences expose the same path operations with an `in:` presentation
identifier. See [Modal presentations](presentations.md).
