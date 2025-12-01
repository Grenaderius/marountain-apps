import { useState } from "react";
import "./ChatModal.css";

export default function ChatModal({ open, onClose }) {
  if (!open) return null;

  return (
    <div className="chat-modal-overlay">
      <div className="chat-modal">
        <button className="chat-close-btn" onClick={onClose}>✖</button>

        <h2>Gemini Assistant</h2>

        {/* Тут буде чат */}
        <iframe
          src="https://gemini.google.com/app"
          className="chat-iframe"
        />
      </div>
    </div>
  );
}
