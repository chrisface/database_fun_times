require 'rails_helper'

RSpec.describe LongRunningTask, disable_transactional_tests: true do

    subject(:worker) { described_class.new }

    describe "#do_some_work" do
      it 'does not continue to work after explosion' do
        expect { worker.do_some_work }.to_not raise_error
        terminate_postgres_connection
        expect { worker.do_some_work }.to raise_error(ActiveRecord::StatementInvalid)
        expect { worker.do_some_work }.to raise_error(ActiveRecord::StatementInvalid)
      end
    end

    describe "#safely_do_some_work" do
      it 'recovers after an explosion' do
        expect { worker.safely_do_some_work }.to_not raise_error
        terminate_postgres_connection
        # We have to blow up once
        expect { worker.safely_do_some_work }.to raise_error(ActiveRecord::StatementInvalid)
        # But the next time we don't
        expect { worker.safely_do_some_work }.to_not raise_error(ActiveRecord::StatementInvalid)
      end
    end

    # We need to terminate the connection in such a way that it's not handled gracefully by ActiveRecord
    # A nice way to do this is to ask postgres to kill the connection that we're currently using.
    # This wont interfere with other tests that may be running at the same time
    def terminate_postgres_connection
      ActiveRecord::Base.connection.exec_query("SELECT pg_terminate_backend(pg_backend_pid());")
    rescue StandardError
    end
  end