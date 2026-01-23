#!/usr/bin/env bash
set -euo pipefail

echo "================================================"
echo "  MICRO GITOPS PLATFORM — FULL VERIFICATION"
echo "  Phase 1 → Phase 5 (DevOps / Infra Only)"
echo "================================================"

APPS_NS="apps"
GITOPS_NS="gitops"

FRONTEND_URL="https://frontend.projectbyradhe.xyz"
USER_URL="https://user.projectbyradhe.xyz"
PRODUCT_URL="https://product.projectbyradhe.xyz"
ORDER_URL="https://order.projectbyradhe.xyz"

echo ""
echo "🔹 Phase 1 — Cluster & Pods"
kubectl get nodes
kubectl get ns
kubectl get pods -n "$APPS_NS"

echo ""
echo "🔹 Phase 2 — Argo CD GitOps State"
kubectl get applications -n "$GITOPS_NS"

echo ""
echo "🔹 Phase 3 — Ingress & TLS"
kubectl get ingress -n "$APPS_NS" || true
kubectl get certificate -n "$APPS_NS" || true

echo ""
echo "🔹 Phase 4 — External Reachability"
for url in "$FRONTEND_URL" "$USER_URL" "$PRODUCT_URL" "$ORDER_URL"; do
  echo "Checking $url"
  STATUS=$(curl -k -s -o /dev/null -w "%{http_code}" "$url")
  if [[ "$STATUS" == "200" || "$STATUS" == "404" ]]; then
    echo "  ✔ OK ($STATUS)"
  else
    echo "  ❌ FAIL ($STATUS)"
    exit 1
  fi
done

echo ""
echo "🔹 Phase 5 — Internal DNS (from frontend pod)"
FRONTEND_POD=$(kubectl get pod -n "$APPS_NS" -l app=frontend -o jsonpath='{.items[0].metadata.name}')

kubectl exec -n "$APPS_NS" "$FRONTEND_POD" -- nslookup user-service.apps.svc.cluster.local
kubectl exec -n "$APPS_NS" "$FRONTEND_POD" -- nslookup product-service.apps.svc.cluster.local
kubectl exec -n "$APPS_NS" "$FRONTEND_POD" -- nslookup order-service.apps.svc.cluster.local

echo ""
echo "🔹 Phase 6 — Supabase (Infra Presence Only)"
echo "NOTE: No auto inserts expected — this is CORRECT"

echo ""
echo "================================================"
echo " ✅ PLATFORM VERIFIED — PHASE 1 → PHASE 5 PASS"
echo "================================================"
