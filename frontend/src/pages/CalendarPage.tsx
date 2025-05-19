import "react-calendar/dist/Calendar.css"; 
import CalendarUI from "../components/CalendarUI";

function CalendarPage() {
  return (

    <div className="h-screen bg-white flex flex-col">
      {/* Top Bar */}
      <CalendarUI/>
    </div>
  );
}
export default CalendarPage