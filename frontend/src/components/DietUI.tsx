import IconUI from "./IconsUI";
function DietUI() {
    return (
        <div className="h-screen bg-white flex flex-col"
        style={{
            backgroundImage: `url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='260' height='260' viewBox='0 0 260 260'%3E%3Cg fill-rule='evenodd'%3E%3Cg fill='%23678fb4' fill-opacity='0.57'%3E%3Cpath d='M24.37 16c.2.65.39 1.32...")`,
        }}
        >
            {/* Top Bar */}
            <IconUI/>
            <h1 className="text-center">Diet</h1>
        </div>
    );
}
export default DietUI;  