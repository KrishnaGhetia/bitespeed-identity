#!/bin/bash

echo "═══════════════════════════════════════════════"
echo "  Bitespeed Identity Reconciliation Test Suite"
echo "═══════════════════════════════════════════════"
echo ""

# Step 1: Reset database
echo "Step 1/3: Resetting database..."
rm -f prisma/dev.db prisma/dev.db-journal
npx prisma migrate dev --name init > /dev/null 2>&1
echo "✅ Database reset complete"
echo ""

# Step 2: Check if server is running
echo "Step 2/3: Checking server status..."
if curl -s http://localhost:3000/health > /dev/null 2>&1; then
    echo "✅ Server is running"
else
    echo "❌ Server is NOT running"
    echo "Please start the server with: npm run dev"
    echo "Then run this script again"
    exit 1
fi
echo ""

# Step 3: Run tests
echo "Step 3/3: Running tests..."
./run-tests.sh

echo ""
echo "═══════════════════════════════════════════════"
echo "  Test Suite Complete!"
echo "═══════════════════════════════════════════════"