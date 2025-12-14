require "net/http"
require "json"

class SentimentService
  API_URL = "https://router.huggingface.co/models/cardiffnlp/twitter-roberta-base-sentiment"

  def self.analyze(text)
    return "NEUTRAL" if text.blank?

    uri = URI(API_URL)
    request = Net::HTTP::Post.new(uri)
    request["Authorization"] = "Bearer #{ENV['HF_TOKEN']}"
    request["Content-Type"] = "application/json"
    request["Accept"] = "application/json"
    request.body = { inputs: text }.to_json

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    unless response.is_a?(Net::HTTPSuccess)
      Rails.logger.error("HF HTTP error #{response.code}: #{response.body}")
      return "NEUTRAL"
    end

    data = JSON.parse(response.body)

    # Формат router API: [{label:, score:}, ...]
    best = data.max_by { |x| x["score"].to_f }
    return "NEUTRAL" unless best && best["label"]

    best["label"].upcase # "POSITIVE", "NEGATIVE", "NEUTRAL"
  rescue => e
    Rails.logger.error("Sentiment exception: #{e.class} - #{e.message}")
    "NEUTRAL"
  end
end
