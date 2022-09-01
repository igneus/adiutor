# takes care of CORS headers and pre-flight requests
Rails.application.config.middleware.insert_before 0, Rack::Cors, debug: true do
  allow do
    origins '*'
    resource '/api/eantifonar/*', headers: :any, methods: [:get, :post, :patch, :put, :options]
  end
end
