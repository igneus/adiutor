namespace :dotenv do
  dotenv_path = Rails.root.join('..', '.env')
  template_path = dotenv_path.to_s + '.template'

  file template_path => [dotenv_path] do
    File.write(
      template_path,
      File.read(dotenv_path)
        .gsub(/^([A-Z0-9_]+=).*$/, '\1')
    )
  end

  desc 're-generate .env.template'
  task :refresh_template => [template_path]
end
