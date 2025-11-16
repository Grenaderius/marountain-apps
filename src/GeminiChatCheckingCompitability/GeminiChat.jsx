import { useState, useRef, useEffect } from "react";
import "./GeminiChat.css";

export default function GeminiChat({ onResult }) {
    const [messages, setMessages] = useState([
        { sender: "bot", text: "Введіть модель свого телефону." }
    ]);

    const [input, setInput] = useState("");
    const [loading, setLoading] = useState(false);
    const chatEndRef = useRef(null);
    const API_URL = import.meta.env.VITE_API_URL;

    useEffect(() => {
        const container = chatEndRef.current?.parentElement;
        if (container) {
            container.scrollTop = container.scrollHeight;
        }
    }, [messages]);

    const sendMessage = async () => {
        if (!input.trim()) return;

        const userMessage = input.trim();

        setMessages(prev => [...prev, { sender: "user", text: userMessage }]);
        setInput("");
        setLoading(true);

        try {
            const res = await fetch(`${API_URL}/gemini-compatibility`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ message: userMessage })
            });

            const data = await res.json();

            setMessages(prev => [...prev, { sender: "bot", text: data.response }]);

            if (data.phone) {
                const phoneText =
                    `Модель: ${data.phone.model || "—"}\n` +
                    `Памʼять: ${data.phone.storage || "—"}\n` +
                    `RAM: ${data.phone.ram || "—"}\n` +
                    `Android: ${data.phone.android_version || "—"}`;

                setMessages(prev => [...prev, { sender: "bot", text: phoneText }]);
            }

            if (onResult) onResult(data);

        } catch (err) {
            setMessages(prev => [
                ...prev,
                { sender: "bot", text: "Помилка з сервером. Спробуйте ще раз." }
            ]);
        }

        setLoading(false);
    };

    return (
        <div className="gemini-chat">
            <p>Compatibility Assistant</p>

            <div className="gemini-chat-messages">
                {messages.map((msg, i) => (
                    <div key={i} className={`msg ${msg.sender}`}>
                        {msg.text.split("\n").map((line, idx) => (
                            <div key={idx}>{line}</div>
                        ))}
                    </div>
                ))}

                {loading && <div className="msg bot">...</div>}

                <div ref={chatEndRef}></div>
            </div>

            <div className="gemini-chat-input">
                <input
                    value={input}
                    onChange={e => setInput(e.target.value)}
                    placeholder="Введіть повідомлення..."
                    onKeyDown={(e) => e.key === "Enter" && sendMessage()}
                />
                <button onClick={sendMessage} disabled={loading}>Send</button>
            </div>
        </div>
    );
}
