import React, { useEffect, useState } from "react";
import "./AppDetails.css";
import { useParams } from "react-router-dom";

const AppDetails = () => {
    const { id } = useParams();
    const API_URL = import.meta.env.VITE_API_URL;

    const [app, setApp] = useState(null);
    const [loading, setLoading] = useState(true);
    const [commentText, setCommentText] = useState("");
    const [rating, setRating] = useState(5);

    useEffect(() => {
        fetch(`${API_URL}/apps/${id}`)
            .then(res => res.json())
            .then(data => {
                setApp(data);
                setLoading(false);
            });
    }, [id]);

    const sendComment = async () => {
        if (!commentText.trim()) return alert("Write comment first!");

        const res = await fetch(`${API_URL}/comments`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                app_id: id,
                user_id: 1, // тимчасово, замінити після авторизації
                comment: commentText,
                rating
            })
        });

        const data = await res.json();

        // додаємо новий коментар з імʼям користувача
        setApp(prev => ({
            ...prev,
            comments: [...prev.comments, data]
        }));

        setCommentText("");
        setRating(5);
    };

    if (loading) return <h1>Loading...</h1>;

    return (
        <div className="app-details-page">
            <div className="app-details-bg"></div>
            <div className="app-details-overlay"></div>

            <div className="app-details-layout">
                <h1 className="app-details-header">{app.name}</h1>

                <div className="app-details-top">
                    <img src={app.photo_path} className="app-details-icon" />

                    <div className="app-details-info">
                        {/* Рейтинг */}
                        <p>
                            <span>Rating:</span>{" "}
                            {app.comments.length > 0
                                ? (
                                    app.comments.reduce((a, c) => a + c.rating, 0) /
                                    app.comments.length
                                ).toFixed(1)
                                : "0"}{" "}
                            ★
                        </p>

                        {/* Ціна */}
                        <p><span>Price:</span> {app.cost ? `${app.cost} USD` : "Free"}</p>

                        {/* Автор додатку */}
                        <p><span>Uploaded by:</span> {app.dev?.name || "Unknown"}</p>

                        <p><span>Minimal Android version:</span> {app.android_min_version}</p>
                        <p><span>Minimal RAM needed:</span> {app.ram_needed} GB</p>
                        <p><span>Max size needed:</span> {app.size} MB</p>

                        <a className="app-details-download" href={app.apk_path} target="_blank">
                            Download APK
                        </a>
                    </div>
                </div>

                <div className="app-details-description-section">
                    <h2>Description</h2>
                    <p>{app.description}</p>
                </div>

                <div className="app-details-comments-section">
                    <h2>Reviews</h2>

                    {/* Написати коментар */}
                    <div className="app-details-write-comment">
                        <textarea
                            value={commentText}
                            onChange={e => setCommentText(e.target.value)}
                            placeholder="Write your feedback..."
                        />

                        <select value={rating} onChange={e => setRating(Number(e.target.value))}>
                            {[5, 4, 3, 2, 1].map(r => (
                                <option key={r} value={r}>{r} ★</option>
                            ))}
                        </select>

                        <button onClick={sendComment}>Send</button>
                    </div>

                    {/* Відображення коментарів */}
                    <div className="app-details-comments-list">
                        {app.comments.map(c => (
                            <div key={c.id} className="app-details-comment">
                                <p className="comment-rating">{c.rating} ★</p>

                                {/* Імʼя автора коментаря */}
                                <p className="comment-author">
                                    {c.user?.name || "Anonymous"}
                                </p>

                                <p className="comment-text">{c.comment}</p>
                            </div>
                        ))}
                    </div>
                </div>
            </div>
        </div>
    );
};

export default AppDetails;
