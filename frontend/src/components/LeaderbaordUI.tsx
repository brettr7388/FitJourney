import { useEffect, useState } from "react";
import IconUI from "./IconsUI";
import { buildPath } from "./Path";

//form of leaderboard data
type LeaderboardEntry = {
  login: string;
  streaks: number;
};

function LeaderboardUI() {
  const [leaderboard, setLeaderboard] = useState<LeaderboardEntry[]>([]);

  // gets top 5 users
  useEffect(() => {
    const fetchLeaderboard = async () => {
      try {
        const response = await fetch(buildPath("api/leaderboard"));
        const data = await response.json();
        if (response.ok) {
          setLeaderboard(data);
        } else {
          console.error("Failed to fetch leaderboard:", data.error);
        }
      } catch (err) {
        console.error("Error fetching leaderboard:", err);
      }
    };

    fetchLeaderboard();
  }, []);

  return (
    <div className="h-screen w-full flex flex-col bg-gradient-to-b from-blue-100 to-blue-200 overflow-y-auto">
      <IconUI />

      <div className="flex flex-col items-center justify-center flex-1 px-8">
        <h2 className="text-6xl font-extrabold text-[#0f172a] mb-12">
          🏆 Leaderboard
        </h2>

        <div className="w-full max-w-4xl bg-white rounded-3xl shadow-2xl p-10">
          {leaderboard.length === 0 ? (
            <p className="text-center text-xl text-gray-600">
              No leaderboard data available.
            </p>
          ) : (
            <ul className="space-y-6">
              {leaderboard.map((entry, index) => (
                <li
                  key={index}
                  className="flex justify-between items-center text-3xl font-semibold border-b border-gray-200 pb-4"
                >
                  <span>
                    #{index + 1} {entry.login}
                  </span>
                  <span className="text-red-500 font-bold">{entry.streaks}🔥</span>
                </li>
              ))}
            </ul>
          )}
        </div>
      </div>
    </div>
  );
}

export default LeaderboardUI;
