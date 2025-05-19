import { useEffect, useState } from "react";
import IconUI from "./IconsUI";
import graphPaper from "../assets/graphPaper.jpg";
import { buildPath } from "./Path";

function NotesUI() {
  const [note, setNote] = useState("");
  const [dateKey, setDateKey] = useState("today");
  const [streak, setStreak] = useState(0);
  const [weekdayText, setWeekdayText] = useState("");

  const userData = localStorage.getItem("user_data");
  const user = userData ? JSON.parse(userData) : null;
  const userId = user?.id;

  const parseLocalDate = (yyyyMmDd: string): Date => {
    const [year, month, day] = yyyyMmDd.split("-").map(Number);
    return new Date(year, month - 1, day);
  };

  const updateDisplayedDate = (dateStr: string) => {
    const localDate = parseLocalDate(dateStr);
    const weekday = localDate.toLocaleDateString("en-US", {
      weekday: "long",
      month: "long",
      day: "numeric",
    });
    setWeekdayText(weekday);
  };

  const loadNote = (dateStr: string) => {
    const savedNote = localStorage.getItem(`note-${dateStr}`);
    setNote(savedNote || "");
  };

  // Load initial selected date
  useEffect(() => {
    const storedDate = localStorage.getItem("selected_date");
    const today = new Date().toISOString().split("T")[0];
    const date = storedDate || today;
    setDateKey(date);
    updateDisplayedDate(date);
    loadNote(date);
  }, []);

  // Save note to localStorage
  useEffect(() => {
    localStorage.setItem(`note-${dateKey}`, note);
  }, [note, dateKey]);

  // Fetch streak from backend
  useEffect(() => {
    const fetchStreak = async () => {
      if (!userId) return;
      try {
        const response = await fetch(buildPath(`api/streak?userId=${userId}`));
        const data = await response.json();
        if (response.ok && typeof data.streaks === "number") {
          setStreak(data.streaks);
        }
      } catch (err) {
        console.error("Failed to fetch streak:", err);
      }
    };
    fetchStreak();
  }, [userId]);

  const handleDateChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const newDate = e.target.value;
    setDateKey(newDate);
    updateDisplayedDate(newDate);
    loadNote(newDate);
    localStorage.setItem("selected_date", newDate); // Sync back to Dashboard
  };

  const getGradient = (streak: number): string => {
    const clamped = Math.max(0, Math.min(streak, 30));

    const transitionToRed = Math.min(clamped, 15) / 15;
    const startR = Math.floor(59 + transitionToRed * (255 - 59));
    const startG = Math.floor(130 - transitionToRed * 130);
    const startB = Math.floor(246 - transitionToRed * 246);

    const startColor = `rgba(${startR}, ${startG}, ${startB}, 0.85)`;

    const fadeWhiteToRed = clamped > 15 ? (clamped - 15) / 15 : 0;
    const endR = 255;
    const endG = Math.floor(255 - fadeWhiteToRed * 255);
    const endB = Math.floor(255 - fadeWhiteToRed * 255);

    const endColor = `rgba(${endR}, ${endG}, ${endB}, 0.85)`;

    return `linear-gradient(to bottom right, ${startColor}, ${endColor})`;
  };

  return (
    <div
      className="min-h-screen flex flex-col items-center justify-start bg-fixed bg-cover bg-center relative"
      style={{
        backgroundImage: `
          ${getGradient(streak)},
          url(${graphPaper})
        `,
        backgroundBlendMode: "overlay",
      }}
    >
     <div className="w-full z-10 relative">
      <IconUI />
     </div>

      
      <div className="flex-grow flex items-center justify-center w-full px-4">
        <div className="max-w-2xl w-full bg-white bg-opacity-95 rounded-2xl shadow-2xl px-8 py-10 border-4 border-[#0f172a] mt-12 mb-12">
          <div className="flex flex-col sm:flex-row sm:justify-between items-center gap-2 mb-4">
            <h2 className="text-xl text-gray-600 italic text-center sm:text-left">
              🗓️ {weekdayText}
            </h2>
            <input
              type="date"
              value={dateKey}
              onChange={handleDateChange}
              className="border border-gray-300 rounded px-3 py-1 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400"
            />
          </div>

          <h1 className="text-3xl font-bold text-[#0f172a] text-center mb-6">
            📝 Journey Notes for {dateKey}
          </h1>

          <textarea
            className="w-full h-80 p-4 border-2 border-blue-300 rounded-lg resize-none focus:outline-none focus:ring-2 focus:ring-blue-500 text-lg leading-relaxed"
            placeholder="Start writing about your workout, mood, or progress here..."
            value={note}
            onChange={(e) => setNote(e.target.value)}
          />

          <div className="flex justify-between items-center mt-4">
            <p className="text-sm text-gray-500 italic">Entries are auto-saved ✨</p>
            <button
              onClick={() => {
                localStorage.removeItem(`note-${dateKey}`);
                setNote("");
              }}
              className="px-4 py-2 bg-red-500 text-white rounded hover:bg-red-600 transition"
            >
              🗑️ Clear Note
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}

export default NotesUI;
