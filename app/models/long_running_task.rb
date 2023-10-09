class LongRunningTask

  def start
    while true
      safely_do_some_work
      sleep 1
    end
  end

  def safely_do_some_work
    Rails.application.reloader.wrap do
      do_some_work
    end
  end

  def do_some_work
    User.count
  end
end