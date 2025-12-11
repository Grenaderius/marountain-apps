import React, { useEffect, useState } from "react";
import "./ViewUploadedApps.css";
import { useNavigate } from "react-router-dom";

const ViewUploadedApps = () => {
    const [apps, setApps] = useState([]);
    const navigate = useNavigate();
    const API_URL = import.meta.env.VITE_API_URL;

    useEffect(() => {
        const fetchApps = async () => {
            try {
                const token = localStorage.getItem("token");

                const res = await fetch(`${API_URL}/apps/my`, {
                    method: "GET",
                    headers: {
                        "Authorization": `Bearer ${token}`,
                    },
                });

                if (!res.ok) throw new Error("Failed to fetch apps");

                const data = await res.json();
                setApps(data);
            } catch (error) {
                console.error("Error loading apps:", error);
            }
        };

        fetchApps();
    }, []);

    const handleEdit = (id) => {
        navigate(`/change-app/${id}`);
    };

    const handleDelete = async (id) => {
        if (!window.confirm("Are you shure you want to delete this app?")) return;

        try {
            const token = localStorage.getItem("token");

            const response = await fetch(`${API_URL}/apps/${id}`, {
                method: "DELETE",
                headers: {
                    "Authorization": `Bearer ${token}`,
                },
            });

            if (response.ok) {
                setApps((prev) => prev.filter((app) => app.id !== id));
            } else {
                alert("Delete eror");
            }
        } catch (error) {
            console.error("Delete error:", error);
        }
    };

    const handleOpenApp = (id) => {
        navigate(`/apps/${id}`);
    };

    return (
        <div className="uploaded-apps-container">
            <h2>Downloaded apps</h2>
            <div className="apps-grid">
                {apps.length > 0 ? (
                    apps.map((app) => (
                        <div className="app-card" key={app.id}>
                            <img
                                src={app.photo_url || "/placeholder.png"}
                                alt={app.name}
                                className="app-image"
                                onClick={() => handleOpenApp(app.id)}
                            />

                            <h3 className="app-name" onClick={() => handleOpenApp(app.id)}>
                                {app.name}
                            </h3>

                            <div className="app-rating">
                                ⭐ {app.rating ? app.rating.toFixed(1) : "—"}
                            </div>

                            <div className="app-actions">
                                <button className="edit-btn" onClick={() => handleEdit(app.id)}>
                                    Редагувати
                                </button>
                                <button className="delete-btn" onClick={() => handleDelete(app.id)}>
                                    Видалити
                                </button>
                            </div>
                        </div>
                    ))
                ) : (
                    <p>Додатків поки що немає.</p>
                )}
            </div>
        </div>
    );
};

export default ViewUploadedApps;
