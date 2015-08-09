Start Postgres
sudo service postgresql start


Connect to Postrgres
sudo sudo -u postgres psql

Create DB
create database "fantasyfooty";

RUN
rackup -p $PORT -o $IP 

git Commiting
git add .; git commit -am "ongoing"; git push origin

heroku logs
heroku logs --app protected-badlands-7136

connect to heroku db
heroku pg:psql --app protected-badlands-7136

heroku run rake db:migrate --app protected-badlands-7136