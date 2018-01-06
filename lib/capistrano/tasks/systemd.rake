namespace :systemd do
  namespace :sidekiq do
    desc 'Stop sidekiq'
    task :stop do
      on roles(:app) do
        within "#{current_path}" do
          execute 'sudo systemctl stop grep_comics_sidekiq'
        end
      end
    end

    desc 'Start sidekiq'
    task :start do
      on roles(:app) do
        within "#{current_path}" do
          execute 'sudo systemctl start grep_comics_sidekiq'
        end
      end
    end

    desc 'Restart sidekiq'
    task :restart do
      on roles(:app) do
        within "#{current_path}" do
          execute 'sudo systemctl restart grep_comics_sidekiq'
        end
      end
    end
  end

  namespace :unicorn do
    desc 'Stop unicorn'
    task :stop do
      on roles(:app) do
        within "#{current_path}" do
          execute 'sudo systemctl stop grep_comics_app'
        end
      end
    end

    desc 'Start unicorn'
    task :start do
      on roles(:app) do
        within "#{current_path}" do
          execute 'sudo systemctl start grep_comics_app'
        end
      end
    end

    desc 'Restart unicorn'
    task :restart do
      on roles(:app) do
        within "#{current_path}" do
          execute 'sudo systemctl restart grep_comics_app'
        end
      end
    end
  end
end
