# set path to application                                                 
app_dir = "/var/www/grep_comics"                                          
shared_dir = "#{app_dir}/shared"                                          
working_directory = "#{app_dir}/current"                                  
pid "#{working_directory}/tmp/pids/unicorn.pid"                           
                                                                          
# Set unicorn options                                                     
worker_processes 2                                                        
timeout 30                                                                
                                                                          
# Set up socket location                                                  
listen "#{working_directory}/tmp/sockets/unicorn.sock", :backlog => 64    
                                                                          
# Logging                                                                 
stderr_path "#{shared_dir}/log/unicorn.stderr.log"                        
stdout_path "#{shared_dir}/log/unicorn.stdout.log"                        
                                                                          
# use correct Gemfile on restarts
before_exec do |server|
  ENV['BUNDLE_GEMFILE'] = "#{app_path}/current/Gemfile"
end

# preload
preload_app true

before_fork do |server, worker|
  # the following is highly recomended for Rails + "preload_app true"
  # as there's no need for the master process to hold a connection
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
  end

  # Before forking, kill the master process that belongs to the .oldbin PID.
  # This enables 0 downtime deploys.
  old_pid = "#{server.config[:pid]}.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server, worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
  end
end
