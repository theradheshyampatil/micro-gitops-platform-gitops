#!/usr/bin/env bash
set -euo pipefail

echo "======================================="
echo " PHASE 4 – BUSINESS & DATA FLOW"
echo "======================================="

PRODUCT_URL="https://product.projectbyradhe.xyz"
ORDER_URL="https://order.projectbyradhe.xyz"

echo ""
echo "1️⃣ Product service reachability (404 acceptable)..."
STATUS=$(curl -k -s -o /dev/null -w "%{http_code}" "$PRODUCT_URL/products")

if [[ "$STATUS" == "200" || "$STATUS" == "404" ]]; then
  echo "✔ Product service reachable (status=$STATUS)"
else
  echo "❌ Product service unreachable (status=$STATUS)"
  exit 1
fi

echo ""
echo "2️⃣ Unauthorized order creation (should be blocked)..."
STATUS=$(curl -k -s -o /dev/null -w "%{http_code}" \
  -X POST "$ORDER_URL/orders" \
  -H "Content-Type: application/json" \
  -d '{}')

if [[ "$STATUS" == "401" || "$STATUS" == "403" ]]; then
  echo "✔ Order endpoint protected (status=$STATUS)"
elif [[ "$STATUS" == "404" ]]; then
  echo "⚠ Order API not implemented yet (acceptable)"
else
  echo "❌ Unexpected order endpoint behavior (status=$STATUS)"
  exit 1
fi

echo ""
echo "======================================="
echo " PHASE 4 BASELINE PASSED (INFRA + SECURITY)"
echo "======================================="
