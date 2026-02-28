#!/bin/bash

echo "🗑️  Resetting database..."

# Stop if server is running (optional - you can skip this)
# pkill -f "ts-node src/index.ts"

# Delete the database
rm -f prisma/dev.db
rm -f prisma/dev.db-journal

# Recreate the database
npx prisma migrate dev --name init

echo "✅ Database reset complete!"
echo "🚀 Start server with: npm run dev"