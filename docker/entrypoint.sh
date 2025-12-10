#!/bin/bash
set -o errexit
set -o pipefail

postgres_ready() {
  # Wait for PostgreSQL to start up before doing anything.
  while ! (echo > /dev/tcp/"${DATABASE_HOST:-db}"/"${DATABASE_PORT:-5432}") >/dev/null 2>&1
  do
    echo "Waiting for PostgreSQL socket ${DATABASE_HOST:-db}:${DATABASE_PORT:-5432}..."
    sleep 1
  done
  echo "PostgreSQL socket ready ${DATABASE_HOST:-db}:${DATABASE_PORT:-5432}"
}

case "$1" in
sidekiq)
  postgres_ready
  # Run Sidekiq background job processor
  echo "** Executing: bundle exec sidekiq"
  bundle exec sidekiq
  ;;

web)
  postgres_ready
  # Create/Migrate DB
  echo "** Creating database if not exists..."
  bin/rails db:create
  echo "** Running database migrations..."
  bin/rails db:migrate
  echo "** Database setup complete"
  # Run server
  echo "** Executing: rails s -b 0.0.0.0"
  rm -f tmp/pids/server.pid && rails s -b 0.0.0.0
  ;;

*)
  echo "** Executing custom command: $@"
  exec "$@"
  ;;

esac
