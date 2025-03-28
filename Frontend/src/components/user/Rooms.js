import React, { useState } from 'react';
import Cookies from 'js-cookie';
import { Link, useNavigate } from 'react-router-dom';
import { bookRoomApi, userGetRoomApi } from '../../services/api';
import { toast } from 'react-toastify';

export const Rooms = () => {
    const [showTable, setShowTable] = useState(false);
    const [date, setDate] = useState('');
    const [startTime, setStartTime] = useState('');
    const [endTime, setEndTime] = useState('');
    const [tableData, setTableData] = useState([]);
    const navigate = useNavigate();

    const handleSearch = async () => {
        const searchParam = {
            user_id: JSON.parse(Cookies.get('user')).user_id,
            date: date,
            start_time: convertTo24HourFormat(startTime),
            end_time: convertTo24HourFormat(endTime),
        };
        try {
            const response = await userGetRoomApi(searchParam);
            setTableData(response.data);
            setShowTable(true);
        } catch (error) {
            console.error('Error fetching room data:', error);
        }
    };

    const handleSelect = async (roomId) => {
        const roomData = {
            user_id: JSON.parse(Cookies.get('user')).user_id,
            reservation_date: date,
            start_time: convertTo24HourFormat(startTime),
            end_time: convertTo24HourFormat(endTime),
            room_id: roomId,
            reservation_status: 1
        }
        try {
            await bookRoomApi(roomData);
            toast.success('Booked Room');
            navigate('/user')
        } catch (err) {
            toast.error('Something went wrong')
        }
    };


    function convertTo24HourFormat(time12h) {
        const [time, modifier] = time12h.split(' ');
        let [hours, minutes, seconds] = time.split(':').map(Number);
        seconds = seconds || 0;

        if (modifier === 'PM' && hours !== 12) {
            hours += 12;
        } else if (modifier === 'AM' && hours === 12) {
            hours = 0;
        }

        const hours24 = String(hours).padStart(2, '0');
        const minutes24 = String(minutes).padStart(2, '0');
        const seconds24 = String(seconds).padStart(2, '0');

        return `${hours24}:${minutes24}:${seconds24}`;
    }

    return (
        <div className="d-flex flex-column min-vh-100">
            <header className="mb-4 p-3" style={{ backgroundColor: '#2c3e50', color: 'white' }}>
                <div className="d-flex justify-content-between align-items-center">
                    <h2>Room Management</h2>
                </div>
            </header>

            <main className="flex-grow-1">
                <div className="mt-5 p-4" style={{ padding: '20px' }}>
                    <div className="d-flex justify-content-center align-items-center mb-4">
                        <label htmlFor="category" className="mb-2">Enter Date</label>
                        <input
                            type="date"
                            className="form-control mx-2"
                            placeholder="Date"
                            id="dateVal"
                            style={{ maxWidth: '150px' }}
                            value={date}
                            onChange={(e) => setDate(e.target.value)}
                        />
                        <label htmlFor="category" className="mb-2">Enter Start Time</label>
                        <input
                            type="time"
                            className="form-control mx-2"
                            id="stimeVal"
                            style={{ maxWidth: '150px' }}
                            value={startTime}
                            onChange={(e) => setStartTime(e.target.value)}
                        />
                        <label htmlFor="category" className="mb-2">Enter End Time</label>
                        <input
                            type="time"
                            className="form-control mx-2"
                            id="etimeVal"
                            style={{ maxWidth: '150px' }}
                            value={endTime}
                            onChange={(e) => setEndTime(e.target.value)}
                        />
                        <button className="btn btn-primary mx-2" onClick={handleSearch}>
                            Search
                        </button>
                    </div>

                    {/* Table */}
                    {showTable && (
                        <table className="table table-striped table-bordered">
                            <thead>
                                <tr>
                                    <th>Room ID</th>
                                    <th>Room Number</th>
                                    <th>Capacity</th>
                                    <th>Room Type</th>
                                    <th>Building</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                {tableData.map((room, index) => (
                                    <tr key={index}>
                                        <td>{room.room_id}</td>
                                        <td>{room.room_no}</td>
                                        <td>{room.capacity}</td>
                                        <td>{room.room_type}</td>
                                        <td>{room.building_id}</td>
                                        <td>
                                            <button className="btn btn-success" onClick={() => handleSelect(room.room_id)}>Select</button>
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    )}
                </div>
            </main>

            <footer className="p-3" style={{ backgroundColor: '#2c3e50', color: 'white' }}>
                <div className="text-center">
                    <Link to="/user" className="btn btn-secondary">
                        Back to User Dashboard
                    </Link>
                    <p>&copy; 2024 Room Management System. All rights reserved.</p>
                </div>
            </footer>
        </div>
    );
};
