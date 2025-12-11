import React, { useEffect, useState } from "react";
import "./PurnchasedApps.css";

const PurchasedApps = () => {
    const [apps, setApps] = useState([]);
    const API_URL = import.meta.env.VITE_API_URL;

    const token = localStorage.getItem("token");

    useEffect(() => {
        const load = async () => {
            const res = await fetch(`${API_URL}/purchases/my`, {
                headers: {
                    Authorization: `Bearer ${token}`
                }
            });

            const data = await res.json();
            setApps(data);
        };

        load();
    }, []);

    return (
        <div className="uploaded-apps-container">
            <h2>Your Purchased Apps</h2>

            {apps.length === 0 ? (
                <p style={{ textAlign: "center", marginTop: 20 }}>
                    You haven't purchased any apps yet.
                </p>
            ) : (
                <div className="apps-grid">
                    {apps.map(app => (
                        <div key={app.id} className="app-card">
                            <img
                                src={app.photo_url}
                                alt={app.name}
                                className="app-image"
                            />

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
