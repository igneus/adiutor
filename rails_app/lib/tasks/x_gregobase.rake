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

  desc 'export all GregoBase scores as gabc files grouped by source(book) and genre'
  task :export, [:path] => [:environment] do |t, args|
    raise 'path must be specified' if args[:path].blank?

    GregobaseExporter.call args[:path]

    `tar -czf "#{args[:path]}.tar.gz" #{args[:path]}`
  end
end
