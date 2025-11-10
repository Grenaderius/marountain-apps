import React, { useState } from "react";
import "./FileUpload.css";

export default function FileUpload({ onFilesSelected }) {
    const [file, setFile] = useState(null);
    const [image, setImage] = useState(null);

    const handleFileChange = (e) => {
        const f = e.target.files[0];
        setFile(f);
        onFilesSelected(f, image);
    };

    const handleImageChange = (e) => {  
        const img = e.target.files[0];
        setImage(img);
        onFilesSelected(file, img);
    };

    return (
        <div className="upload-container">
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
                            <img src="/file-icon.png" alt="file icon" className="file-icon" />
                            <p>{file.name}</p>
                        </div>
                    ) : (
                        <span>Choose file (.apk)</span>
                    )}
                </label>
            </div>

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
                        <span>Choose a photo (250×250px)</span>
                    )}
                </label>
            </div>
        </div>
    );
}
