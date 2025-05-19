import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { buildPath } from './Path';
import dumbbellsImg from '../assets/dumbbells.jpg';

function Register() {
    const [firstName, setFirstName] = useState('');
    const [lastName, setLastName] = useState('');
    const [email, setEmail] = useState('');
    const [login, setLogin] = useState('');
    const [password, setPassword] = useState('');
    const [errors, setErrors] = useState<string[]>([]); // State to store errors
    const [message, setMessage] = useState('');
    const navigate = useNavigate();

    async function doRegister(event: React.FormEvent): Promise<void> {
        event.preventDefault();

        if(!firstName || !lastName || !email || !login || !password) {
            setErrors(['All fields are required.']);
            return;
        }
        const obj = { firstName, lastName, email, login, password };
        const js = JSON.stringify(obj);

        console.log("Registering with payload :", obj);
        console.log("Posting to:", buildPath('api/register'));
        try {
            const response = await fetch(buildPath('api/register'), {
                method: 'POST',
                body: js,
                headers: { 'Content-Type': 'application/json' },
            });

            const data = await response.json();

            if (response.status === 400) {
                // Display errors if registration fails
                setErrors(data.errors || []);
            } else if (response.status === 200) {
                // Clear errors and navigate on successful registration
                setErrors([]);
                setMessage('Registration successful!');
                navigate('/verification'); // Replace with your desired route
            } else {
                setMessage('An unexpected error occurred.');
            }
        } catch (err) {
            console.error(err);
            setMessage('An error occurred while registering.');
        }
    }

    return (
        <div
  className="min-h-screen bg-center bg-no-repeat bg-fixed relative flex flex-col items-center justify-start"
  style={{
    backgroundImage: `url(${dumbbellsImg})`,
    backgroundSize: '150px',
    backgroundRepeat: 'repeat',
  }}
>
  <div className="relative z-10 max-w-xl mx-auto bg-white bg-opacity-95 rounded-2xl shadow-2xl px-8 py-12 mb-20 mt-20 border border-gray-200 text-center">
    {/* Title + Slogan */}
    <h1 className="text-5xl md:text-6xl font-extrabold tracking-tight text-[#0f172a]">
      Fit Journey
    </h1>
    <p className="text-2xl md:text-3xl font-medium mt-3 italic text-[#0f172a] opacity-90">
      Track. Train. Transform.
    </p>

    {/* Register Form */}
    <h2 className="text-2xl font-bold text-[#0f172a] mt-10 mb-6">Register</h2>
    <form onSubmit={doRegister} className="space-y-4 text-left">
      <input
        type="text"
        placeholder="First Name"
        value={firstName}
        onChange={(e) => setFirstName(e.target.value)}
        className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#2563eb] transition"
      />
      <input
        type="text"
        placeholder="Last Name"
        value={lastName}
        onChange={(e) => setLastName(e.target.value)}
        className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#2563eb] transition"
      />
      <input
        type="email"
        placeholder="Email"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#2563eb] transition"
      />
      <input
        type="text"
        placeholder="Username"
        value={login}
        onChange={(e) => setLogin(e.target.value)}
        className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#2563eb] transition"
      />
      <input
        type="password"
        placeholder="Password"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
        className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#2563eb] transition"
      />

      <button
        type="submit"
        className="w-full bg-[#0f172a] text-white py-3 rounded-xl font-semibold hover:bg-[#2563eb] transition-all shadow-md hover:shadow-lg"
      >
        Register
      </button>
    </form>

    {errors.length > 0 && (
      <div className="mt-5 text-red-600 bg-red-100 p-3 rounded-lg text-sm">
        <h3 className="text-center font-semibold">Errors:</h3>
        <ul className="list-disc list-inside">
          {errors.map((error, index) => (
            <li key={index}>{error}</li>
          ))}
        </ul>
      </div>
    )}

    {message && errors.length === 0 && (
      <p className="text-center text-red-600 mt-4">{message}</p>
    )}

    <div className="text-center mt-6 text-sm">
      <p className="text-[#0f172a]">
        Already have an account?{' '}
        <button
          onClick={() => navigate('/login')}
          className="text-[#2563eb] underline hover:text-[#1e40af] transition"
        >
          Login
        </button>
      </p>
    </div>
  </div>
</div>

    );
}

export default Register;