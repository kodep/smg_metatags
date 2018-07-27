Eye.config do
  logger "/home/ubuntu/smg_metatags/shared/log/eye.log"
end

Eye.application :metatags do
  working_dir "/home/ubuntu/smg_metatags/current"
  trigger :flapping, :times => 10, :within => 1.minute
  env 'RACK_ENV' => 'production'

process :sinatra do
    daemonize true
    pid_file "/tmp/sinatra.pid"
    stdall "/home/ubuntu/smg_metatags/shared/log/sinatra.log"

    start_command "rvm use 2.3.0 do bundle exec ruby index.rb"
    stop_signals [:TERM, 5.seconds, :KILL]
    restart_command 'kill -9 {PID}'

    restart_grace 10.seconds

    check :cpu, :every => 30, :below => 80, :times => 3
    check :memory, :every => 30, :below => 100.megabytes, :times => [3,5]
  end
end
