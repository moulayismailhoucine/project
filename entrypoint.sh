#!/bin/bash
set -e

# Run Laravel migrations
cd /var/www/html
php artisan migrate --force

# Start Apache in foreground
exec apache2-foreground
