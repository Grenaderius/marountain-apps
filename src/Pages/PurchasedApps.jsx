import React, { useEffect, useState } from "react";
import { useSearchParams } from "react-router-dom";
import "./PurchasedApps.css";

const PurchasedApps = () => {
    const [apps, setApps] = useState([]);
    const [message, setMessage] = useState("");
    const API_URL = import.meta.env.VITE_API_URL;
    const token = localStorage.getItem("token");

    const [searchParams] = useSearchParams();
    const sessionId = searchParams.get("session_id");

    useEffect(() => {
        const load = async () => {
            if (sessionId) {
                setMessage("Purchase successful!");
            }

            try {
                const res = await fetch(`${API_URL}/purchases/my`, {
                    headers: {
                        Authorization: `Bearer ${token}`,
                    },
                });

                const data = await res.json();
                setApps(data);
            } catch (err) {
                console.error(err);
            }
        };

        load();
    }, [sessionId]);

    return (
        <div className="uploaded-apps-container">
            <h2>Your Purchased Apps</h2>

            {message && <p className="success-message">{message}</p>}

            {apps.length === 0 ? (
                <p style={{ textAlign: "center", marginTop: 20 }}>
                    You haven't purchased any apps yet.
                </p>
            ) : (
                <div className="apps-grid">
                    {apps.map((app) => (
                        <div key={app.id} className="app-card">
                            <img src={app.photo_url} alt={app.name} className="app-image" />

                            <div className="app-name">{app.name}</div>

                            <div className="app-actions">
                                <a
                                    href={app.apk_url}
                                    target="_blank"
                                    rel="noreferrer"
                                    className="download-btn"
                                >
                                    Download APK
                                </a>
                            </div>
                        </div>
                    ))}
                </div>
            )}
        </div>
    );
};

export default PurchasedApps;
