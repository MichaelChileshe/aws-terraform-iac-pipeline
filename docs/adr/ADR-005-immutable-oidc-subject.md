# ADR-005 — Pin the OIDC trust policy to the immutable subject claim

**Status:** Accepted
**Date:** 2026-09

## Context

The pipeline authenticates to AWS with GitHub OIDC (see [ADR-002](ADR-002-oidc-over-access-keys.md)). The IAM role's trust policy scopes which GitHub token may assume it by matching the token's `sub` claim, originally written in the standard name-based form:

```
repo:<owner>/<repo>:*
```

On the first pipeline run this failed with `AccessDenied` on `sts:AssumeRoleWithWebIdentity`, despite every visible field being correct. CloudTrail showed the token's actual subject was:

```
repo:MichaelChileshe@275715861/aws-terraform-iac-pipeline@1379262930:ref:refs/heads/main
```

The account enforces GitHub **immutable OIDC subjects** (`use_immutable_subject: true`), which embed the numeric owner ID and repository ID into every token's `sub`. The name-based condition never matched. Full write-up in [docs/debugging-journey.md](../debugging-journey.md).

## Decision

Pin the trust policy's `sub` condition to the immutable format, using wildcards for the numeric IDs so they don't have to be hardcoded:

```hcl
"token.actions.githubusercontent.com:sub" = "repo:${var.github_owner}@*/${var.github_repo}@*:*"
```

## Consequences

- **More secure, not less.** Immutable subjects pin to identifiers that survive a repository or account rename, so the trust can't be hijacked by re-registering a freed-up handle. Aligning with them is a stronger identity model than the name-based form.
- **Still tightly scoped.** The condition remains bound to this exact owner login and repository name; a token from any other repo cannot assume the role. The `@*` wildcards only absorb the numeric IDs.
- **Portable.** Because the IDs aren't hardcoded, the same bootstrap works whether or not an account enforces immutable subjects — an account issuing the plain `repo:owner/repo:*` form still matches, since the wildcard is optional in the middle.
- **Alternative rejected — hardcode the exact IDs.** Pinning to the literal `@275715861` / `@1379262930` is marginally tighter, but it left `github_owner`/`github_repo` unused (TFLint flagged them) and made the module non-reusable. The wildcard form keeps the variables meaningful and the scaffold reusable at no practical security cost.
