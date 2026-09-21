# ADR-003 — S3 native state locking over DynamoDB

**Status:** Accepted · **Date:** 2026-09-18

## Context
Remote state must be locked so two applies can't run at once. The long-standing
pattern is an S3 bucket for state plus a DynamoDB table for the lock.

## Decision
Use Terraform 1.10's native S3 state locking (`use_lockfile = true`) — no
DynamoDB table.

## Reasoning
Native locking removes a whole resource (the DynamoDB table) and its IAM
permissions from the design, while giving the same protection. Fewer moving parts.

## Trade-off accepted
Requires Terraform >= 1.10 (pinned in `required_version`). Teams on older
Terraform still need the DynamoDB pattern.
