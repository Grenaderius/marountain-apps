require "net/http"
require "json"

class SentimentService
  API_URL = "https://api-inference.huggingface.co/models/distilbert-base-uncased-finetuned-sst-2-english"
  CONFIDENCE_THRESHOLD = 0.55

  def self.analyze(text)
    return "NEUTRAL" if text.blank?

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

    # Очікуваний формат:
    # [
    #   [
    #     { "label" => "NEGATIVE", "score" => 0.91 },
    #     { "label" => "POSITIVE", "score" => 0.09 }
    #   ]
    # ]
    best = data.first.max_by { |x| x["score"] }

    score = best["score"].to_f
    label = best["label"]

    return "NEUTRAL" if score < CONFIDENCE_THRESHOLD

    label
  rescue => e
    Rails.logger.error("Sentiment error: #{e.class} - #{e.message}")
    "NEUTRAL"
  end
end
