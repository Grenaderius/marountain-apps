require "net/http"
require "json"

class SentimentService
  API_URL = "https://api-inference.huggingface.co/models/distilbert-base-uncased-finetuned-sst-2-english"
  CONFIDENCE_THRESHOLD = 0.55

  def self.analyze(text)
    return "NEUTRAL" if text.blank?

    Rails.logger.info("HF TOKEN PRESENT? #{ENV['HF_TOKEN'].present?}")

    uri = URI(API_URL)

    request = Net::HTTP::Post.new(uri)
    request["Authorization"] = "Bearer #{ENV['HF_TOKEN']}"
    request["Content-Type"] = "application/json"
    request.body = { inputs: text }.to_json

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    # ❗ важливо
    unless response.is_a?(Net::HTTPSuccess)
      Rails.logger.error("HF HTTP error #{response.code}: #{response.body}")
      return "NEUTRAL"
    end

    data = JSON.parse(response.body)

    # HF може повернути { "error": "..." }
    if data.is_a?(Hash) && data["error"]
      Rails.logger.error("HF API error: #{data['error']}")
      return "NEUTRAL"
    end

    # Очікувано: [[{label, score}, ...]]
    unless data.is_a?(Array) && data.first.is_a?(Array)
      Rails.logger.error("HF unexpected format: #{data.inspect}")
      return "NEUTRAL"
    end

    best = data.first.max_by { |x| x["score"].to_f }
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
