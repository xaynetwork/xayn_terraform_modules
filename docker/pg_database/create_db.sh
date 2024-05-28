#!/bin/bash
set -e

echo "Creating database ${PGDATABASE}"

psql -v ON_ERROR_STOP=1 --username "$PGUSER" --host "$PGHOST" --dbname "postgres" <<-EOF
    CREATE DATABASE $PGDATABASE;
EOF

echo "Database ${PGDATABASE} created successfully"
