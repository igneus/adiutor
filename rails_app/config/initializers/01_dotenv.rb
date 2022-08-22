if Rails.env.development? || Rails.env.test?
  # .env in a non-standard location, as it's shared by multiple apps
  Dotenv.load Rails.root.join('..', '.env')
end
