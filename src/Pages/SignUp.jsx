import React, { useState } from "react";
import "./SignUp.css";
import { Link, useNavigate } from "react-router-dom";

const SignUp = () => {
    const [email, setEmail] = useState("");
    const [pass, setPass] = useState("");
    const [repeatPass, setRepeatPass] = useState("");
    const [error, setError] = useState("");
    const navigate = useNavigate();

    const handleSignUp = async () => {
        if (pass !== repeatPass) {
            setError("Passwords do not match");
            return;
        }

        try {
            const response = await fetch("http://localhost:3000/users", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ user: { email, password: pass } }),
            });

            const data = await response.json();

            if (response.ok) {
                localStorage.setItem("user", JSON.stringify(data.user));
                navigate("/login");
            } else {
                setError(data.errors ? data.errors.join(", ") : "Registration failed");
            }
        } catch (err) {
            setError("Server error");
        }
    };

    return (
        <div className="login-page">
            <h1>Sign up here!</h1>

            {error && <p className="login-error-msg">{error}</p>}

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
                    placeholder="Pass"
                    value={pass}
                    onChange={(e) => setPass(e.target.value)}
                />
                <input
                    type="password"
                    className="login-pass-input"
                    placeholder="Repeat pass"
                    value={repeatPass}
                    onChange={(e) => setRepeatPass(e.target.value)}
                />
            </div>

            <div className="login-buttons-section">
                <Link to="/login" style={{ textDecoration: "none", color: "inherit" }}>
                    <button className="login-login-btn">Log in</button>
                </Link>
                <button className="login-signup-btn" onClick={handleSignUp}>
                    Sign up
                </button>
            </div>
        </div>
    );
};

export default SignUp;
