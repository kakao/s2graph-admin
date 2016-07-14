app_path = File.expand_path(File.dirname(__FILE__) + '/..')
shared_path = File.expand_path(File.dirname(__FILE__) + '/../../../shared')
pids_dir = "#{shared_path}/pids"

require"#{app_path}/config/initializers/phase.rb"
unicorn_processes = (ENV['PHASE'] == "real" ? 8 : 4)
worker_processes unicorn_processes

# You can listen on a port or a socket. Listening on a socket is good in a
# production environment, but listening on a port can be useful for local
# debugging purposes.

listen shared_path + '/unicorn.sock', backlog: 2048, tcp_nopush: true, timeout: 15

# For development, you may want to listen on port 3000 so that you can make sure
# your unicorn.rb file is soundly configured.
listen(3000, backlog: 1024) if ENV['RAILS_ENV'] == 'development'

# After the timeout is exhausted, the unicorn worker will be killed and a new
# one brought up in its place. Adjust this to your application's needs. The
# default timeout is 60. Anything under 3 seconds won't work properly.
timeout 300

# Set the working directory of this unicorn instance.
working_directory app_path

# Set the location of the unicorn pid file. This should match what we put in the
# unicorn init script later.
pid "#{pids_dir}/unicorn.pid"

# You should define your stderr and stdout here. If you don't, stderr defaults
# to /dev/null and you'll lose any error logging when in daemon mode.
stderr_path app_path + '/log/unicorn.log'
stdout_path app_path + '/log/unicorn.log'

# Load the app up before forking.
preload_app true

# Garbage collection settings.
if GC.respond_to?(:copy_on_write_friendly=)
  GC.copy_on_write_friendly = true
end

# If using ActiveRecord, disconnect (from the database) before forking.
before_fork do |server, worker|
  defined?(ActiveRecord::Base) && ActiveRecord::Base.connection.disconnect!
  old_pid = "#{pids_dir}/unicorn.pid.oldbin"

  if File.exists?(old_pid)
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

# After forking, restore your ActiveRecord connection.
after_fork do |server, worker|
  defined?(ActiveRecord::Base) && ActiveRecord::Base.establish_connection
end
