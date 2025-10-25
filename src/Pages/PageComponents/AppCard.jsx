import React from "react";
import { useNavigate } from "react-router-dom";
import "./AppCard.css";

const AppCard = ({ id, name, rating, photo }) => {
    const navigate = useNavigate();

    const handleClick = () => {
        navigate(`/details/${id}`);
    };

    return (
        <div className="card" onClick={handleClick}>
            <div className="card-photo">
                <img src={photo || "/images/main-background.png"} alt={name} />
            </div>
            <div className="card-bottom">
                <span className="card-name">{name}</span>
                <span className="card-rating">★ {rating}</span>
            </div>
        </div>
    );
};

export default AppCard;
