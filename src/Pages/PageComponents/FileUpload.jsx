import React, { useState } from "react";
import "./FileUpload.css"; // підключаємо стилі

export default function FileBoxes() {
    const [file, setFile] = useState(null);
    const [image, setImage] = useState(null);

    const handleFileChange = (e) => {
        const selectedFile = e.target.files[0];
        if (selectedFile) setFile(selectedFile);
    };

    const handleImageChange = (e) => {
        const selectedImage = e.target.files[0];
        if (selectedImage) setImage(selectedImage);
    };

    return (
        <div className="upload-container">
            {/* 📄 Блок для файлу */}
            <div className="upload-box">
                <input
                    type="file"
                    accept=".apk"
                    id="fileInput"
                    onChange={handleFileChange}
                    className="hidden-input"
                />
                <label htmlFor="fileInput" className="upload-label">
                    {file ? (
                        <div className="file-preview">
                            <img
                                src="/file-icon.png"
                                alt="file icon"
                                className="file-icon"
                            />
                            <p>{file.name}</p>
                        </div>
                    ) : (
                        <span>Choose file(.apk)</span>
                    )}
                </label>
            </div>

            {/* 🖼️ Блок для фото */}
            <div className="upload-box">
                <input
                    type="file"
                    accept="image/*"
                    id="imageInput"
                    onChange={handleImageChange}
                    className="hidden-input"
                />
                <label htmlFor="imageInput" className="upload-label">
                    {image ? (
                        <img
                            src={URL.createObjectURL(image)}
                            alt="preview"
                            className="image-preview"
                        />
                    ) : (
                        <span>Choose a photo(250/250px)</span>
                    )}
                </label>
            </div>
        </div>
    );
}
