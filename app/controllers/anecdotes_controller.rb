class AnecdotesController < ApplicationController

    before_action { @results = [] }

    def example_2_a
        connection = ActiveRecord::Base.connection

        User.create(name: "Cat")
        User.create(name: "Dog")
        @results << User.all.map(&:name) # Result 0

        connection.execute("INSERT INTO users (name, created_at, updated_at) VALUES ('Mouse', '2023-10-09 16:48:52.506854', '2023-10-09 16:48:52.506854')")
        @results << User.all.map(&:name) # Result 1

        User.destroy_all
        @results << User.all.map(&:name) # Result 2

        render :example_results
    end

    def example_2_b
        ActiveRecord::Base.uncached do
            connection = ActiveRecord::Base.connection

            User.create(name: "Cat")
            User.create(name: "Dog")
            @results << User.all.map(&:name) # Result 0

            connection.execute("INSERT INTO users (name, created_at, updated_at) VALUES ('Mouse', '2023-10-09 16:48:52.506854', '2023-10-09 16:48:52.506854')")
            @results << User.all.map(&:name) # Result 1

            User.destroy_all
            @results << User.all.map(&:name) # Result 2
        end
        render :example_results
    end
end