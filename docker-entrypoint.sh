#!/bin/sh
set -e

echo "Setting up wrangler configuration..."
if [ ! -f "/app/wrangler.json" ]; then
    cp /app/wrangler.example.json /app/wrangler.json
    sed -i "s|\${D1_DATABASE_NAME}|${D1_DATABASE_NAME:-moepush}|g" /app/wrangler.json
    sed -i "s|\${D1_DATABASE_ID}|${D1_DATABASE_ID:-moepush}|g" /app/wrangler.json
    echo "Created wrangler.json with environment variables"
fi

pnpm drizzle-kit generate
pnpm wrangler d1 migrations apply moepush --local

exec "$@"
