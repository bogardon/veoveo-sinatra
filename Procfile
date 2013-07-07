web: bundle exec rackup config.ru -p $PORT
worker: env TERM_CHILD=1 QUEUE=push bundle exec rake resque:work
