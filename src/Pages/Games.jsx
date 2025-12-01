import React from "react";
import SideBar from "../SideBar/SideBar";
import "./Games.css";
import AppCardsList from "./PageComponents/AppCardList";

const Games = () => {
    return (
        <div className="games-page">
            <div className="games-bg" />
            <div className="games-overlay" />

            <div className="games-layout">
                <SideBar />
                <main className="games-content">
                    <h1 className="text-3xl font-bold"></h1>
                    <p className="mt-4">
                    </p>
                    <AppCardsList filterBy="games" />
                </main>
            </div>
        </div>
    );
};

export default Games;
