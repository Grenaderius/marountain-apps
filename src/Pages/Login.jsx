import React, { useState } from "react";
import "./Login.css";
import { Link, useNavigate } from "react-router-dom";

const Login = () => {
    const [email, setEmail] = useState("");
    const [password, setPassword] = useState("");
    const [errorMsg, setErrorMsg] = useState("");
    const navigate = useNavigate();
    const API_URL = import.meta.env.VITE_API_URL;

    const handleLogin = async () => {
        setErrorMsg("");

        try {
            const response = await fetch(`${API_URL}/login`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ email, password }),
            });

            const data = await response.json().catch(() => null);

            if (!response.ok) {
                setErrorMsg(data?.error || "Wrong email or password");
                return;
            }

            localStorage.setItem("user", JSON.stringify(data.user));
            navigate("/");
        } catch (error) {
            console.error("Login error:", error);
            setErrorMsg("Server error. Try again later.");
        }
    };

    return (
        <div className="login-page">
            <h1>Log in here!</h1>

            {errorMsg && <p className="login-error-msg">{errorMsg}</p>}

            <div className="login-inputs-div">
                <input
                    type="text"
                    className="login-login-input"
                    placeholder="Email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                />
                <input
                    type="password"
                    className="login-pass-input"
                    placeholder="Password"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                />
            </div>

            <div className="login-buttons-section">
                <button className="login-login-btn" onClick={handleLogin}>
                    Log in
                </button>
                <Link
                    to="/sign-up"
                    style={{ textDecoration: "none", color: "inherit" }}
                >
                    <button className="login-signup-btn">Sign up</button>
                </Link>
            </div>
        </div>
    );
};

export default Login;
