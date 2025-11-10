import React, { useState } from "react";
import "./AddApp.css";
import FileUpload from "./PageComponents/FileUpload";

const AddApp = () => {
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

    const CLOUD_NAME = "dwrbmcdsq";
    const UPLOAD_PRESET = "unsigned_upload";

    const API_URL = import.meta.env.VITE_API_URL; 

    const handleChange = (e) => {
        const { name, value, type, checked } = e.target;
        setForm((prev) => ({
            ...prev,
            [name]: type === "checkbox" ? checked : value,
        }));
    };

    const uploadToDrive = async (file) => {
        const formData = new FormData();
        formData.append("file", file);

        const res = await fetch(`${API_URL}/upload`, {
            method: "POST",
            body: formData,
        });

        if (!res.ok) throw new Error("Drive upload failed");

        const data = await res.json();
        return data.webContentLink; // або webViewLink
    };

    const handleSubmit = async () => {
        if (!file || !image) {
            alert("Please choose both APK file and image first!");
            return;
        }

        setLoading(true);

        try {
            // Завантажуємо у Google Drive
            const [fileUrl, imageUrl] = await Promise.all([
                uploadToDrive(file),
                uploadToDrive(image),
            ]);

            // Формуємо payload для бекенду
            const payload = {
                ...form,
                apk_url: fileUrl,
                icon_url: imageUrl,
            };

            const response = await fetch(`${API_URL}/apps`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify(payload),
            });

            if (!response.ok) throw new Error("Upload failed");

            alert("✅ App successfully added!");
            setForm({
                name: "",
                android_version: "",
                ram: "",
                cost: "",
                storage: "",
                description: "",
                is_game: false,
            });
            setFile(null);
            setImage(null);
        } catch (error) {
            alert("❌ Something went wrong: " + error.message);
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="add-app-page">
            <div className="add-app-bg"></div>
            <div className="add-app-overlay"></div>

            <div className="add-app-layout">
                <h1 className="add-app-header-text">Add your app to our store here!</h1>

                <div className="add-app-top-section">
                    <div className="add-app-add-apk-and-icon-section">
                        <FileUpload onFilesSelected={(apk, icon) => {
                            setFile(apk);
                            setImage(icon);
                        }} />
                    </div>

                    <div className="add-app-right-input-section">
                        <div className="add-app-right-input-inside-section">
                            <p>Name:</p>
                            <input
                                name="name"
                                value={form.name}
                                onChange={handleChange}
                                className="add-app-info-text-input"
                                placeholder="Write name of your app"
                            />

                            <p>Minimal Android version:</p>
                            <input
                                name="android_version"
                                value={form.android_version}
                                onChange={handleChange}
                                className="add-app-info-text-input"
                                placeholder="Write android version required"
                            />

                            <p>Minimal RAM:</p>
                            <input
                                name="ram"
                                value={form.ram}
                                onChange={handleChange}
                                className="add-app-info-text-input"
                                placeholder="Ram needed"
                            />

                            <p>Cost:</p>
                            <input
                                name="cost"
                                value={form.cost}
                                onChange={handleChange}
                                className="add-app-info-text-input"
                                placeholder="Cost"
                            />

                            <p>Max storage needed:</p>
                            <input
                                name="storage"
                                value={form.storage}
                                onChange={handleChange}
                                className="add-app-info-text-input"
                                placeholder="Max-size needed"
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
                        placeholder="Description"
                        maxLength="500"
                    />

                    <div className="add-app-checkbox-section">
                        <label>
                            <input
                                name="is_game"
                                type="checkbox"
                                checked={form.is_game}
                                onChange={handleChange}
                                className="add-app-checkbox"
                            />{" "}
                            Is a game
                        </label>
                    </div>

                    <button
                        className="add-app-apply-btn"
                        onClick={handleSubmit}
                        disabled={loading}
                    >
                        {loading ? "Uploading..." : "Add"}
                    </button>
                </div>
            </div>
        </div>
    );
};

export default AddApp;
