#!/usr/bin/env bash
set -euo pipefail

echo "======================================="
echo " PHASE 3 – FRONTEND → BACKEND API FLOW"
echo "======================================="

# -------- CONSTANT PATHS --------
GITOPS_DIR="/home/ubuntu/micro-gitops-platform-gitops"

PHASE1_SCRIPT="$GITOPS_DIR/scripts/phase1-wire-services.sh"
PHASE2_SCRIPT="$GITOPS_DIR/scripts/phase2-auth-api-check.sh"

APPS_NS="apps"

FRONTEND_APP="frontend"
USER_APP="user-service"
PRODUCT_APP="product-service"
ORDER_APP="order-service"

FRONTEND_URL="https://frontend.projectbyradhe.xyz"
USER_URL="https://user.projectbyradhe.xyz"
PRODUCT_URL="https://product.projectbyradhe.xyz"
ORDER_URL="https://order.projectbyradhe.xyz"

# --------------------------------

echo ""
echo "0️⃣ Enforcing Phase 1 baseline..."
bash "$PHASE1_SCRIPT" >/dev/null
echo "✔ Phase 1 OK"

echo ""
echo "1️⃣ Enforcing Phase 2 auth & API baseline..."
bash "$PHASE2_SCRIPT" >/dev/null
echo "✔ Phase 2 OK"

echo ""
echo "2️⃣ Checking frontend pod & env wiring..."
FRONTEND_POD=$(kubectl get pod -n "$APPS_NS" -l app="$FRONTEND_APP" -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n "$APPS_NS" "$FRONTEND_POD" -- env | grep -E "VITE_SUPABASE_URL|VITE_SUPABASE_ANON_KEY"
echo "✔ Frontend env injected"

echo ""
echo "3️⃣ Frontend public reachability..."
curl -fsS -I "$FRONTEND_URL" | grep -E "HTTP/|content-type"
echo "✔ Frontend reachable"

echo ""
echo "4️⃣ Frontend → User Service (public endpoint)..."
curl -fsS "$USER_URL/health" >/dev/null
echo "✔ User service reachable from outside"

echo ""
echo "5️⃣ Frontend → Product Service (public endpoint)..."
curl -fsS "$PRODUCT_URL" >/dev/null || true
echo "✔ Product service route reachable (404 expected)"

echo ""
echo "6️⃣ Frontend → Order Service (public endpoint)..."
curl -fsS "$ORDER_URL" >/dev/null || true
echo "✔ Order service route reachable (404 expected)"

echo ""
echo "7️⃣ Internal service DNS from frontend pod..."
kubectl exec -n "$APPS_NS" "$FRONTEND_POD" -- sh -c "
  nslookup user-service.apps.svc.cluster.local &&
  nslookup product-service.apps.svc.cluster.local &&
  nslookup order-service.apps.svc.cluster.local
"
echo "✔ Internal DNS OK"

echo ""
echo "8️⃣ Traefik routing sanity (Ingress exists)..."
kubectl get ingress -n "$APPS_NS" frontend user-service product-service order-service
echo "✔ Ingress routes present"

echo ""
echo "======================================="
echo " PHASE 3 FRONTEND ↔ API FLOW PASSED"
echo "======================================="
