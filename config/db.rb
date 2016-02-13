# read the local configuration
@config = YAML.load_file('config/mongo.yml')

@environment = @config['environment']

@db_host = @config[@environment]['host']
@db_port = @config[@environment]['port']
@db_name = @config[@environment]['database']
p @db_name

# Configure the environment

# # Logger code: https://github.com/jnunemaker/mongomapper/blob/master/test/test_helper.rb
# log_dir = File.expand_path('../log/', __FILE__)
# FileUtils.mkdir_p(log_dir) unless File.exist?(log_dir)
# logger = Logger.new(log_dir + @db_log)
#
# LogBuddy.init(:logger => logger)

logger = Logger.new('test.log')
MongoMapper.connection = Mongo::Connection.new(@db_host, @db_port, :logger => logger)
MongoMapper.database = @db_name
MongoMapper.logger # would be equal to logger
MongoMapper.connection.connect