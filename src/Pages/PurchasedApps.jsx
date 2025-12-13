import React, { useEffect, useState } from "react";
import { useSearchParams } from "react-router-dom";
import { useNavigate } from "react-router-dom";
import "./PurnchasedApps.css";

const PurchasedApps = () => {
    const [apps, setApps] = useState([]);
    const [message] = useState("");
    const navigate = useNavigate();

    const API_URL = import.meta.env.VITE_API_URL;
    const token = localStorage.getItem("token");
    const [searchParams] = useSearchParams();

    useEffect(() => {
        const loadData = async () => {
            const success = searchParams.get("success");
            const appId = searchParams.get("app_id");

            if (success === "true" && appId && token) {
                try {
                    await fetch(`${API_URL}/purchases/create_after_payment`, {
                        method: "POST",
                        headers: {
                            "Content-Type": "application/json",
                            Authorization: `Bearer ${token}`,
                        },
                        body: JSON.stringify({
                            app_id: Number(appId),
                            payment_success: true
                        }),
                    });
                } catch (error) {
                    console.error("Error creating purchase:", error);
                }
            }

            try {
                const res = await fetch(`${API_URL}/purchases/my`, {
                    headers: {
                        Authorization: `Bearer ${token}`,
                    },
                });
                const data = await res.json();
                setApps(data);
            } catch (error) {
                console.error("Error loading purchased apps:", error);
            }
        };

        loadData();
    }, [API_URL, searchParams, token]);

    const handleOpenApp = (id) => {
        navigate(`/apps/${id}`);
    };

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

                            <div className="app-name" onClick={() => handleOpenApp(app.id)}>{app.name}</div>

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
