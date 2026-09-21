# ADR-004 — Plan on PR, apply on merge

**Status:** Accepted · **Date:** 2026-09-18

## Context
Infrastructure changes need review before they hit real resources.

## Decision
Run `terraform plan` on every pull request and post the plan as a PR comment;
run `terraform apply` only when the change is merged to `main`.

## Reasoning
The reviewer sees the exact diff (what will be created/changed/destroyed) before
approving, and `apply` runs against reviewed, merged code only. This is the
auditable change trail the whole project exists to provide.

## Trade-off accepted
A merge to `main` applies automatically with no separate human "go" at apply
time. For production I'd add a GitHub Environment protection rule requiring a
reviewer to approve the apply step (noted in "what I'd do differently").
