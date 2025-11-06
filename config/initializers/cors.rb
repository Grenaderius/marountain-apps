Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'https://marountain-apps-2nd.vercel.app',
            'http://localhost:5173',
            'https://marountain-apps-2nd-h1d6htg4g-nazars-projects-ed8fd5f8.vercel.app'

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true
  end
end
