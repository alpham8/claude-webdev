## 4) Clean Code (Non-Negotiable)

**Readability over cleverness — always.**

- **Guard clauses first**: Return early to avoid deep nesting.
- **Single responsibility**: One function does one thing.
- **Small functions**: A function should fit on one screen (~30–40 lines maximum). If it does not, split it.
- **No magic numbers or strings**: Use named constants or enums.
- **No premature abstraction**: Add layers only when they demonstrably reduce complexity.
- **Meaningful names**: Variables, functions, and classes must reveal intent. No unexplained abbreviations.
- **No dead code**: Remove commented-out code; use version control instead.
- **get vs find naming**: `getX()` expects the result to exist and throws on failure. `findX()` is a lookup that may return an empty result (empty array, empty string). Never mix these semantics.
- **Boolean method names**: Methods returning `bool` must start with `is`, `has`, `can`, `should`, or `was` — e.g. `isActive()`, `hasPermission()`, `canEdit()`.

```typescript
// ❌ Bad
function p(u: any, t: string) {
    if (u !== null) { if (u.active) { if (t === 'x') { return 42; } } }
}

// ✅ Good
const PERMISSION_DENIED = 403;

function resolvePermission(user: User, type: PermissionType): number
{
    if (!user.active) {
        return PERMISSION_DENIED;
    }

    if (type !== PermissionType.Admin) {
        return PERMISSION_DENIED;
    }

    return HttpStatus.Ok;
}
```