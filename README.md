# An Anthologoy of Interesting ActiveRecord Anecdotes (AIAA)

# Setup

## Create user in database if you don't already have one
    psql -U postgres -c "CREATE USER `echo $USER` SUPERUSER;"

## Create the database
    rails db:setup

## Anecdote 1

If you have a database, you _need_ a working database connection to be able to make your first request to Rails. Even if the request you make does not does not require a call to the database (development only)

### Happy path
1. Start Database
2. Start Rails
3. Request /ping ✅
4. Kill Database
5. Request /ping ✅

### Sad path
1. Start Rails
2. Request /ping ❌
3. Start Database
4. Request /ping ✅

### Why?
Rails wants to check for pending migrations on the first request requiring a connection.

    config.active_record.migration_error = :page_load

This is only on in development by default, no other options exist
