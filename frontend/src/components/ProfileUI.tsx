import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import IconUI from "./IconsUI";
import { buildPath } from "./Path";
import profileBg from "../assets/profile.jpg";

function ProfileUI() {
  const [formData, setFormData] = useState({
    login: "",
    weight: "",
    height: "",
    age: "",
    goal: "",
  });
  const [editingField, setEditingField] = useState<string | null>(null);
  const [email, setEmail] = useState<string | null>(null);
  const navigate = useNavigate();

  const userData = localStorage.getItem("user_data");
  const user = userData ? JSON.parse(userData) : null;
  const userId = user?.id;

  useEffect(() => {
    if (!userId) return;
    if (user?.email) setEmail(user.email);

    const fetchProfile = async () => {
      try {
        const response = await fetch(buildPath(`api/get-profile?userId=${userId}`));
        const data = await response.json();

        if (!response.ok) throw new Error(data.error || "Failed to fetch profile");

        setFormData({
          login: data.login || "",
          weight: data.weight?.toString() || "",
          height: data.height?.toString() || "",
          age: data.age?.toString() || "",
          goal: data.goal || "",
        });
      } catch (err) {
        console.error("Failed to fetch profile:", err);
      }
    };

    fetchProfile();
  }, [userId]);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
  };

  const handleSave = async (field: string) => {
    setEditingField(null);
    try {
      const res = await fetch(buildPath("api/update-user-stats"), {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ userId, [field]: formData[field as keyof typeof formData] }),
      });

      const data = await res.json();
      if (!res.ok) throw new Error(data.error || "Failed to update");

      console.log("Updated:", field);
    } catch (err) {
      console.error("Save error:", err);
    }
  };

  const handleLogout = async () => {
    try {
      await fetch(buildPath("api/logout"), { method: "POST" });
    } catch (err) {
      console.error("Logout API call failed:", err);
    } finally {
      localStorage.removeItem("token_data");
      localStorage.removeItem("user_data");
      navigate("/login");
    }
  };

  const handleDeleteAccount = async () => {
    const userLogin = user?.login;
    if (!userLogin) {
      alert("No user is logged in.");
      return;
    }

    const confirmDelete = window.confirm(
      `Are you sure you want to delete the account for "${userLogin}"? This action cannot be undone.`
    );

    if (!confirmDelete) return;

    try {
      const token = localStorage.getItem("token_data");
      if (!token) {
        alert("You are not logged in.");
        return;
      }

      const res = await fetch(buildPath("api/delete"), {
        method: "DELETE",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
      });

      if (res.ok) {
        alert("Account deleted successfully.");
        localStorage.clear();
        navigate("/register");
      } else {
        const errData = await res.json().catch(() => null);
        const errMsg = errData?.error || "An unexpected error occurred.";
        alert(`Failed to delete account: ${errMsg}`);
      }
    } catch (err) {
      console.error("Error deleting account:", err);
      alert("An error occurred while deleting your account.");
    }
  };

  const handleRequestPasswordReset = async () => {
    if (!email) {
      alert("No email associated with this account.");
      return;
    }

    try {
      const res = await fetch(buildPath("api/request-password-reset"), {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email }),
      });

      const data = await res.json();
      if (!res.ok) throw new Error(data.error || "Failed to send password reset email");

      alert("Password reset email sent. Please check your inbox.");
    } catch (err) {
      console.error("Password reset request error:", err);
      alert("Failed to send password reset email. Please try again.");
    }
  };

  return (
    <div
      className="min-h-screen bg-cover bg-center bg-fixed flex flex-col"
      style={{
        backgroundImage: `url(${profileBg})`,
      }}
    >
      <IconUI />
    
      <div className="flex flex-col items-center justify-start mt-24 px-6">
      <h1 className="text-4xl font-bold text-[#0f172a] mb-8">👤 Profile</h1>

    
      <div className="bg-white border-2 border-[#0f172a] shadow-lg rounded-xl p-8 w-full max-w-md space-y-6">
          {/* Username (read-only) */}
          <div className="flex flex-col">
            <label className="text-sm font-medium text-black mb-1">Username</label>
            <div className="bg-gray-100 px-4 py-2 rounded">
              <span className="text-black">{formData.login}</span>
            </div>
          </div>
    
          {/* Editable Fields */}
          {["weight", "height", "age"].map((field) => (
            <div key={field} className="flex flex-col">
              <label className="text-sm font-medium text-black mb-1">
                {field.charAt(0).toUpperCase() + field.slice(1)}
              </label>
              {editingField === field ? (
                <>
                  <input
                    type="number"
                    name={field}
                    value={formData[field as keyof typeof formData]}
                    onChange={handleChange}
                    className="border px-4 py-2 rounded mb-2"
                  />
                  <button
                    onClick={() => handleSave(field)}
                    className="text-sm text-white bg-green-500 hover:bg-green-600 px-3 py-1 rounded w-fit"
                  >
                    Save
                  </button>
                </>
              ) : (
                <div className="flex justify-between items-center bg-gray-100 px-4 py-2 rounded">
                  <span className="text-black">{formData[field as keyof typeof formData]}</span>
                  <button
                    onClick={() => setEditingField(field)}
                    className="text-blue-500 hover:underline text-sm"
                  >
                    Edit
                  </button>
                </div>
              )}
            </div>
          ))}
    
          {/* Goal Dropdown */}
          <div className="flex flex-col">
            <label className="text-sm font-medium text-black mb-1">Goal</label>
            {editingField === "goal" ? (
              <>
                <select
                  name="goal"
                  value={formData.goal}
                  onChange={handleChange}
                  className="border px-4 py-2 rounded mb-2"
                >
                  <option value="">Select a goal</option>
                  <option value="Lose weight">Lose weight</option>
                  <option value="Build muscle">Build muscle</option>
                  <option value="Maintain weight">Maintain weight</option>
                </select>
                <button
                  onClick={() => handleSave("goal")}
                  className="text-sm text-white bg-green-500 hover:bg-green-600 px-3 py-1 rounded w-fit"
                >
                  Save
                </button>
              </>
            ) : (
              <div className="flex justify-between items-center bg-gray-100 px-4 py-2 rounded">
                <span className="text-black">{formData.goal}</span>
                <button
                  onClick={() => setEditingField("goal")}
                  className="text-blue-500 hover:underline text-sm"
                >
                  Edit
                </button>
              </div>
            )}
          </div>
    
          {/* Change Password Button */}
          <div className="pt-4 border-t mt-6">
            <button
              onClick={handleRequestPasswordReset}
              className="w-full py-2 bg-yellow-500 hover:bg-yellow-600 text-white font-semibold rounded"
            >
              Change Password
            </button>
          </div>
    
          {/* Logout and Delete Buttons Side-by-Side */}
          <div className="pt-4 border-t mt-6">
            <div className="flex justify-between gap-4">
              <button
                onClick={handleLogout}
                className="w-1/2 py-2 bg-blue-500 hover:bg-blue-600 text-white font-semibold rounded"
              >
                Log Out
              </button>
              <button
                onClick={handleDeleteAccount}
                className="w-1/2 py-2 bg-red-500 hover:bg-red-600 text-white font-semibold rounded"
              >
                Delete Account
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
    

  );
}

export default ProfileUI;
