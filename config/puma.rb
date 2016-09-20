
# Windows can not run puma concurrently, so the default worker count must be changed
# from 2 to 0 while using windows.
worker_count = Gem.win_platform? ? 0 : 2
workers Integer(ENV['WEB_CONCURRENCY'] || worker_count)
threads_count = Integer(ENV['MAX_THREADS'] || 5)
threads threads_count, threads_count

preload_app!

rackup      DefaultRackup
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'development'

on_worker_boot do
  # Worker specific setup for Rails 4.1+
  # See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
  ActiveRecord::Base.establish_connection
end
