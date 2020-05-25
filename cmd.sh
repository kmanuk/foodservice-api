#!/bin/bash
set -e

send_notification () {
  curl -X POST -H 'Content-type: application/json' --data '{"text": "*FoodinHoods '$APP_TYPE' is starting on a '$RAILS_ENV'*\nCommit:\n'"$GIT_INFO"'", "username": "AWS ECS", "icon_emoji": ":computer:" }' https://hooks.slack.com/services/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
}

run_server () {
  bundle exec rails s -p 3000 -b '0.0.0.0'
}

run_sidekiq () {
  bundle exec sidekiq -C config/sidekiq.yml
}

if [ "$RAILS_ENV" = staging ]; then
  if [ "$APP_TYPE" = Sidekiq ]; then
    ln -sf /proc/1/fd/1 log/sidekiq.log
    send_notification
    run_sidekiq
  else
    ln -sf /proc/1/fd/1 log/staging.log
    send_notification
    run_server
  fi
elif [ "$RAILS_ENV" = production ]; then
  if [ "$APP_TYPE" = Sidekiq ]; then
    ln -sf /proc/1/fd/1 log/sidekiq.log
    send_notification
    run_sidekiq
  else
    ln -sf /proc/1/fd/1 log/production.log
    send_notification
    run_server
  fi
else
  run_server
fi
