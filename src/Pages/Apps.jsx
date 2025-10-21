import React from "react";
import SideBar from "../SideBar/SideBar";

const Apps = () => {
    return (
        <div className="flex flex-col h-screen">
            <div className="flex flex-1">
                <SideBar />
                <main className="flex-1 p-6 bg-gray-100">
                    <h1 className="text-2xl font-bold">Apps</h1>
                    <p className="mt-4">
                        Тут буде контент сторінки Apps.
                    </p>
                </main>
            </div>
        </div>
    );
};

export default Apps;
