import { BrowserRouter as Router, Route, Routes, Navigate } from 'react-router-dom';
//import './App.css';
import './index.css';
import LoginPage from './pages/LoginPage';
import CardPage from './pages/CardPage';
import RegisterPage from './pages/RegisterPage';
import DashboardPage from './pages/DashboardPage';
import CalendarPage from './pages/CalendarPage';
import DietPage from './pages/DietPage';
import FriendsPage from './pages/FriendsPage';
import ProfilePage from './pages/ProfilePage';
import VerificationPage from './pages/VerificationPage';
import UserStatsPage from './pages/UserStatsPage';
import ResetPassword from './components/ResetPassword';
import MotivationPage from './pages/MotivationPage';
import NotesPage from './pages/NotesPage';
import LeaderboardPage from './pages/LeaderboardPage';

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<LoginPage />} />
        <Route path="/cards" element={<CardPage />} />
        <Route path="/dashboard" element={<DashboardPage />} />
        <Route path="/calendar" element={<CalendarPage />} />
        <Route path="/diet" element={<DietPage />} />
        <Route path="/friends" element={<FriendsPage />} />
        <Route path="/profile" element={<ProfilePage />} />
        <Route path="/verification" element={<VerificationPage />} />
        <Route path="/register" element={<RegisterPage />} />
        <Route path="/setup-profile" element={<UserStatsPage />} />
        <Route path="/reset-password" element={<ResetPassword />} /> {/* Add the route for password reset */}
        <Route path="/motivation" element={<MotivationPage />} /> 
        <Route path="/notes" element={<NotesPage /> } />
        <Route path="/leaderboard" element={<LeaderboardPage /> } />  
        <Route path="*" element={<Navigate to="/" />} /> {/* Redirect invalid routes to the login page */}
      </Routes>
    </Router>
  );
}

export default App;