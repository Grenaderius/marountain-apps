Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "https://marountain-apps-2nd-a5ezbx2xo-nazars-projects-ed8fd5f8.vercel.app", "http://localhost:5173"
    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true
  end
end
