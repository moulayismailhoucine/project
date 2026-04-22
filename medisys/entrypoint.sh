#!/bin/bash
set -e

cd /var/www/html

# Run Laravel migrations
php artisan migrate --force

# Cache configs, routes, and views (runtime only — needs APP_KEY and DB)
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Start Apache in foreground
exec apache2-foreground
