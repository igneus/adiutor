unless Rails.env.test?
  Rack::MiniProfiler.config.position = 'bottom-left'
end
