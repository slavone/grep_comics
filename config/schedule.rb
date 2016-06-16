# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#

RBENV_INIT = %Q{export PATH=/home/#{ENV['USER']}/.rbenv/shims:/home/#{ENV['USER']}/.rbenv/bin:/usr/bin:$PATH; eval "$(rbenv init -)"; }

job_type :rbenv_rake, RBENV_INIT + "cd :path && :environment_variable=:environment bundle exec rake :task --silent :output}"
job_type :rbenv_runner, RBENV_INIT + "cd :path && bin/rails runner -e :environment ':task' :output}"

every 1.minute do
  rbenv_runner 'DiamondCrawler.new.test_cron', environment: 'development'
end
