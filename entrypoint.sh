#!/bin/bash

cd /var/www/html

# Generate a proper Laravel APP_KEY if not set or invalid
if [ -z "$APP_KEY" ] || [[ ! "$APP_KEY" == base64:* ]]; then
    echo "Generating Laravel APP_KEY..."
    export APP_KEY=$(php artisan key:generate --show 2>/dev/null)
    echo "APP_KEY generated: ${APP_KEY:0:20}..."
fi

echo "APP_KEY length: ${#APP_KEY}"
echo "DB_CONNECTION: $DB_CONNECTION"
echo "DATABASE_URL set: $(test -n "$DATABASE_URL" && echo 'yes' || echo 'no')"

# Ensure storage and cache directories are writable
chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache /var/www/html/public/build 2>/dev/null || true
chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache 2>/dev/null || true

# Run migrations and caches in the background so Apache can start immediately
(
    echo "Waiting for database..."
    i=0
    while [ $i -lt 30 ]; do
        php artisan tinker --execute="echo 'DB_OK';" 2>/dev/null && break
        echo "DB not ready, retrying in 2s... ($i/30)"
        sleep 2
        i=$((i + 1))
    done

    if [ $i -eq 30 ]; then
        echo "WARNING: Database not accessible after 60 seconds."
    else
        echo "Database is ready."
    fi

    # Check if this is a fresh/empty database (no users)
    USER_COUNT=$(php artisan tinker --execute="echo \App\Models\User::count();" 2>/dev/null || echo "0")
    echo "User count: $USER_COUNT"

    if [ "$USER_COUNT" = "0" ] || [ "$USER_COUNT" = "" ]; then
        echo "Fresh database detected. Running migrate:fresh --force..."
        php artisan migrate:fresh --force 2>/dev/null && echo "Migrations fresh complete." || echo "migrate:fresh failed, trying migrate --force..."
        # If fresh failed, try normal migrate as fallback
        if [ $? -ne 0 ]; then
            php artisan migrate --force 2>/dev/null && echo "Migrations complete." || echo "Migrations failed."
        fi
        # Seed after fresh migrate
        echo "Running seeders..."
        php artisan db:seed --force 2>/dev/null && echo "Seeding complete." || echo "Seeding failed, continuing..."
    else
        echo "Existing database detected ($USER_COUNT users). Running migrate --force..."
        php artisan migrate --force 2>/dev/null && echo "Migrations complete." || echo "Migrations failed, continuing..."
    fi

    php artisan config:cache 2>/dev/null || echo "config:cache skipped"
    php artisan route:cache 2>/dev/null || echo "route:cache skipped"
    php artisan view:cache 2>/dev/null || echo "view:cache skipped"
) &

# Start Apache in foreground (required for Render to detect the port)
exec apache2-foreground
