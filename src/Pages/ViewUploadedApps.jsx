import React, { useEffect, useState } from "react";
import "./ViewUploadedApps.css";
import { useNavigate } from "react-router-dom";

const ViewUploadedApps = () => {
    const [apps, setApps] = useState([]);
    const [user, setUser] = useState(null);
    const navigate = useNavigate();
    const API_URL = import.meta.env.VITE_API_URL;

    useEffect(() => {
        const fetchUserAndApps = async () => {
            try {
                const userLocal = JSON.parse(localStorage.getItem("user"));

                if (!userLocal) {
                    console.error("User not found in localStorage");
                    return;
                }

                setUser(userLocal);

                const appsRes = await fetch(`${API_URL}/apps`, {
                    credentials: "include",
                });

                const appsData = await appsRes.json();

                const filtered = appsData.filter(app => app.dev_id === userLocal.id);
                setApps(filtered);

            } catch (error) {
                console.error(error);
            }
        };

        fetchUserAndApps();
    }, []);

    const handleEdit = (id) => {
        navigate(`/edit-app/${id}`);
    };

    const handleDelete = async (id) => {
        if (window.confirm("Ви впевнені, що хочете видалити цей додаток?")) {
            try {
                const response = await fetch(`${API_URL}/apps/${id}`, {
                    method: "DELETE",
                    credentials: "include",
                });
                if (response.ok) {
                    setApps((prev) => prev.filter((app) => app.id !== id));
                } else {
                    alert("Помилка при видаленні додатку");
                }
            } catch (error) {
                console.error(error);
            }
        }
    };

    const handleOpenApp = (id) => {
        navigate(`/apps/${id}`);
    };

    return (
        <div className="uploaded-apps-container">
            <h2>Мої завантажені додатки</h2>
            <div className="apps-grid">
                {apps.length > 0 ? (
                    apps.map((app) => (
                        <div className="app-card" key={app.id}>
                            <img
                                src={app.image_url || "/placeholder.png"}
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
                    <p>Ви ще не завантажили жодного додатку.</p>
                )}
            </div>
        </div>
    );
};

export default ViewUploadedApps;
