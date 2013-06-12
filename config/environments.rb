configure :development do
  environment = ENV['RACK_ENV'] || 'development'
  db_config = YAML.load(ERB.new(File.read("./config/database.yml")).result)
  db = db_config[environment]
  ActiveRecord::Base.establish_connection(db)

  s3_config = YAML.load(File.read("./config/s3.yml"))[environment]
  Paperclip::Attachment.default_options[:storage] = :s3
  Paperclip::Attachment.default_options[:s3_credentials] = s3_config
end
