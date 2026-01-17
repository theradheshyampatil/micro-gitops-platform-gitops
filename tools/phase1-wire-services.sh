#!/usr/bin/env bash
set -euo pipefail

echo "======================================="
echo " PHASE 1 – FRONTEND ↔ BACKEND WIRING"
echo "======================================="

# ---------- CONSTANT PATHS ----------
GITOPS_DIR="/home/ubuntu/micro-gitops-platform-gitops"

FRONTEND_NS="apps"
GITOPS_NS="gitops"

FRONTEND_APP="frontend"
USER_APP="user-service"
PRODUCT_APP="product-service"
ORDER_APP="order-service"

FRONTEND_URL="https://frontend.projectbyradhe.xyz"
USER_URL="https://user.projectbyradhe.xyz"
PRODUCT_URL="https://product.projectbyradhe.xyz"
ORDER_URL="https://order.projectbyradhe.xyz"
# ------------------------------------

echo ""
echo "1️⃣ Checking GitOps repo paths..."
cd "$GITOPS_DIR"
ls apps/frontend apps/user-service apps/product-service apps/order-service >/dev/null
echo "✔ Repo paths OK"

echo ""
echo "2️⃣ Checking ArgoCD applications..."
kubectl get applications -n "$GITOPS_NS" | grep -E "$FRONTEND_APP|$USER_APP|$PRODUCT_APP|$ORDER_APP"

echo ""
echo "3️⃣ Checking pod status..."
kubectl get pods -n "$FRONTEND_NS" -l app="$FRONTEND_APP"
kubectl get pods -n "$FRONTEND_NS" -l app="$USER_APP"
kubectl get pods -n "$FRONTEND_NS" -l app="$PRODUCT_APP"
kubectl get pods -n "$FRONTEND_NS" -l app="$ORDER_APP"

echo ""
echo "4️⃣ Checking ingress routes..."
kubectl get ingress -n "$FRONTEND_NS"

echo ""
echo "5️⃣ External reachability checks..."
echo "→ Frontend"
curl -I "$FRONTEND_URL" | head -n 5

echo "→ User Service"
curl -I "$USER_URL" | head -n 5 || true

echo "→ Product Service"
curl -k -I "$PRODUCT_URL" | head -n 5 || true

echo "→ Order Service"
curl -k -I "$ORDER_URL" | head -n 5 || true

echo ""
echo "6️⃣ Internal service DNS check (from frontend pod)..."
FRONTEND_POD=$(kubectl get pod -n "$FRONTEND_NS" -l app="$FRONTEND_APP" -o jsonpath='{.items[0].metadata.name}')

kubectl exec -n "$FRONTEND_NS" "$FRONTEND_POD" -- sh -c '
echo "→ user-service"
nslookup user-service.apps.svc.cluster.local

echo "→ product-service"
nslookup product-service.apps.svc.cluster.local

echo "→ order-service"
nslookup order-service.apps.svc.cluster.local
'

echo ""
echo "======================================="
echo " PHASE 1 BASELINE CHECK COMPLETE"
echo "======================================="
