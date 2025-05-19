import { useNavigate } from 'react-router-dom';

const Verification = () => {
  const navigate = useNavigate();

  const handleOkClick = () => {
    navigate('/login');
  };

  return (
    <div className="max-w-md mx-auto mt-10 p-6 bg-white shadow-md rounded-lg relative">
      <h1 className="absolute top-0 w-full text-5xl font-bold text-center text-[#0f172a] mt-3">
        Fit Journey
      </h1>
      <div className="mt-16 text-center">
        <h2 className="text-2xl font-bold mb-6">Please check your email inbox for a message.</h2>
        <p className="text-[#0f172a] mb-6">You must verify your email before continuing.</p>
        <button 
          onClick={handleOkClick} 
          className="mt-4 px-6 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors"
        >
          OK
        </button>
      </div>
    </div>
  );
};

export default Verification;
