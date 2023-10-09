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
3. Request http://localhost:3000/ping ✅
4. Kill Database
5. Request http://localhost:3000/ping ✅

### Sad path
1. Start Rails
2. Request http://localhost:3000/ping ❌
3. Start Database
4. Request http://localhost:3000/ping ✅

### Why?
Rails wants to check for pending migrations on the first request requiring a connection.

    config.active_record.migration_error = :page_load

This is only on in development by default, no other options exist

## Anecdote 2

Rails has a query cache and executing the same query can return the same result. Sometimes unhelpfully.

### Reproduction

1. Try and predict what the code for example_2 will display
2. Be surprised http://localhost:3000/annecdotes/example_2_a
3. Try and guess what will happen when reloading the page
4. Possibly be wrong again

### Why?

Query Cache! ActiveRecord is smart and wont repeat a query if it thinks it doesn't need to. It's not always right and you need to know when to tell it to stop trying to be smart.

    ActiveRecord::Base.uncached do
      # I will not cache queries
    end

Try again with `uncached`: http://localhost:3000/annecdotes/example_2_b

The cache is at the connection pool level. You can turn it on/off, have a look inside anytime you like.

https://github.com/rails/rails/blob/main/activerecord/lib/active_record/connection_adapters/abstract/query_cache.rb