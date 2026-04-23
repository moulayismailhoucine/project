$content = @'
#!/bin/bash

cd /var/www/html

# Generate APP_KEY if not set
if [ -z "$APP_KEY" ] || [[ ! "$APP_KEY" == base64:* ]]; then
    echo "Generating Laravel APP_KEY..."
    export APP_KEY=$(php artisan key:generate --show 2>/dev/null)
    echo "APP_KEY generated: ${APP_KEY:0:20}..."
fi

echo "APP_KEY length: ${#APP_KEY}"
echo "DB_CONNECTION: $DB_CONNECTION"
echo "DATABASE_URL set: $(test -n "$DATABASE_URL" && echo 'yes' || echo 'no')"

# Fix permissions
chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache /var/www/html/public/build 2>/dev/null || true
chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache 2>/dev/null || true

# Wait for database
echo "Waiting for database..."
i=0
while [ $i -lt 30 ]; do
    php artisan tinker --execute="DB::connection()->getPdo();" 2>/dev/null && break
    echo "DB not ready, retrying in 2s... ($i/30)"
    sleep 2
    i=$((i + 1))
done

if [ $i -eq 30 ]; then
    echo "ERROR: Database not accessible after 60 seconds. Exiting."
    exit 1
fi

echo "Database is ready."

# Check if users table exists
HAS_USERS_TABLE=$(php artisan tinker --execute="echo Schema::hasTable('users') ? 'YES' : 'NO';" 2>/dev/null || echo "NO")
echo "Has users table: $HAS_USERS_TABLE"

if [ "$HAS_USERS_TABLE" != "YES" ]; then
    echo "Running migrate:fresh --force..."
    php artisan migrate:fresh --force && echo "Migration complete." || { echo "Migration failed. Exiting."; exit 1; }

    echo "Running seeders..."
    php artisan db:seed --force && echo "Seeding complete." || echo "Seeding failed, continuing..."
else
    echo "Tables exist. Running migrate --force..."
    php artisan migrate --force && echo "Migration complete." || echo "Migration failed, continuing..."
fi

php artisan config:cache 2>/dev/null || echo "config:cache skipped"
php artisan view:cache 2>/dev/null || echo "view:cache skipped"

echo "Starting Apache..."
exec apache2-foreground
'@

# Write with Unix line endings
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText("$PWD\entrypoint.sh", $content.Replace("`r`n", "`n"), $utf8NoBom)

Write-Host "Done. Verifying..."
Get-Content entrypoint.sh | Select-Object -Last 5