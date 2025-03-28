import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { createRoomApi, deleteRoomApi, getAllBuildingsApi, getRoomsApi, modifyRoomApi } from '../../services/api';
import { toast } from 'react-toastify';

export const RoomsPage = () => {
    const [activeForm, setActiveForm] = useState('viewRooms');
    const [rooms, setRooms] = useState([]);
    const [buildings, setBuildings] = useState([])
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState(null);

    const roomTypes = [
        { id: 1, name: 'Study Room' },
        { id: 2, name: 'Meeting Room' },
        { id: 3, name: 'Computer Lab' },
    ];

    const fetchRooms = async () => {
        try {
            setLoading(true);
            const response = await getRoomsApi();
            const sortedData = response.data.sort((a, b) => a.room_no - b.room_no);
            setRooms(sortedData);
            setLoading(false);
        } catch (err) {
            setError(err.message);
            setLoading(false);
        }
    };

    const fetchBuildings = async () => {
        try {
            setLoading(true);
            const response = await getAllBuildingsApi();
            setBuildings(response.data);
            setLoading(false);
        } catch (err) {
            setError(err.message)
            setLoading(false)
        }
    }

    useEffect(() => {
        fetchRooms();
        fetchBuildings();
    }, []);

    const createRoom = async (roomData) => {
        console.log(roomData);
        try {
            await createRoomApi(roomData);
            fetchRooms();
            setActiveForm("viewRooms")
            toast.success('Room created successfully!');
        } catch (err) {
            setError(err.message);
        }
    };

    const modifyRoom = async (roomId, updatedData) => {
        try {
            if (roomId == null) {
                toast.error('Please select resource')
            } else {
                await modifyRoomApi(roomId, updatedData);
                fetchRooms();
                setActiveForm("viewRooms")
                toast.success('Room modified successfully!');
            }
        } catch (err) {
            setError(err.message);
        }
    };

    const deleteRoom = async (roomId) => {
        try {
            await deleteRoomApi(roomId)
            fetchRooms();
            setActiveForm("viewRooms")
            toast.success("Room deleted successfully!")
        } catch (err) {
            setError(err.message);
        }
    };

    const handleButtonClick = (form) => {
        setActiveForm(form);
    };

    const handleCreateSubmit = (event) => {
        event.preventDefault();
        const roomData = {
            room_no: event.target.roomNumber.value,
            capacity: event.target.capacity.value,
            room_type: event.target.roomType.value,
            availability_status: event.target.availability.value === 'available' ? 1 : 0,
            building_id: event.target.building.value
        };
        createRoom(roomData);
    };

    const handleModifySubmit = (event) => {
        event.preventDefault();
        if (event.target.roomSelect.value === "") {
            toast.error('Please select room')
        } else {
            const roomId = event.target.roomSelect.value;
            const updatedData = {
                room_no: event.target.roomNumberModify.value,
                capacity: event.target.capacityModify.value,
                room_type: event.target.roomTypeModify.value,
                availability_status: event.target.availabilityModify.value === 'available' ? 1 : 0,
                building_id: event.target.buildingModify.value
            };
            modifyRoom(roomId, updatedData);
        }
    };

    const handleRoomSelectChange = (event) => {
        const selectedRoomId = event.target.value;
        const selectedRoom = rooms.find((room) => room.room_id === selectedRoomId)
        if (selectedRoom) {
            document.getElementById('roomNumberModify').value = selectedRoom.room_no;
            document.getElementById('capacityModify').value = selectedRoom.capacity;
            document.getElementById('roomTypeModify').value = selectedRoom.room_type;
            if (selectedRoom.availability_status) {
                document.getElementById('available').checked = true;
            } else {
                document.getElementById('notAvailable').checked = true;
            }
            document.getElementById('buildingModify').value = selectedRoom.building_id;
        }

    };

    const handleDeleteSubmit = (event) => {
        event.preventDefault();
        const roomId = event.target.roomDelete.value;
        deleteRoom(roomId);
    };

    if (loading) return <p>Loading...</p>;
    if (error) return <p>Error: {error}</p>;

    return (
        <div className="d-flex flex-column min-vh-100">
            <header className="mb-4 p-3" style={{ backgroundColor: '#2c3e50', color: 'white' }}>
                <div className="d-flex justify-content-between align-items-center">
                    <h2>Room Management</h2>
                    <div>
                        <button
                            className="btn btn-primary mx-2"
                            onClick={() => handleButtonClick('viewRooms')}
                        >
                            View Rooms
                        </button>
                        <button
                            className="btn btn-success mx-2"
                            onClick={() => handleButtonClick('createRoom')}
                        >
                            Create Room
                        </button>
                        <button
                            className="btn btn-warning mx-2"
                            onClick={() => handleButtonClick('modifyRoom')}
                        >
                            Modify Room
                        </button>
                        <button
                            className="btn btn-danger mx-2"
                            onClick={() => handleButtonClick('deleteRoom')}
                        >
                            Delete Room
                        </button>
                    </div>
                </div>
            </header>

            <main className="flex-grow-1">
                <div className="mt-5 p-4" style={{ padding: '20px' }}>
                    {activeForm === 'viewRooms' && (
                        <div >
                            <h4>View Rooms</h4>
                            <table className="table table-bordered table-hover"
                                style={{
                                    backgroundColor: '#d6d6d6',
                                    borderRadius: '8px',
                                    boxShadow: '0 4px 8px rgba(0, 0, 0, 0.2)'
                                }}
                            >
                                <thead className="thead-dark">
                                    <tr>
                                        <th>Room ID</th>
                                        <th>Room Number</th>
                                        <th>Capacity</th>
                                        <th>Status</th>
                                        <th>Type</th>
                                        <th>Buiding ID</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    {rooms.map((room) => (
                                        <tr key={room.room_id}>
                                            <td>{room.room_id}</td>
                                            <td>{room.room_no}</td>
                                            <td>{room.capacity}</td>
                                            <td>{room.availability_status ? "true" : "false"}</td>
                                            <td>{room.room_type}</td>
                                            <td>{room.building_id}</td>
                                        </tr>
                                    ))}
                                </tbody>
                            </table>
                        </div>
                    )}
                    {(activeForm === 'createRoom' || activeForm === 'modifyRoom' || activeForm === 'deleteRoom') && (
                        <div className="d-flex justify-content-center">
                            <div
                                className="form-container p-4"
                                style={{
                                    maxWidth: '400px',
                                    width: '100%',
                                    backgroundColor: '#d6d6d6',
                                    borderRadius: '8px',
                                    boxShadow: '0 4px 8px rgba(0, 0, 0, 0.2)'
                                }}
                            >
                                {activeForm === 'createRoom' && (
                                    <div>
                                        <h4>Create Room</h4>
                                        <form onSubmit={handleCreateSubmit}>
                                            <div className="mb-3">
                                                <label htmlFor="roomNumber" className="form-label">Room Number</label>
                                                <input type="number" id="roomNumber" className="form-control" required />
                                            </div>
                                            <div className="mb-3">
                                                <label htmlFor="capacity" className="form-label">Capacity</label>
                                                <input type="number" id="capacity" className="form-control" required />
                                            </div>
                                            <div className="mb-3">
                                                <label htmlFor="roomType" className="form-label">Room Type</label>
                                                <select id="roomType" className="form-select" required>
                                                    {roomTypes.map((roomType) => (
                                                        <option key={roomType.id} value={roomType.name}>
                                                            {roomType.name}
                                                        </option>
                                                    ))}
                                                </select>
                                            </div>
                                            <div className="mb-3">
                                                <label htmlFor="building" className="form-label">Building</label>
                                                <select id="building" className="form-select" required>
                                                    {buildings.map((building) => (
                                                        <option key={building.building_id} value={building.building_id}>
                                                            {building.department_name}
                                                        </option>
                                                    ))}
                                                </select>
                                            </div>

                                            {/* Dynamic Availability Radio Buttons */}
                                            <div className="mb-3">
                                                <label className="form-label">Availability</label>
                                                <div className="form-check">
                                                    <input
                                                        type="radio"
                                                        id="available"
                                                        name="availability"
                                                        value="available"
                                                        className="form-check-input"
                                                        required
                                                    />
                                                    <label htmlFor="available" className="form-check-label">Available</label>
                                                </div>
                                                <div className="form-check">
                                                    <input
                                                        type="radio"
                                                        id="notAvailable"
                                                        name="availability"
                                                        value="notAvailable"
                                                        className="form-check-input"
                                                    />
                                                    <label htmlFor="notAvailable" className="form-check-label">Not Available</label>
                                                </div>
                                            </div>

                                            <button type="submit" className="btn btn-success w-100" sub>
                                                Create
                                            </button>
                                        </form>
                                    </div>
                                )}
                                {activeForm === 'modifyRoom' && (
                                    <div>
                                        <h4>Modify Room</h4>
                                        <form onSubmit={handleModifySubmit}>
                                            <div className="mb-3">
                                                <label htmlFor="roomSelect" className="form-label">Select Room</label>
                                                <select id="roomSelect" className="form-select" onChange={handleRoomSelectChange}>
                                                    <option value="">Choose a room...</option>
                                                    {rooms.map((room) => (
                                                        <option key={room.room_id} value={room.room_id}>
                                                            {room.room_no}
                                                        </option>
                                                    ))}
                                                </select>
                                            </div>
                                            <div className="mb-3">
                                                <label htmlFor="roomNumberModify" className="form-label">Room Number</label>
                                                <input type="number" id="roomNumberModify" className="form-control" readOnly />
                                            </div>
                                            <div className="mb-3">
                                                <label htmlFor="capacityModify" className="form-label">Capacity</label>
                                                <input type="number" id="capacityModify" className="form-control" required />
                                            </div>
                                            <div className="mb-3">
                                                <label htmlFor="roomTypeModify" className="form-label">Room Type</label>
                                                <select id="roomTypeModify" className="form-select" required>
                                                    {roomTypes.map((roomType) => (
                                                        <option key={roomType.id} value={roomType.name}>
                                                            {roomType.name}
                                                        </option>
                                                    ))}
                                                </select>
                                            </div>
                                            <div className="mb-3">
                                                <label htmlFor="buildingModify" className="form-label">Building</label>
                                                <select id="buildingModify" className="form-select" required>
                                                    {buildings.map((building) => (
                                                        <option key={building.building_id} value={building.building_id}>
                                                            {building.department_name}
                                                        </option>
                                                    ))}
                                                </select>
                                            </div>
                                            <div className="mb-3">
                                                <label className="form-label">Availability</label>
                                                <div className="form-check">
                                                    <input
                                                        type="radio"
                                                        id="available"
                                                        name="availabilityModify"
                                                        value="available"
                                                        className="form-check-input"
                                                        required
                                                    />
                                                    <label htmlFor="available" className="form-check-label">Available</label>
                                                </div>
                                                <div className="form-check">
                                                    <input
                                                        type="radio"
                                                        id="notAvailable"
                                                        name="availabilityModify"
                                                        value="notAvailable"
                                                        className="form-check-input"
                                                        required
                                                    />
                                                    <label htmlFor="notAvailable" className="form-check-label">Not Available</label>
                                                </div>
                                            </div>
                                            <button type="submit" className="btn btn-warning w-100">
                                                Modify
                                            </button>
                                        </form>
                                    </div>
                                )}
                                {activeForm === 'deleteRoom' && (
                                    <div>
                                        <h4>Delete Room</h4>
                                        <form onSubmit={handleDeleteSubmit}>
                                            <div className="mb-3">
                                                <label htmlFor="roomDelete" className="form-label">Select Room</label>
                                                <select id="roomDelete" className="form-select">
                                                    <option value="">Choose a room...</option>
                                                    {rooms.map((room) => (
                                                        <option key={room.room_id} value={room.room_id}>
                                                            {room.room_no}
                                                        </option>
                                                    ))}
                                                </select>
                                            </div>
                                            <button type="submit" className="btn btn-danger w-100">
                                                Delete
                                            </button>
                                        </form>
                                    </div>
                                )}
                            </div>
                        </div>
                    )
                    }
                </div >
            </main >

            <footer className="p-3" style={{ backgroundColor: '#2c3e50', color: 'white' }}>
                <div className="text-center">
                    <Link to="/admin" className="btn btn-secondary">
                        Back to Admin Dashboard
                    </Link>
                    <p>&copy; 2024 Room Management System. All rights reserved.</p>
                </div>
            </footer>
        </div >
    );
};
