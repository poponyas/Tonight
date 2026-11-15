#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CSV_FILE="$PROJECT_DIR/seeds/cities.csv"

: "${DATABASE_URL:?Set DATABASE_URL before running}"

if [[ ! -f "$CSV_FILE" ]]; then
    echo "Error: cities.csv not found"
    exit 1
fi

echo "Importing cities..."

psql "$DATABASE_URL" -v ON_ERROR_STOP=1 <<SQL
BEGIN;

CREATE TEMP TABLE cities_import (
    region TEXT,
    city TEXT,
    timezone TEXT
) ON COMMIT DROP;

\copy cities_import(region, city, timezone) FROM '$CSV_FILE' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')

INSERT INTO public.cities (region, city, timezone)
SELECT DISTINCT
    TRIM(region),
    TRIM(city),
    TRIM(timezone)
FROM cities_import
WHERE NULLIF(TRIM(region), '') IS NOT NULL
  AND NULLIF(TRIM(city), '') IS NOT NULL
  AND NULLIF(TRIM(timezone), '') IS NOT NULL
  AND NOT EXISTS (
      SELECT 1
      FROM public.cities c
      WHERE c.region = TRIM(cities_import.region)
        AND c.city = TRIM(cities_import.city)
  );

COMMIT;
SQL

echo "Cities imported successfully."
