import React, { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom';
import Cookies from 'js-cookie';
import { adminDashboardReservation, adminDashboardResource } from '../../services/api';

export const AdminDashboard = () => {

    const [reservations, setreservations] = useState([])
    const [resources, setresources] = useState([])

    const navigate = useNavigate();

    const handleLogout = async () => {
        navigate("/logout");
    };

    const fetchAllDetails = async () => {
        const resp1 = await adminDashboardReservation();
        setreservations(resp1.data.reservations[0].reservations)
    }

    useEffect(() => {
        fetchAllDetails();
    }, []);

    return (
        <div className="container-fluid bg-light vh-100">
            <div className="row h-100">
                {/* Sidebar */}
                <nav className="col-md-2 d-none d-md-block bg-dark sidebar vh-100">
                    <div className="sidebar-sticky d-flex flex-column h-100">
                        <ul className="nav flex-column text-white">
                            <li className="nav-item mt-3">
                                <h5 className="text-white text-center">Admin Dashboard</h5>
                            </li>
                            <li className="nav-item mt-4">
                                <a className="nav-link text-white" href="/admin/rooms">
                                    Manage Rooms
                                </a>
                            </li>
                            <li className="nav-item">
                                <a className="nav-link text-white" href="/admin/building">
                                    Manage Building
                                </a>
                            </li>
                            <li className="nav-item">
                                <a className="nav-link text-white" href="/admin/resources">
                                    Manage Resources
                                </a>
                            </li>
                            <li className="nav-item">
                                <a className="nav-link text-white" href="/admin/policy">
                                    Policies
                                </a>
                            </li>
                            <li className="nav-item">
                                <a className="nav-link text-white" href="/admin/feedbacks">
                                    Feedback
                                </a>
                            </li>
                        </ul>
                        <div className="mt-auto">
                            <button className="btn btn-danger w-100" onClick={handleLogout}>Logout</button>
                        </div>
                    </div>
                </nav>

                {/* Main Content */}
                <main className="col-md-10 ml-sm-auto col-lg-10 px-4 py-4">
                    <h2 className="text-dark mb-4">Welcome, {JSON.parse(Cookies.get('user')).username}</h2>

                    {/* Tables Section */}
                    <div className="row">
                        {/* Booked Rooms Table */}
                        <div className="col-md-12">
                            <h4 className="mb-3">Booked Rooms</h4>
                            <table className="table table-bordered table-hover">
                                <thead className="thead-dark">
                                    <tr>
                                        <th>Room Number, Department Name</th>
                                        <th>Time Booked</th>
                                        <th>Booked By</th>
                                        <th>Booking Date</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    {reservations.length == 0 ? <><h3>No Reservations available</h3></> : reservations.map((room) => (
                                        <tr key={room.room_id}>
                                            <td>{room.room_no}, {room.department_name}</td>
                                            <td>{room.start_time.split('.')[0]} - {room.end_time.split('.')[0]}</td>
                                            <td>{room.username}</td>
                                            <td>{room.reservation_date}</td>
                                        </tr>
                                    ))}
                                </tbody>
                            </table>
                        </div>
                    </div>
                </main>
            </div>
        </div>
    );
};
