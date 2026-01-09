# Micro GitOps Platform – GitOps Repository

## What is this repository?

This repository defines the **desired state of Kubernetes**.

Think of this repository as:
👉 **How the cluster should look**

This repository is watched by **Argo CD**.

---

## Golden Rule (Very Important)

If something exists in the cluster:
✅ It must exist in this repository

If it does not exist here:
❌ It should not exist in the cluster

This is GitOps.

---

## Directory Structure

```text
apps/
├── user-service/
├── product-service/
└── order-service/

