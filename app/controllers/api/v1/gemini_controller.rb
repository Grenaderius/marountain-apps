require "google/generativeai"

class Api::GeminiController < ApplicationController
  protect_from_forgery with: :null_session

  def compatibility
    message = params[:message].to_s

    client = Google::GenerativeAI::Client.new(api_key: ENV["GEMINI_API_KEY"])
    model  = client.model("gemini-pro")

    prompt = <<~PROMPT
      Ти — помічник, що аналізує моделі смартфонів.

      Твій формат відповіді ЗАВЖДИ суворо JSON:

      {
        "response": "текст",
        "phone": {
          "model": "...",
          "storage": "...",
          "ram": "...",
          "android_version": "..."
        }
      }

      Якщо користувач ще нічого не ввів або це перше повідомлення —
      поверни:
      {
        "response": "Введіть модель свого телефону.",
        "phone": {
          "model": "",
          "storage": "",
          "ram": "",
          "android_version": ""
        }
      }

      Користувач написав:
      "#{message}"

      Знайди характеристики телефону, навіть якщо модель написана з помилками.
    PROMPT

    result = model.generate_content(prompt)
    output = result.output_text

    json = JSON.parse(output) rescue { error: "AI returned invalid JSON" }

    render json: json
  end
end