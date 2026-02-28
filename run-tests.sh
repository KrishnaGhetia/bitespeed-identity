#!/bin/bash

# Configuration
API_URL="http://localhost:3000/identify"
OUTPUT_DIR="test-results"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_FILE="$OUTPUT_DIR/test_results_$TIMESTAMP.json"

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Create output directory
mkdir -p $OUTPUT_DIR

echo "🧪 Starting API Tests..."
echo "📁 Results will be saved to: $OUTPUT_FILE"
echo ""

# Start JSON array
echo "[" > $OUTPUT_FILE

# Test Case 1: New Contact
echo -e "${YELLOW}Test 1: Creating new contact${NC}"
RESPONSE=$(curl -s -X POST $API_URL \
  -H "Content-Type: application/json" \
  -d '{"email":"lorraine@hillvalley.edu","phoneNumber":"123456"}')
echo "$RESPONSE" | jq '.'
echo "  {\"test\": \"Test 1: New Contact\", \"request\": {\"email\":\"lorraine@hillvalley.edu\",\"phoneNumber\":\"123456\"}, \"response\": $RESPONSE}," >> $OUTPUT_FILE
echo ""

# Test Case 2: Same phone, new email (creates secondary)
echo -e "${YELLOW}Test 2: Same phone, new email${NC}"
RESPONSE=$(curl -s -X POST $API_URL \
  -H "Content-Type: application/json" \
  -d '{"email":"mcfly@hillvalley.edu","phoneNumber":"123456"}')
echo "$RESPONSE" | jq '.'
echo "  {\"test\": \"Test 2: Same phone, new email\", \"request\": {\"email\":\"mcfly@hillvalley.edu\",\"phoneNumber\":\"123456\"}, \"response\": $RESPONSE}," >> $OUTPUT_FILE
echo ""

# Test Case 3: Same email, new phone
echo -e "${YELLOW}Test 3: Same email, new phone${NC}"
RESPONSE=$(curl -s -X POST $API_URL \
  -H "Content-Type: application/json" \
  -d '{"email":"lorraine@hillvalley.edu","phoneNumber":"789012"}')
echo "$RESPONSE" | jq '.'
echo "  {\"test\": \"Test 3: Same email, new phone\", \"request\": {\"email\":\"lorraine@hillvalley.edu\",\"phoneNumber\":\"789012\"}, \"response\": $RESPONSE}," >> $OUTPUT_FILE
echo ""

# Test Case 4: Only email
echo -e "${YELLOW}Test 4: Query with only email${NC}"
RESPONSE=$(curl -s -X POST $API_URL \
  -H "Content-Type: application/json" \
  -d '{"email":"mcfly@hillvalley.edu"}')
echo "$RESPONSE" | jq '.'
echo "  {\"test\": \"Test 4: Only email\", \"request\": {\"email\":\"mcfly@hillvalley.edu\"}, \"response\": $RESPONSE}," >> $OUTPUT_FILE
echo ""

# Test Case 5: Only phone
echo -e "${YELLOW}Test 5: Query with only phone${NC}"
RESPONSE=$(curl -s -X POST $API_URL \
  -H "Content-Type: application/json" \
  -d '{"phoneNumber":"123456"}')
echo "$RESPONSE" | jq '.'
echo "  {\"test\": \"Test 5: Only phone\", \"request\": {\"phoneNumber\":\"123456\"}, \"response\": $RESPONSE}," >> $OUTPUT_FILE
echo ""

# Test Case 6: Create first primary for linking test
echo -e "${YELLOW}Test 6: Create first primary (george)${NC}"
RESPONSE=$(curl -s -X POST $API_URL \
  -H "Content-Type: application/json" \
  -d '{"email":"george@hillvalley.edu","phoneNumber":"919191"}')
echo "$RESPONSE" | jq '.'
echo "  {\"test\": \"Test 6: First primary\", \"request\": {\"email\":\"george@hillvalley.edu\",\"phoneNumber\":\"919191\"}, \"response\": $RESPONSE}," >> $OUTPUT_FILE
echo ""

# Test Case 7: Create second primary for linking test
echo -e "${YELLOW}Test 7: Create second primary (biff)${NC}"
RESPONSE=$(curl -s -X POST $API_URL \
  -H "Content-Type: application/json" \
  -d '{"email":"biffsucks@hillvalley.edu","phoneNumber":"717171"}')
echo "$RESPONSE" | jq '.'
echo "  {\"test\": \"Test 7: Second primary\", \"request\": {\"email\":\"biffsucks@hillvalley.edu\",\"phoneNumber\":\"717171\"}, \"response\": $RESPONSE}," >> $OUTPUT_FILE
echo ""

# Test Case 8: Link two primaries (MOST IMPORTANT TEST)
echo -e "${YELLOW}Test 8: Link two primary contacts${NC}"
RESPONSE=$(curl -s -X POST $API_URL \
  -H "Content-Type: application/json" \
  -d '{"email":"george@hillvalley.edu","phoneNumber":"717171"}')
echo "$RESPONSE" | jq '.'
echo "  {\"test\": \"Test 8: Link primaries\", \"request\": {\"email\":\"george@hillvalley.edu\",\"phoneNumber\":\"717171\"}, \"response\": $RESPONSE}," >> $OUTPUT_FILE
echo ""

# Test Case 9: Duplicate request
echo -e "${YELLOW}Test 9: Exact duplicate request${NC}"
RESPONSE=$(curl -s -X POST $API_URL \
  -H "Content-Type: application/json" \
  -d '{"email":"lorraine@hillvalley.edu","phoneNumber":"123456"}')
echo "$RESPONSE" | jq '.'
echo "  {\"test\": \"Test 9: Duplicate request\", \"request\": {\"email\":\"lorraine@hillvalley.edu\",\"phoneNumber\":\"123456\"}, \"response\": $RESPONSE}," >> $OUTPUT_FILE
echo ""

# Test Case 10: Invalid request (no email or phone)
echo -e "${YELLOW}Test 10: Invalid request${NC}"
RESPONSE=$(curl -s -X POST $API_URL \
  -H "Content-Type: application/json" \
  -d '{}')
echo "$RESPONSE" | jq '.'
echo "  {\"test\": \"Test 10: Invalid request\", \"request\": {}, \"response\": $RESPONSE}" >> $OUTPUT_FILE
echo ""

# Close JSON array
echo "]" >> $OUTPUT_FILE

echo -e "${GREEN}✅ All tests completed!${NC}"
echo -e "${GREEN}📊 Results saved to: $OUTPUT_FILE${NC}"