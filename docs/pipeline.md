# The CI/CD pipeline

File: `.github/workflows/terraform.yml`. One workflow, triggered two ways.

## Triggers
- **pull_request → main:** runs the full check suite and posts the plan as a PR
  comment. Nothing is applied.
- **push → main (i.e. after merge):** runs the checks again and then `apply`.

## Steps, in order
1. **Checkout** the code.
2. **Configure AWS credentials (OIDC).** `aws-actions/configure-aws-credentials`
   exchanges the workflow's short-lived GitHub OIDC token for temporary AWS
   credentials by assuming the IAM role from `bootstrap`. No access keys exist
   anywhere in GitHub.
3. **Setup Terraform** (pinned version).
4. **fmt -check** — formatting is enforced, not suggested.
5. **init** — connects to the S3 backend.
6. **validate** — the config is internally consistent.
7. **TFLint** — provider-aware linting (deprecated args, bad instance types, ...).
8. **Checkov** — security scanning of the Terraform (public buckets, open
   security groups, unencrypted volumes, ...). Soft-fail in the lab; a hard gate
   in production.
9. **plan** — the proposed change.
10. **Comment plan on PR** — the exact diff, posted for review, on pull requests.
11. **apply** — only on push to main.

## Why OIDC matters
Long-lived AWS access keys stored as GitHub secrets are the classic CI security
hole: they don't rotate, they leak in logs, and they grant standing access. OIDC
issues a fresh token per run, valid for minutes, and the IAM trust policy is
scoped with a `sub` condition to THIS repository — so no other repo can assume
the role even if it somehow got the ARN.

## Permissions the workflow needs
`id-token: write` (to request the OIDC token), `contents: read` (checkout),
`pull-requests: write` (to comment the plan).
