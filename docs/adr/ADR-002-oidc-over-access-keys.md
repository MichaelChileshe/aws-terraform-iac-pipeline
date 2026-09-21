# ADR-002 — OIDC over stored access keys for CI

**Status:** Accepted · **Date:** 2026-09-18

## Context
The pipeline needs AWS credentials. The traditional approach stores an IAM
user's access key and secret as GitHub secrets.

## Decision
Use GitHub OIDC federation: the workflow assumes an IAM role by exchanging a
short-lived OIDC token, with no stored keys.

## Reasoning
Stored access keys are long-lived, don't rotate, can leak in logs, and grant
standing access. OIDC issues a fresh, minutes-long token per run, and the role's
trust policy is scoped with a `sub` condition to this repository only.

## Trade-off accepted
One-time setup is more involved (an OIDC provider + a role with a correct trust
policy) than pasting two secrets. The security gain is decisive.
