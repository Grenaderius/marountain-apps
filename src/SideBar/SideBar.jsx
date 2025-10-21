import { useState, useRef } from "react";
import "./SideBar.css";

export default function Sidebar() {
  const [dropdownOpen, setDropdownOpen] = useState(false);
  const dropdownRef = useRef(null);
  const user = JSON.parse(localStorage.getItem("user"));

  return (
    <aside className="sidebar">
      <h3>Filters</h3>

          <div className="sidebar-filter-section">
              <div className="sidebar-checkbox-section">
                  <label>
                      <input className="sidebar-checkbox" type="checkbox" /> Online
                  </label>
                  <label>
                      <input className="sidebar-checkbox" type="checkbox" /> Offline
                  </label>
                  <label>
                      <input className="sidebar-checkbox" type="checkbox" /> Free
                  </label>
              </div>
      </div>

          <div className="sidebar-filter-section" ref={dropdownRef}>
              <button className="sidebar-dropdown-btn" onClick={() => setDropdownOpen(!dropdownOpen)}>
          Newest ▼
        </button>
        {dropdownOpen && (
          <ul className="sidebar-dropdown-list">
            <li className="sidebar-dropdown-item">Oldest</li>
            <li className="sidebar-dropdown-item">dafda</li>
            <li className="sidebar-dropdown-item">Option 3</li>
          </ul>
        )}
      </div>


          <div className="sidebar-filter-section">
              <button className="sidebar-check-compitability-btn">Check compatibility</button>
          </div>

          <div className="sidebar-comp-checkbox">
              <label>
                  <input className="sidebar-checkbox" type="checkbox" /> Compatible
              </label>
           </div>

          <div className="sidebar-filter-section">
              <button className="sidebar-apply-btn">Apply</button>
              <p className="sidebar-apply-btn-text">Changes has been applied</p>
          </div>

          <p className="sidebar-user-email">User: {user ? user.email : "Not logged in"}</p>
    </aside>
  );
}
