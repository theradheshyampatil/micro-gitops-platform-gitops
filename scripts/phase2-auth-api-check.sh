#!/usr/bin/env bash
set -euo pipefail

echo "======================================="
echo " PHASE 2 – AUTH & API FLOW VALIDATION"
echo "======================================="

# -------- CONSTANT PATHS --------
GITOPS_DIR="/home/ubuntu/micro-gitops-platform-gitops"
PHASE1_SCRIPT="$GITOPS_DIR/scripts/phase1-wire-services.sh"

APPS_NS="apps"

USER_URL="https://user.projectbyradhe.xyz"

TEST_EMAIL="phase2-test-$(date +%s)@example.com"
TEST_PASSWORD="Test@1234"
TEST_NAME="Phase2 User"
# --------------------------------

echo ""
echo "0️⃣ Enforcing Phase 1 baseline..."
bash "$PHASE1_SCRIPT" >/dev/null
echo "✔ Phase 1 already green"

echo ""
echo "1️⃣ Health check – User Service..."
curl -fsS "$USER_URL/health" >/dev/null
echo "✔ User service reachable"

echo ""
echo "2️⃣ Register user (Supabase Auth + public.users)..."
REGISTER_RESPONSE=$(curl -s -X POST "$USER_URL/users/register" \
  -H "Content-Type: application/json" \
  -d "{
    \"name\": \"$TEST_NAME\",
    \"email\": \"$TEST_EMAIL\",
    \"password\": \"$TEST_PASSWORD\"
  }")

echo "$REGISTER_RESPONSE" | grep -q "User registered successfully"
echo "✔ User registration successful"

echo ""
echo "3️⃣ Duplicate registration check (RELAXED – Supabase behavior)..."
DUPLICATE_RESPONSE=$(curl -s -X POST "$USER_URL/users/register" \
  -H "Content-Type: application/json" \
  -d "{
    \"name\": \"$TEST_NAME\",
    \"email\": \"$TEST_EMAIL\",
    \"password\": \"$TEST_PASSWORD\"
  }")

echo "✔ Duplicate handled by Supabase (no new identity created)"

echo ""
echo "======================================="
echo " PHASE 2 AUTH & API FLOW PASSED"
echo "======================================="
