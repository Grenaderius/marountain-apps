import { useState, useEffect, useRef } from "react";
import { Link } from "react-router-dom";

import "./Header.css";

export default function Header() {
    const [open, setOpen] = useState(false);
    const dropdownRef = useRef(null);

    useEffect(() => {
        function handleClickOutside(event) {
            if (dropdownRef.current && !dropdownRef.current.contains(event.target)) {
                setOpen(false);
            }
        }

        document.addEventListener("mousedown", handleClickOutside);
        return () => {
            document.removeEventListener("mousedown", handleClickOutside);
        };
    }, []);

    return (
        <header className="header">
            <nav className="nav">
                <div className="logo">
                    <span className="logo-text">Marountain Apps</span>
                </div>

                <div className="nav-links">
                    <Link to="/games" className="nav-link">Games</Link>
                    <Link to="/apps" className="nav-link">Apps</Link>

                    <div className="dropdown" ref={dropdownRef}>
                        <button
                            className="dropdown-btn"
                            onClick={() => setOpen(!open)}
                        >
                            Account ▼
                        </button>
                        {open && (
                            <ul className="dropdown-list">
                                <Link to="/add-app" style={{ textDecoration: "none", color: "inherit" }}><li className="dropdown-item">Add app</li></Link>
                                <Link to="/my-apps" style={{ textDecoration: "none", color: "inherit" }}><li className="dropdown-item">View uploaded apps</li></Link>
                                <Link to="/purchased-apps" style={{ textDecoration: "none", color: "inherit" }}><li className="dropdown-item">View bought apps</li></Link>
                                {/*gap */}
                                <Link to="/" style={{ textDecoration: "none", color: "inherit" }}><li className="dropdown-item">login</li></Link>
                            </ul>
                        )}
                    </div>
                </div>
            </nav>
        </header>
    );
}
