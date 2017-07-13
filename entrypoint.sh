#/bin/sh

if [ ! -z "$CONFIG_HOME" ]; then
    cp -f $CONFIG_HOME/* $APP_HOME/config
fi

if [ "$DB_SETUP" == "yes" ]; then
    echo ">>> db schema load"
    rake db:setup
    rake db:schema:load
fi

bundle exec rake secret

echo ">>> start admin!!"
rails server -p 3000 -b 0.0.0.0;
