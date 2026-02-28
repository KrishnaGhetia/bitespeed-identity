#!/bin/bash

API_URL="http://localhost:3000/identify"
OUTPUT_FILE="requirements-validation.json"

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  Bitespeed Requirements Validation Test Suite                 ║"
echo "╔════════════════════════════════════════════════════════════════╗"
echo ""

# Function to test and validate
test_scenario() {
    local scenario_name="$1"
    local request="$2"
    local expected_desc="$3"
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📋 Scenario: $scenario_name"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📤 Request:"
    echo "$request" | jq '.'
    echo ""
    echo "📥 Response:"
    
    response=$(curl -s -X POST "$API_URL" \
        -H "Content-Type: application/json" \
        -d "$request")
    
    echo "$response" | jq '.'
    echo ""
    echo "✅ Expected: $expected_desc"
    echo ""
}

# ═══════════════════════════════════════════════════════════════════
# SCENARIO 1: Creating Secondary Contact (From Requirements Example)
# ═══════════════════════════════════════════════════════════════════

echo "═══════════════════════════════════════════════════════════════════"
echo "  SCENARIO 1: When is a secondary contact created?"
echo "═══════════════════════════════════════════════════════════════════"
echo ""

test_scenario \
    "1a. Create Primary Contact" \
    '{"email":"lorraine@hillvalley.edu","phoneNumber":"123456"}' \
    "Primary contact created with ID 1"

test_scenario \
    "1b. Create Secondary Contact (same phone, new email)" \
    '{"email":"mcfly@hillvalley.edu","phoneNumber":"123456"}' \
    "Secondary contact created with ID 2, linked to primary ID 1"

test_scenario \
    "1c. Query with existing email" \
    '{"email":"mcfly@hillvalley.edu","phoneNumber":"123456"}' \
    "Returns consolidated contact - no new contact created"

test_scenario \
    "1d. Query with only email" \
    '{"email":"lorraine@hillvalley.edu"}' \
    "Returns all contacts linked to this email"

test_scenario \
    "1e. Query with only phone" \
    '{"phoneNumber":"123456"}' \
    "Returns all contacts linked to this phone"

# ═══════════════════════════════════════════════════════════════════
# SCENARIO 2: Primary Turning Secondary (From Requirements Example)
# ═══════════════════════════════════════════════════════════════════

echo "═══════════════════════════════════════════════════════════════════"
echo "  SCENARIO 2: Can primary contacts turn into secondary?"
echo "═══════════════════════════════════════════════════════════════════"
echo ""

test_scenario \
    "2a. Create First Primary (George)" \
    '{"email":"george@hillvalley.edu","phoneNumber":"919191"}' \
    "Primary contact created for George"

test_scenario \
    "2b. Create Second Primary (Biff)" \
    '{"email":"biffsucks@hillvalley.edu","phoneNumber":"717171"}' \
    "Separate primary contact created for Biff"

test_scenario \
    "2c. Link Two Primaries" \
    '{"email":"george@hillvalley.edu","phoneNumber":"717171"}' \
    "Older primary (George) stays primary, newer (Biff) becomes secondary"

test_scenario \
    "2d. Verify Consolidation" \
    '{"email":"biffsucks@hillvalley.edu"}' \
    "Returns consolidated contact with George as primary"

# ═══════════════════════════════════════════════════════════════════
# SCENARIO 3: Edge Cases
# ═══════════════════════════════════════════════════════════════════

echo "═══════════════════════════════════════════════════════════════════"
echo "  SCENARIO 3: Edge Cases"
echo "═══════════════════════════════════════════════════════════════════"
echo ""

test_scenario \
    "3a. Invalid Request (no email or phone)" \
    '{}' \
    "Returns error"

test_scenario \
    "3b. New Contact with only email" \
    '{"email":"doc@hillvalley.edu"}' \
    "Creates new primary with null phone"

test_scenario \
    "3c. New Contact with only phone" \
    '{"phoneNumber":"555000"}' \
    "Creates new primary with null email"

echo "═══════════════════════════════════════════════════════════════════"
echo "  ✅ All Validation Tests Complete!"
echo "═══════════════════════════════════════════════════════════════════"