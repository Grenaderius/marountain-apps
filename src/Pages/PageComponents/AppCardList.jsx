
import React, { useEffect, useState } from "react";
import AppCard from "./AppCard";

const AppCardsList = () => {
    const [items, setItems] = useState([]);

    useEffect(() => {
        // fetch from your backend that queries SQLite
        fetch("http://localhost:3000/apps")
            .then((res) => res.json())
            .then((data) => setItems(data));
    }, []);

    return (
        <div style={{ display: "flex", flexWrap: "wrap", gap: "20px" }}>
            {items && items.map((item) => (
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
