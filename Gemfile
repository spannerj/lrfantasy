source 'https://rubygems.org'
#ruby '2.0.0'

gem 'activerecord'
gem 'sinatra'
gem "sinatra-activerecord"
gem "watir-webdriver"
gem 'phantomjs', :require => 'phantomjs/poltergeist'
gem 'poltergeist'
gem 'sinatra-flash'
gem 'sinatra-redirect-with-flash'
gem 'activerecord-postgres-array'

group :default, :development, :test do
	gem 'sqlite3'
end

group :production do
	gem 'pg'
end