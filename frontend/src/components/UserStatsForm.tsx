import { useState } from 'react';
import{ useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { buildPath } from './Path';

const UserInfo = () => {
  const navigate = useNavigate();
  const [userId, setUserId] = useState(null);
  const [gender, setGender] = useState('');
  const [height, setHeight] = useState('');
  const [weight, setWeight] = useState('');
  const [age, setAge] = useState('');
  const [goal, setGoal] = useState('');

  const email = new URLSearchParams(window.location.search).get('email');

  // Fetch userId on page load
  useEffect(() => {
    const fetchUserId = async () => {
      try {
        const res = await fetch(`/api/get-user-id?email=${email}`);
        const data = await res.json();
        if (res.ok) {
          setUserId(data.userId);
        } else {
          console.error("Error fetching userId:", data.error);
        }
      } catch (err) {
        console.error("Fetch failed:", err);
      }
    };

    if (email) fetchUserId();
  }, [email]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!userId) {
      console.error('User ID not found');
      return;
    }

    if(!gender || !height || !weight || !age || !goal) {
      console.error('All fields are required');
      return;
    }

    const payload = {
      userId,
      gender,
      height: parseInt(height),
      weight: parseInt(weight),
      age: parseInt(age),
      goal
    };  

    console.log('Submitting payload:', payload);

    try {
      const response = await fetch(buildPath('api/user-info'), {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      });

      const data = await response.json();

      if (response.ok) {
        alert('User info submitted successfully');
        navigate('/');
      } else {
        console.error('Error submitting user info:', data.error);
      }
    } catch (err) {
      console.error('Request failed:', err);
    }
  };

  return (
    <div className="max-w-md mx-auto mt-10 p-6 bg-white shadow-md rounded-lg">
      <h1 className="text-3xl font-bold text-center mb-6 text-[#0f172a]">Tell Us About Yourself</h1>
      <form className="space-y-4">
        <input
          type="text"
          placeholder="Gender"
          value={gender}
          onChange={(e) => setGender(e.target.value)}
          className="w-full p-2 border rounded"
        />
        <input
          type="number"
          placeholder="Height (inches)"
          value={height}
          onChange={(e) => setHeight(e.target.value)}
          className="w-full p-2 border rounded"
        />
        <input
          type="number"
          placeholder="Weight (lbs)"
          value={weight}
          onChange={(e) => setWeight(e.target.value)}
          className="w-full p-2 border rounded"
        />
        <input
          type="number"
          placeholder="Age"
          value={age}
          onChange={(e) => setAge(e.target.value)}
          className="w-full p-2 border rounded"
        />
        <select
          value={goal}
          onChange={(e) => setGoal(e.target.value)}
          className="w-full p-2 border rounded"
        >
          <option value="">Select a goal</option>
          <option value="Lose weight">Lose weight</option>
          <option value="Gain weight">Gain weight</option>
          <option value="Maintain weight">Maintain weight</option>
        </select>
        <button
          type="button"
          onClick={handleSubmit}
          className="w-full mt-4 bg-[#0f172a] text-white py-2 rounded hover:bg-[#1e293b] transition"
        >
          Continue
        </button>
      </form>
    </div>
  );
};
export default UserInfo;