Start Postgres
sudo service postgresql start


Connect to Postrgres
sudo sudo -u postgres psql

Create DB
create database "fantasyfooty";

RUN
rackup -p $PORT -o $IP 