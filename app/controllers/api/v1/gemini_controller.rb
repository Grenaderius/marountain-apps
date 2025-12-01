require "gemini-ai"

class Api::V1::GeminiController < ApplicationController

  def compatibility
    message = params[:message].to_s.strip

    client = Gemini.new(
      api_key: ENV["GEMINI_API_KEY"]
    )

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

    # ✔ Правильний виклик Gemini (без drive upload!)
    raw = client.generate(
      model: "gemini-1.5-flash",
      contents: [
        { role: "user", parts: [{ text: prompt }] }
      ]
    )

    text = raw.dig("candidates", 0, "content", "parts", 0, "text") rescue ""

    parsed =
      begin
        JSON.parse(text)
      rescue
        { error: "AI returned invalid JSON", raw: text }
      end

    render json: parsed
  end
end
