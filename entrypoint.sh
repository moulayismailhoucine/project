#!/bin/bash
set -e

cd /var/www/html

echo "APP_KEY length: ${#APP_KEY}"
echo "DB_CONNECTION: $DB_CONNECTION"
echo "DATABASE_URL set: $(test -n "$DATABASE_URL" && echo 'yes' || echo 'no')"

# Wait for database to be ready (up to 60 seconds)
echo "Waiting for database..."
i=0
while [ $i -lt 30 ]; do
    php artisan migrate --force && break
    echo "DB not ready, retrying in 2s... ($i/30)"
    sleep 2
    i=$((i + 1))
done

if [ $i -eq 30 ]; then
    echo "ERROR: Database not ready after 60 seconds"
    exit 1
fi

# Cache configs, routes, and views (runtime only — needs APP_KEY and DB)
php artisan config:cache || echo "config:cache failed, continuing..."
php artisan route:cache || echo "route:cache failed, continuing..."
php artisan view:cache || echo "view:cache failed, continuing..."

echo "Startup complete, starting Apache..."

# Start Apache in foreground
exec apache2-foreground
