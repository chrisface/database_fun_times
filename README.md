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

Query Cache! ActiveRecord is smart and wont repeat a query if it thinks it doesn't need to. It's not always right and you need to know when to tell it to stop trying to be smart. The cache is enabled around each request.

    ActiveRecord::Base.uncached do
      # I will not cache queries
    end

Try again with `uncached`: http://localhost:3000/annecdotes/example_2_b

The cache is at the connection pool level. You can turn it on/off, have a look inside anytime you like.

https://github.com/rails/rails/blob/main/activerecord/lib/active_record/connection_adapters/abstract/query_cache.rb

## Anecdote 3

A broken database connection stays broken unless you or Rails cleans the mess up.

### Reproduction

1. Open a rails console
2. Hit the database connection with a query `User.count` ✅
3. Kill the database
4. Hit the database connection with a query `User.count` ❌
5. Restart the database
6. Hit the database connection with a query `User.count` ❌
7. Ask the connection if it's alive `User.connection.active? # false`
8. Tell the connection to reconnect `User.connection.reconnect!`
9. Ask the connection if it's alive `User.connection.active? # true`
10. Hit the database connection with a query `User.count` ✅

### Why?

ActiveRecord provides a pool of connections to your database to use. To prevent things getting mixed up, a connection is checked out of the pool and used exclusively for the current thread until returned to the pool. If this connection breaks, the thread can't talk to the database until the connection is healed/you throw away the connection and get a new one.

The method `reconnect!` can be used to heal a connection but you you wont normally call this yourself.

Normall when a query fails mid request, an error is raised, the request is aborted with a 500 and the connection is returned to the pool where it will be discared/recovered later.

There are however scenarios where you maybe have a long running thread such as a hand-built worker where a connection failure will never recover unless you tell it to.

Rails wraps all of your web requests and jobs. You can do the same. It will ensure that you get a working database connection as well as some other useful concurrency helpers to allow for multi-threaded application code execution

    Rails.application.executor.wrap do
      # call application code here
      # I enable the query cache from before, surprise!
    end

    Rails.application.reloader.wrap do
      # call long running application code here
      # I don't enable the query cache from before, surprise!
    end

How postgres adapter checks for `active?` https://github.com/rails/rails/blob/main/activerecord/lib/active_record/connection_adapters/postgresql_adapter.rb#L345

Strongly recommend you read about these in detail before usage.

https://guides.rubyonrails.org/threading_and_code_execution.html

### Testing

How do we prove with a test that our database connections can self heal in a long running process?

The class `LongRunningTask` is a simple example with a working test