import { BrowserRouter as Router, Routes, Route, Link } from "react-router-dom";

//components
import Header from "./Navigation/Header";

//pages
import Apps from "./Pages/Apps";
import Games from "./Pages/Games";
import AddApp from "./Pages/AddApp";
import Login from "./Pages/Login";
import SignUp from "./Pages/SignUp";
import ViewUploadedApps from "./Pages/ViewUploadedApps";
import AppDetails from "./Pages/AppDetails";
import ChangeUploadedApp from "./Pages/ChangeUploadedApp";
import PurchasedApps from "./Pages/PurchasedApps";

export default function App() {

    return (

        <Router>
            <Header />
            <Routes>
                <Route path="/" element={<Login />} />
                <Route path="/apps" element={<Apps />} />
                <Route path="/add-app" element={<AddApp />} />
                <Route path="/my-apps" element={<ViewUploadedApps />} />
                <Route path="/apps/:id" element={<AppDetails />} />
                <Route path="/change-app/:id" element={<ChangeUploadedApp />} />
                <Route path="/games" element={<Games />} />
                <Route path="/payment-success" element={<PurchasedApps />} />

                <Route path="/sign-up" element={<SignUp />} />
            </Routes>
        </Router>
    );
}
