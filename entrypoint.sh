#!/bin/bash

cd /var/www/html

# Wait for database to be ready (up to 60 seconds)
echo "Waiting for database..."
for i in {1..30}; do
    php artisan migrate --force 2>/dev/null && break
    echo "DB not ready, retrying in 2s... ($i/30)"
    sleep 2
done

# Cache configs, routes, and views (runtime only — needs APP_KEY and DB)
php artisan config:cache 2>/dev/null || true
php artisan route:cache 2>/dev/null || true
php artisan view:cache 2>/dev/null || true

# Start Apache in foreground
exec apache2-foreground
