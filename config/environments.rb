configure :development do
	set :database, 'sqlite://database.db'
	set :show_exceptions, true
end	

configure :production do
 db = URI.parse(ENV['DATABASE_URL'] || 'postgres://nqkoacgkwkumsn:AzJeE2a38dJYxhErye64iJW6qx@ec2-54-83-205-164.compute-1.amazonaws.com:5432/d8oo8d4poj9b4c')

 ActiveRecord::Base.establish_connection(
   :adapter  => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
   :host     => db.host,
   :username => db.user,
   :password => db.password,
   :database => db.path[1..-1],
   :encoding => 'utf8'
 )
end