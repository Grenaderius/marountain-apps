import React from "react";
import './AddApp.css';
import FileUpload from "./PageComponents/FileUpload";


const AddApp = () => {
    return (
        <div className="add-app-page">
            <div className="add-app-bg"></div>
            <div className="add-app-overlay"></div>

            <div className="add-app-layout">
                <h1 className="add-app-header-text">Add your app to our store here!</h1>

                <div className="add-app-top-section">
                    <div className="add-app-add-apk-and-icon-section">
                        <FileUpload />
                    </div>
                

                    <div className="add-app-right-input-section">
                        <div className="add-app-right-input-inside-section">
                            <p>Name:</p>
                            <input type="text" className="add-app-info-text-input" placeholder="Write name of your app" />

                            <p>Minimal Android version:</p>
                            <input type="text" className="add-app-info-text-input" placeholder="Write android version required" />

                            <p>Minimal RAM:</p>
                            <input type="text" className="add-app-info-text-input" placeholder="Ram needed" />

                            <p>Cost:</p>
                            <input type="text" className="add-app-info-text-input" placeholder="Cost" />

                            <p>Max storage needed:</p>
                            <input type="text" className="add-app-info-text-input" placeholder="Max-size needed" />
                        </div>
                    </div>
                </div>



                <div className="add-app-bottom-section">
                    <p >Description:</p>
                    <textarea type="text" className="add-app-description-text-input" placeholder="Description" maxLength="500" />

                    <div className="add-app-checkbox-section">
                        <label>
                            <input className="add-app-checkbox" type="checkbox" /> Is a game
                        </label>
                    </div>

                    <button className="add-app-apply-btn">Add</button>

                </div>
            </div>
        </div>
    );
};

export default AddApp;