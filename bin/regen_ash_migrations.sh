#!/bin/bash
# https://hexdocs.pm/ash_postgres/migrations_and_tasks.html

# Get count of untracked migrations
N_MIGRATIONS=$(git ls-files --others priv/repo/migrations | wc -l)

# Rollback untracked migrations
echo "maybe do:"
echo "mix ecto.rollback -n $N_MIGRATIONS"

# Delete untracked migrations and snapshots
git ls-files --others priv/repo/migrations | xargs rm
git ls-files --others priv/resource_snapshots | xargs rm

# Regenerate migrations
mix ash_postgres.generate_migrations --name $1

# Run migrations if flag
if echo $* | grep -e "-m" -q
then
  mix ecto.migrate
fi
