require "net/http"
require "json"

class SentimentService
  API_URL = "https://router.huggingface.co/models/distilbert-base-uncased-finetuned-sst-2-english"
  CONFIDENCE_THRESHOLD = 0.55

  def self.analyze(text)
    return "NEUTRAL" if text.blank?

    uri = URI(API_URL)

    request = Net::HTTP::Post.new(uri)
    request["Authorization"] = "Bearer #{ENV['HF_TOKEN']}"
    request["Content-Type"] = "application/json"
    request.body = { inputs: text }.to_json

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    content_type = response["content-type"].to_s

    unless response.is_a?(Net::HTTPSuccess)
      Rails.logger.error("HF HTTP error #{response.code}: #{response.body}")
      return "NEUTRAL"
    end

    unless content_type.include?("application/json")
      Rails.logger.error("HF non-JSON response: #{response.body}")
      return "NEUTRAL"
    end

    data = JSON.parse(response.body)

    if data.is_a?(Hash) && data["error"]
      Rails.logger.error("HF API error: #{data['error']}")
      return "NEUTRAL"
    end

    predictions = data.first
    return "NEUTRAL" unless predictions.is_a?(Array)

    best = predictions.max_by { |x| x["score"].to_f }
    return "NEUTRAL" if best.nil?
    return "NEUTRAL" if best["score"].to_f < CONFIDENCE_THRESHOLD

    best["label"] # POSITIVE / NEGATIVE
  rescue JSON::ParserError => e
    Rails.logger.error("HF JSON parse error: #{e.message}")
    "NEUTRAL"
  rescue => e
    Rails.logger.error("Sentiment exception: #{e.class} - #{e.message}")
    "NEUTRAL"
  end
end
