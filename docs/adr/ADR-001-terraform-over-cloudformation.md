# ADR-001 — Terraform over CloudFormation

**Status:** Accepted · **Date:** 2026-09-18

## Context
The environment needs to be defined as code. The two obvious choices are
Terraform and AWS CloudFormation.

## Decision
Use Terraform.

## Reasoning
Terraform is cloud-agnostic (the same tool and skills apply beyond AWS), has a
larger module/registry ecosystem, a readable plan/apply workflow, and a mature
story for remote state and CI/CD. CloudFormation is AWS-native and needs no state
management, but is AWS-only and more verbose.

## Trade-off accepted
Terraform state must be stored and locked (handled here with S3 + native
locking), which CloudFormation avoids by keeping state server-side. Worth it for
the ecosystem and portability.
