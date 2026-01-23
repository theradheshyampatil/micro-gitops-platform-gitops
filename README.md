# Micro GitOps Platform

Production-style GitOps platform running on Kubernetes (k3s) with:

## Stack
- Jenkins (CI)
- AWS ECR
- GitHub (Source + GitOps)
- Argo CD (CD)
- Traefik (Ingress)
- cert-manager (TLS)
- Prometheus + Grafana (Monitoring)

## Architecture
CI:
Jenkins → Build → Push Image → Update GitOps repo

CD:
GitOps repo → Argo CD → k3s → Traefik

## Access
- Jenkins: https://jenkins.projectbyradhe.xyz

## Notes
- Jenkins home is PVC-backed (not committed)
- All manifests are declarative
- Platform is restart-safe

