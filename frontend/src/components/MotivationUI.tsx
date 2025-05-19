import { useState } from "react";
import IconUI from "./IconsUI";

function MotivationUI() {
  const quotes = [
    "No pain, no gain. Every rep counts!",
    "Sweat is just fat crying.",
    "Push yourself, because no one else is going to do it for you.",
    "The body achieves what the mind believes.",
    "When you feel like quitting, think about why you started.",
    "Excuses don't burn calories.",
    "Train insane or remain the same.",
    "Strive for progress, not perfection.",
    "Your only limit is you.",
    "Don't count the days, make the days count!",
  ];

  const [currentQuote, setCurrentQuote] = useState(
    "Press 'Generate Quote' for inspiration!"
  );

  const generateQuote = () => {
    const randomIndex = Math.floor(Math.random() * quotes.length);
    setCurrentQuote(quotes[randomIndex]);
  };

  return (
    <div className="h-screen bg-gradient-to-br from-[#e0f7f4] via-[#f2fdfc] to-[#ffffff] flex flex-col">
      <IconUI />

      <div className="flex-1 flex flex-col items-center justify-center px-4">
        <h1 className="text-5xl font-bold text-[#0f172a] mb-10 text-center">
          Motivational Quote Generator
        </h1>

        <div className="bg-gray-200 p-8 rounded-2xl shadow-md max-w-2xl text-center mb-10">
          <p className="text-2xl text-[#0f172a] font-medium leading-relaxed">
            “{currentQuote}”
          </p>
        </div>

        <button
          onClick={generateQuote}
          className="bg-[#0f172a] text-white px-10 py-4 rounded-xl text-xl font-semibold hover:bg-[#2563eb] transition"
        >
          Generate Quote
        </button>
      </div>
    </div>
  );
}

export default MotivationUI;
