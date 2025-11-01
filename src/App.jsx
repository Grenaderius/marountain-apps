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


export default function App() {

    return (

        <Router>
            <Header />
            <Routes>
                <Route path="/" element={<Games />} />
                <Route path="/apps" element={<Apps />} />
                <Route path="/add-app" element={<AddApp />} />
                <Route path="/my-apps" element={<ViewUploadedApps />} />

                <Route path="/login" element={<Login />} />
                <Route path="/sign-up" element={<SignUp />} />

            </Routes>
        </Router>
    );
}
