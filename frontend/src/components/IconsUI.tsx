import { useNavigate } from "react-router-dom";
import logo from "../assets/FitJourneyLogo.png"; // Update with your actual logo path

function IconUI() {
  const navigate = useNavigate();

  return (
    <div className="pt-4 px-4">
      <header className="relative w-full bg-white shadow-md px-6 py-4 sticky top-0 z-50 border-4 border-[#0f172a] rounded-2xl">
  {/* Centered Slogan */}
  <p className="absolute left-1/2 top-[1.25rem] transform -translate-x-1/2 text-xl md:text-2xl font-medium italic text-[#0f172a] opacity-90 whitespace-nowrap">
  Track. Train. Transform.
  </p>

  <div className="flex items-center justify-between w-full">
    {/* Left: Logo + Title */}
    <div className="flex items-center space-x-2">
      <img
        src={logo}
        alt="Fit Journey Logo"
        className="h-10 w-10 object-contain hover:animate-pulse transition"
      />
      <h1 className="text-3xl md:text-4xl font-extrabold tracking-tight text-[#0f172a]">
        Fit Journey
      </h1>
    </div>

          {/* Right: Icon Buttons */}
          <div className="flex items-center space-x-6">
            {/* Home Button */}
            <button
              onClick={() => navigate("/dashboard")}
              className="text-[#0f172a] hover:text-[#2563eb] hover:underline hover:decoration-[#0f172a] underline-offset-4 transition"
            >
              <svg xmlns="http://www.w3.org/2000/svg" fill="none"
                viewBox="0 0 24 24" strokeWidth="1.5"
                stroke="currentColor" className="w-8 h-8">
                <path strokeLinecap="round" strokeLinejoin="round"
                  d="M2.25 12L11.204 3.045a1.125 1.125 0 0 1 1.591 0L21.75 12M4.5 9.75v10.125A1.125 1.125 0 0 0 5.625 21h3.375v-4.875A1.125 1.125 0 0 1 10.125 15h2.25a1.125 1.125 0 0 1 1.125 1.125V21h3.375a1.125 1.125 0 0 0 1.125-1.125V9.75" />
              </svg>
            </button>

            {/* Motivation Button */}
            <button
              onClick={() => navigate("/motivation")}
              className="text-[#0f172a] hover:text-[#2563eb] hover:underline hover:decoration-[#0f172a] underline-offset-4 transition"
            >
              <svg xmlns="http://www.w3.org/2000/svg" fill="none"
                viewBox="0 0 24 24" strokeWidth="1.5"
                stroke="currentColor" className="w-8 h-8">
                <path strokeLinecap="round" strokeLinejoin="round"
                  d="M9.813 15.904 9 18.75l-.813-2.846a4.5 4.5 0 0 0-3.09-3.09L2.25 12l2.846-.813a4.5 4.5 0 0 0 3.09-3.09L9 5.25l.813 2.846a4.5 4.5 0 0 0 3.09 3.09L15.75 12l-2.846.813a4.5 4.5 0 0 0-3.09 3.09Z
                  M18.259 8.715 18 9.75l-.259-1.035a3.375 3.375 0 0 0-2.455-2.456L14.25 6l1.036-.259a3.375 3.375 0 0 0 2.455-2.456L18 2.25l.259 1.035a3.375 3.375 0 0 0 2.456 2.456L21.75 6l-1.035.259a3.375 3.375 0 0 0-2.456 2.456
                  ZM16.894 20.567 16.5 21.75l-.394-1.183a2.25 2.25 0 0 0-1.423-1.423L13.5 18.75l1.183-.394a2.25 2.25 0 0 0 1.423-1.423l.394-1.183.394 1.183a2.25 2.25 0 0 0 1.423 1.423l1.183.394-1.183.394a2.25 2.25 0 0 0-1.423
                  1.423Z" />
              </svg>
            </button>

            {/* Notes Button */}
            <button
              onClick={() => navigate("/notes")}
              className="text-[#0f172a] hover:text-[#2563eb] hover:underline hover:decoration-[#0f172a] underline-offset-4 transition"
            >
              <svg xmlns="http://www.w3.org/2000/svg" fill="none"
                viewBox="0 0 24 24" strokeWidth="1.5"
                stroke="currentColor" className="w-8 h-8">
                <path strokeLinecap="round" strokeLinejoin="round"
                  d="m16.862 4.487 1.687-1.688a1.875 1.875 0 1 1 2.652 2.652L10.582 16.07a4.5 4.5 0 0 1-1.897 1.13L6 18l.8-2.685a4.5 4.5 0 0 1 1.13-1.897l8.932-8.931Zm0 0L19.5 7.125M18 14v4.75A2.25 2.25 0 0 1 15.75 21H5.25A2.25
                  2.25 0 0 1 3 18.75V8.25A2.25 2.25 0 0 1 5.25 6H10" />
              </svg>
            </button>

            {/* Leaderboard Button */}
            <button
              onClick={() => navigate("/leaderboard")}
              className="text-[#0f172a] hover:text-[#2563eb] hover:underline hover:decoration-[#0f172a] underline-offset-4 transition"
            >
              <svg xmlns="http://www.w3.org/2000/svg" fill="none"
                viewBox="0 0 24 24" strokeWidth="1.5"
                stroke="currentColor" className="w-8 h-8">
                <path strokeLinecap="round" strokeLinejoin="round"
                  d="M3 13.125C3 12.504 3.504 12 4.125 12h2.25c.621 0 1.125.504 1.125 1.125v6.75C7.5 20.496 6.996 21 6.375 21h-2.25A1.125 1.125 0 0 1 3 19.875v-6.75ZM9.75 8.625c0-.621.504-1.125 1.125-1.125h2.25c.621 0
                  1.125.504 1.125 1.125v11.25c0 .621-.504 1.125-1.125 1.125h-2.25a1.125 1.125 0 0 1-1.125-1.125V8.625ZM16.5 4.125c0-.621.504-1.125 1.125-1.125h2.25C20.496 3 21 3.504 21 4.125v15.75c0 .621-.504 1.125-1.125
                  1.125h-2.25a1.125 1.125 0 0 1-1.125-1.125V4.125Z" />
              </svg>
            </button>

            {/* Profile Button */}
            <button
              onClick={() => navigate("/profile")}
              className="text-[#0f172a] hover:text-[#2563eb] hover:underline hover:decoration-[#0f172a] underline-offset-4 transition"
            >
              <svg xmlns="http://www.w3.org/2000/svg" fill="none"
                viewBox="0 0 24 24" strokeWidth="1.5"
                stroke="currentColor" className="w-8 h-8">
                <path strokeLinecap="round" strokeLinejoin="round"
                  d="M15.75 6a3.75 3.75 0 1 1-7.5 0
                    3.75 3.75 0 0 1 7.5 0ZM4.501 20.118
                    a7.5 7.5 0 0 1 14.998 0
                    A17.933 17.933 0 0 1 12 21.75
                    c-2.676 0-5.216-.584-7.499-1.632Z" />
              </svg>
            </button>
          </div>
        </div>
      </header>
    </div>
  );
}

export default IconUI;
