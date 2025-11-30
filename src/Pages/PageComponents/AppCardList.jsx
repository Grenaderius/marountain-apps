import React, { useEffect, useState } from "react";
import AppCard from "./AppCard";

const AppCardsList = ({ filterBy }) => {
    const [items, setItems] = useState([]);
    const [error, setError] = useState(null);

    const API_URL = import.meta.env.VITE_API_URL;

    useEffect(() => {
        const fetchApps = async () => {
            try {
                const res = await fetch(`${API_URL}/apps`);
                if (!res.ok) throw new Error(`Server responded with ${res.status}`);

                const data = await res.json();
                const filtered =
                    filterBy === "games"
                        ? data.filter((i) => i.is_game === true)
                        : filterBy === "apps"
                            ? data.filter((i) => i.is_game === false)
                            : data;

                setItems(filtered);
            } catch (err) {
                setError("Could not load apps. Please try again later.");
            }
        };

        fetchApps();
    }, [API_URL, filterBy]);

    if (error) return <p className="error">{error}</p>;
    if (items.length === 0) return <p>Loading apps...</p>;

    return (
        <div style={{ display: "flex", flexWrap: "wrap", gap: "20px" }}>
            {items.map((item) => (
                <AppCard
                    key={item.id || 0}
                    id={item.id || 0}
                    name={item.name || "Not Found"}
                    rating={item.rating || "none"}
                    photo={item.photo || "/images/main-background.png"}
                />
            ))}
        </div>
    );
};

export default AppCardsList;