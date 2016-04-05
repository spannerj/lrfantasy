#!/usr/bin/env bash

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd $dir

echo "Installing gem bundle..."
gem install bundler --no-rdoc --no-ri

echo "install postgres server"
sudo yum -y install gcc ruby-devel libxslt-devel libxml2-devel sqlite sqlite-devel libpqxx-devel
bundle config build.nokogiri --use-system-libraries
bundle config build.pg --with-pg-config=/usr/pgsql-9.3/bin/pg_config

bundle install

echo "rake the database"
gem install rake --no-rdoc --no-ri
rake db:migrate
