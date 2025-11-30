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
    const [saving, setSaving] = useState(false);
    const [error, setError] = useState(null);

    const user = JSON.parse(localStorage.getItem("user") || "null");

    const findUserComment = (comments = []) =>
        user ? comments.find((c) => Number(c.user_id) === Number(user.id)) : null;

    const sortComments = (comments = []) => {
        if (!comments) return [];
        const userId = user?.id;
        return [...comments].sort((a, b) => {
            if (userId && Number(a.user_id) === Number(userId)) return -1;
            if (userId && Number(b.user_id) === Number(userId)) return 1;
            if (a.created_at && b.created_at) return new Date(b.created_at) - new Date(a.created_at);
            return Number(b.id) - Number(a.id);
        });
    };

    useEffect(() => {
        let canceled = false;
        const load = async () => {
            setLoading(true);
            setError(null);
            try {
                const res = await fetch(`${API_URL}/apps/${id}`);
                if (!res.ok) throw new Error(`Failed to load app: ${res.status}`);
                const data = await res.json();

                if (!canceled) {
                    // підв'язка локального user для власного коментаря
                    if (data.comments && user) {
                        data.comments = data.comments.map((c) =>
                            !c.user && Number(c.user_id) === Number(user.id)
                                ? { ...c, user }
                                : c
                        );
                    }

                    setApp({ ...data, comments: sortComments(data.comments || []) });

                    const myComment = findUserComment(data.comments || []);
                    if (myComment) {
                        setCommentText(myComment.comment || "");
                        setRating(myComment.rating ?? 5);
                    }
                }
            } catch (err) {
                if (!canceled) setError(err.message || "Error");
            } finally {
                if (!canceled) setLoading(false);
            }
        };
        load();
        return () => (canceled = true);
    }, [API_URL, id]);

    const upsertCommentInState = (comment) => {
        setApp((prev) => {
            if (!prev) return prev;
            const fixed = !comment.user && user ? { ...comment, user } : comment;
            const others = (prev.comments || []).filter((c) => Number(c.user_id) !== Number(fixed.user_id));
            return { ...prev, comments: sortComments([fixed, ...others]) };
        });
    };

    const sendComment = async () => {
        if (!user) return alert("You must be logged in!");
        if (!commentText.trim()) return alert("Write a comment first!");
        setSaving(true);
        try {
            const existing = findUserComment(app?.comments || []);
            const method = existing ? "PUT" : "POST";
            const url = existing ? `${API_URL}/comments/${existing.id}` : `${API_URL}/comments`;

            const res = await fetch(url, {
                method,
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({
                    comment: { app_id: id, user_id: user.id, comment: commentText, rating },
                }),
            });

            if (!res.ok) {
                const errBody = await res.json().catch(() => ({}));
                throw new Error(errBody.error || errBody.errors?.join?.(", ") || "Failed");
            }

            const data = await res.json();
            upsertCommentInState(data);
            setCommentText("");
            setRating(5);
        } catch (err) {
            alert(err.message || "Error saving comment");
        } finally {
            setSaving(false);
        }
    };

    const deleteComment = async (commentId) => {
        if (!user) return alert("You must be logged in!");
        if (!window.confirm("Are you sure you want to delete your review?")) return;

        try {
            const res = await fetch(`${API_URL}/comments/${commentId}`, {
                method: "DELETE",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ user_id: user.id }),
            });

            if (!res.ok) {
                const errBody = await res.json().catch(() => ({}));
                throw new Error(errBody.error || "Delete failed");
            }

            setApp((prev) => ({
                ...prev,
                comments: sortComments((prev.comments || []).filter((c) => Number(c.id) !== Number(commentId))),
            }));
            setCommentText("");
            setRating(5);
        } catch (err) {
            alert(err.message || "Cannot delete comment");
        }
    };

    if (loading) return <h1>Loading...</h1>;
    if (error) return <h1>Error: {error}</h1>;
    if (!app) return <h1>App not found</h1>;

    const averageRating =
        app.comments && app.comments.length > 0
            ? (app.comments.reduce((a, c) => a + (Number(c.rating) || 0), 0) / app.comments.length).toFixed(1)
            : "0";

    const myComment = findUserComment(app.comments || []);

    return (
        <div className="app-details-page">
            <div className="app-details-bg"></div>
            <div className="app-details-overlay"></div>

            <div className="app-details-layout">
                <h1 className="app-details-header">{app.name}</h1>

                <div className="app-details-top">
                    <img src={app.photo_path} className="app-details-icon" alt="App icon" />
                    <div className="app-details-info">
                        <p><span>Rating:</span> {averageRating} ★</p>
                        <p><span>Price:</span> {app.cost ? `${app.cost} USD` : "Free"}</p>
                        <p><span>Uploaded by:</span> {app.dev?.name || "Unknown"}</p>
                        <p><span>Minimal Android version:</span> {app.android_min_version}</p>
                        <p><span>Minimal RAM needed:</span> {app.ram_needed} GB</p>
                        <p><span>Max size needed:</span> {app.size} MB</p>
                    </div>
                </div>

                <div className="app-details-download-section">
                    {app.apk_path ? (
                        <a className="app-details-download" href={app.apk_path} target="_blank" rel="noreferrer">Download APK</a>
                    ) : (
                        <button className="app-details-download" disabled>No APK</button>
                    )}
                </div>

                <div className="app-details-description-section">
                    <h2>Description</h2>
                    <p>{app.description}</p>
                </div>

                <div className="app-details-comments-section">
                    <h2>Reviews</h2>

                    <div className="app-details-write-comment">
                        <textarea value={commentText} onChange={(e) => setCommentText(e.target.value)} placeholder="Write your feedback..." />
                        <select value={rating} onChange={(e) => setRating(Number(e.target.value))}>
                            {[5, 4, 3, 2, 1].map(r => <option key={r} value={r}>{r} ★</option>)}
                        </select>
                        <div style={{ display: "flex", marginTop: 8 }}>
                            <button onClick={sendComment} disabled={saving}>
                                {myComment ? (saving ? "Updating..." : "Update") : saving ? "Sending..." : "Send"}
                            </button>
                            {myComment && (
                                <button onClick={() => deleteComment(myComment.id)} className="delete-comment-btn" style={{ background: "#e53935", color: "#fff" }}>
                                    Delete
                                </button>
                            )}
                        </div>
                    </div>

                    <div className="app-details-comments-list">
                        {app.comments && app.comments.length > 0 ? (
                            app.comments.map(c => (
                                <div key={c.id} className="app-details-comment">
                                    <div className="comment-header">
                                        <p className="comment-author">User: {c.user?.email || "Anonymous"}</p>
                                        <p className="comment-rating">Rating: {c.rating} ★</p>
                                    </div>
                                    <p className="comment-text">{c.comment}</p>
                                    {user && Number(c.user_id) === Number(user.id) && (
                                        <div style={{ marginTop: 8 }}>
                                            <button onClick={() => deleteComment(c.id)} className="delete-comment-btn">Delete</button>
                                        </div>
                                    )}
                                </div>
                            ))
                        ) : (
                            <p>No reviews yet</p>
                        )}
                    </div>
                </div>
            </div>
        </div>
    );
};

export default AppDetails;
