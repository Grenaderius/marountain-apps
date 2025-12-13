require "net/http"
require "json"

class SentimentService
  API_URL = "https://api-inference.huggingface.co/models/distilbert-base-uncased-finetuned-sst-2-english"

  def self.analyze(text)
    uri = URI(API_URL)

    request = Net::HTTP::Post.new(uri)
    request["Authorization"] = "Bearer #{ENV['HF_TOKEN']}"
    request["Content-Type"] = "application/json"
    request.body = { inputs: text }.to_json

    response = Net::HTTP.start(
      uri.hostname,
      uri.port,
      use_ssl: true
    ) { |http| http.request(request) }

    data = JSON.parse(response.body)

    best = data[0].max_by { |x| x["score"] }

    if best["score"] < 0.6
      "NEUTRAL"
    else
      best["label"] 
    end
  rescue => e
    Rails.logger.error("Sentiment error: #{e.message}")
    "NEUTRAL"
  end
end
