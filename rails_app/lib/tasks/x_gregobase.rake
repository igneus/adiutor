namespace :gregobase do
  desc 'load GregoBase database dump'
  task load_dump: [:environment] do
    uri = URI(ENV['GREGOBASE_DATABASE_URL'] || raise('db URI not specified'))
    mysql_connect = "mysql -u #{uri.user} --password=#{uri.password} -h #{uri.host}"
    dbname = uri.path.sub(/^\//, '')

    export_path = ENV['GREGOBASE_DUMP_PATH'] || raise('dump path not specified')

    sh "echo \"drop database if exists #{dbname}; create database #{dbname}; grant all on #{dbname}.* to 'db2user'@'%'\" | " + mysql_connect
    sh mysql_connect + " #{dbname} < #{export_path}"
  end

  desc 'import chants from the GregoBase database'
  task import: IMPORT_PREREQUISITES do
    Corpus.find_by_system_name!('gregobase').import!
  end
end
