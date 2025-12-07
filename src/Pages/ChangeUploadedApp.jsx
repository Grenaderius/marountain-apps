import React, { useState, useEffect } from "react";
import { useParams, useNavigate } from "react-router-dom";
import "./AddApp.css";
import FileUpload from "./PageComponents/FileUpload";

const ChangeUploadedApp = () => {
    const { id } = useParams();
    const navigate = useNavigate();
    const [form, setForm] = useState({
        name: "",
        android_version: "",
        ram: "",
        cost: "",
        storage: "",
        description: "",
        is_game: false,
    });

    const [file, setFile] = useState(null);
    const [image, setImage] = useState(null);
    const [loading, setLoading] = useState(false);

    const token = localStorage.getItem("token");
    const API_URL = import.meta.env.VITE_API_URL;

    // Підвантаження даних додатку
    useEffect(() => {
        const fetchApp = async () => {
            try {
                const res = await fetch(`${API_URL}/apps/${id}`, {
                    headers: { Authorization: `Bearer ${token}` },
                });
                if (!res.ok) throw new Error("Failed to fetch app");
                const data = await res.json();
                setForm({
                    name: data.name || "",
                    android_version: data.android_min_version || "",
                    ram: data.ram_needed || "",
                    cost: data.cost || "",
                    storage: data.size || "",
                    description: data.description || "",
                    is_game: data.is_game || false,
                });
            } catch (err) {
                alert("❌ " + err.message);
            }
        };
        fetchApp();
    }, [id, token]);

    const handleChange = (e) => {
        const { name, value, type, checked } = e.target;
        setForm((prev) => ({
            ...prev,
            [name]: type === "checkbox" ? checked : value,
        }));
    };

    const handleSubmit = async () => {
        if (!token) {
            alert("❌ You need to log in first!");
            return;
        }

        setLoading(true);
        try {
            const formData = new FormData();

            if (file) formData.append("apk", file);
            if (image) formData.append("photo", image);

            formData.append("app[name]", form.name);
            formData.append("app[description]", form.description);
            formData.append("app[is_game]", form.is_game);
            formData.append("app[cost]", form.cost);
            formData.append("app[size]", form.storage);
            formData.append("app[android_min_version]", form.android_version);
            formData.append("app[ram_needed]", form.ram);

            const response = await fetch(`${API_URL}/apps/${id}`, {
                method: "PATCH",
                headers: {
                    Authorization: `Bearer ${token}`,
                },
                body: formData,
            });

            if (!response.ok) {
                const err = await response.json();
                throw new Error(err.error || "Update failed");
            }

            alert("✅ App successfully updated!");
            navigate("/my-apps");
        } catch (error) {
            alert("❌ Error: " + error.message);
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="add-app-page">
            <div className="add-app-bg"></div>
            <div className="add-app-overlay"></div>

            <div className="add-app-layout">
                <h1 className="add-app-header-text">
                    Edit your app here!
                </h1>

                <div className="add-app-top-section">
                    <div className="add-app-add-apk-and-icon-section">
                        <FileUpload
                            onFilesSelected={(apk, icon) => {
                                setFile(apk);
                                setImage(icon);
                            }}
                        />
                    </div>

                    <div className="add-app-right-input-section">
                        <div className="add-app-right-input-inside-section">
                            <p>Name:</p>
                            <input
                                name="name"
                                value={form.name}
                                onChange={handleChange}
                                className="add-app-info-text-input"
                            />

                            <p>Minimal Android version:</p>
                            <input
                                name="android_version"
                                value={form.android_version}
                                onChange={handleChange}
                                className="add-app-info-text-input"
                            />

                            <p>Minimal RAM:</p>
                            <input
                                name="ram"
                                value={form.ram}
                                onChange={handleChange}
                                className="add-app-info-text-input"
                            />

                            <p>Cost:</p>
                            <input
                                name="cost"
                                value={form.cost}
                                onChange={handleChange}
                                className="add-app-info-text-input"
                            />

                            <p>Max storage needed:</p>
                            <input
                                name="storage"
                                value={form.storage}
                                onChange={handleChange}
                                className="add-app-info-text-input"
                            />
                        </div>
                    </div>
                </div>

                <div className="add-app-bottom-section">
                    <p>Description:</p>
                    <textarea
                        name="description"
                        value={form.description}
                        onChange={handleChange}
                        className="add-app-description-text-input"
                        maxLength="500"
                    />

                    <div className="add-app-checkbox-section">
                        <label>
                            <input
                                name="is_game"
                                type="checkbox"
                                checked={form.is_game}
                                onChange={handleChange}
                            />
                            {" "}Is a game
                        </label>
                    </div>

                    <button
                        className="add-app-apply-btn"
                        onClick={handleSubmit}
                        disabled={loading}
                    >
                        {loading ? "Updating..." : "Update"}
                    </button>
                </div>
            </div>
        </div>
    );
};

export default ChangeUploadedApp;
