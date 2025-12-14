require "net/http"
require "json"

class SentimentService
  API_URL = "https://router.huggingface.co/models/distilbert-base-uncased-finetuned-sst-2-english"

  def self.analyze(text)
    return "NEUTRAL" if text.blank?

    uri = URI(API_URL)

    request = Net::HTTP::Post.new(uri)
    request["Authorization"] = "Bearer #{ENV['HF_TOKEN']}"
    request["Content-Type"]  = "application/json"
    request["Accept"]        = "application/json"
    request["User-Agent"]    = "Rails-Sentiment-Service"
    request.body = { inputs: text }.to_json

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    unless response.is_a?(Net::HTTPSuccess)
      Rails.logger.error("HF HTTP error #{response.code}: #{response.body}")
      return "NEUTRAL"
    end

    data = JSON.parse(response.body)

    # router повертає: [[{label, score}, ...]]
    predictions = data.first
    return "NEUTRAL" unless predictions.is_a?(Array)

    best = predictions.max_by { |x| x["score"].to_f }
    return "NEUTRAL" unless best

    best["label"] # "POSITIVE" або "NEGATIVE"
  rescue => e
    Rails.logger.error("Sentiment exception: #{e.class} - #{e.message}")
    "NEUTRAL"
  end
end
