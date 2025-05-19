import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { buildPath } from './Path';
import dumbbellsImg from '../assets/dumbbells.jpg';
import FitJourneyLogo from "../assets/FitJourneyLogo.png";

function Login() {
  const [loginName, setLoginName] = useState('');
  const [loginPassword, setPassword] = useState('');
  const [message, setMessage] = useState('');
  const [errors, setErrors] = useState<string[]>([]); // State to store errors
  const navigate = useNavigate();

  async function doLogin(event: React.FormEvent): Promise<void> {
    event.preventDefault();
    const obj = { login: loginName, password: loginPassword };
    const js = JSON.stringify(obj);

    try {
      console.log("Making request to:", buildPath('api/login'));

      const response = await fetch(buildPath('api/login'), {
        method: 'POST',
        body: js,
        headers: {
          'Content-Type': 'application/json',
        },
      });

      const data = await response.json();

      if (response.ok) {
        // Save the token and user data in localStorage
        localStorage.setItem('token_data', data.token);
        localStorage.setItem('user_data', JSON.stringify(data.user));

        // Navigate to the dashboard
        navigate('/dashboard');
      } else if (response.status === 400) {
        // Display errors if login fails
        setErrors(data.errors || []);
      } else {
        setMessage('An unexpected error occurred.');
      }
    } catch (error) {
      console.error('Error during login:', error);
      setMessage('An error occurred while logging in.');
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
  {/* Unified White Card */}
  <div className="relative z-10 max-w-xl mx-auto bg-white bg-opacity-95 rounded-2xl shadow-2xl px-8 py-12 mb-20 mt-20 border border-gray-200 text-center">
    
    {/* Logo */}
    <img
      src={FitJourneyLogo}
      alt="Fit Journey Logo"
      className="mx-auto h-20 w-20 mb-4"
    />

    {/* Title + Slogan */}
    <h1 className="text-5xl md:text-6xl font-extrabold tracking-tight text-[#0f172a]">Fit Journey</h1>
    <p className="text-2xl md:text-3xl font-medium mt-3 italic text-[#0f172a] opacity-90">
      Track. Train. Transform.
    </p>

    {/* Login Form */}
    <h2 className="text-2xl font-bold text-[#0f172a] mt-10 mb-6">Welcome Back</h2>
    <form onSubmit={doLogin} className="space-y-5">
      <input
        type="text"
        placeholder="Username"
        value={loginName}
        onChange={(e) => setLoginName(e.target.value)}
        className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#2563eb] transition"
      />

      <input
        type="password"
        placeholder="Password"
        value={loginPassword}
        onChange={(e) => setPassword(e.target.value)}
        className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#2563eb] transition"
      />

      <button
        type="submit"
        className="w-full bg-[#0f172a] text-white py-3 rounded-xl font-semibold hover:bg-[#2563eb] transition-all shadow-md hover:shadow-lg"
      >
        Log In
      </button>
    </form>

    {errors.length > 0 && (
      <div className="mt-5 text-red-600 bg-red-100 p-3 rounded-lg text-sm">
        <h3 className="font-medium mb-1">Errors:</h3>
        <ul className="list-disc list-inside">
          {errors.map((error, index) => (
            <li key={index}>{error}</li>
          ))}
        </ul>
      </div>
    )}

    {message && <p className="text-center text-red-600 mt-4 text-sm">{message}</p>}

    <div className="text-center mt-6 text-sm">
      <p className="text-[#0f172a]">
        Don’t have an account?{' '}
        <button
          onClick={() => navigate('/register')}
          className="text-[#2563eb] underline hover:text-[#1e40af] transition"
        >
          Register
        </button>
      </p>
    </div>
  </div>
</div>



  );
}

export default Login;