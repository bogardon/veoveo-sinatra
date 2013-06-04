configure :development do
  environment = ENV['RACK_ENV'] || 'development'
  db_config = YAML.load(ERB.new(File.read("./config/database.yml")).result)
  db = db_config[environment]
  ActiveRecord::Base.establish_connection(db)
end
