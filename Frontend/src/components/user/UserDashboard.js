import React, { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom';
import Cookies from 'js-cookie';
import { userDashboardReservation, userDashboardResouces } from '../../services/api';

export const UserDashboard = () => {

    const [reservations, setreservations] = useState([])
    const [resources, setresources] = useState([])
    const navigate = useNavigate();

    const fetchAllDetails = async () => {
        const userdata = {
            "user_id": JSON.parse(Cookies.get('user')).user_id
        }
        const resp1 = await userDashboardReservation(userdata)
        const resp2 = await userDashboardResouces(userdata)
        if (resp1.data.error === "(1644, 'No upcoming reservations found for the user')") {
            setreservations(null)
        } else {
            setreservations(resp1.data.reservations)
        }
        if (resp2.data.error === "(1644, 'No rented resources found for the user after the specified date')") {
            setresources(null)
        } else {
            setresources(resp2.data.rented_resources)

        }
    }

    useEffect(() => {
        fetchAllDetails();
    }, []);

    const handleLogout = async () => {
        navigate("/logout");
    };

    return (
        <div className="container-fluid bg-light vh-100">
            <div className="row h-100">
                {/* Sidebar */}
                <nav className="col-md-2 d-none d-md-block bg-dark sidebar vh-100">
                    <div className="sidebar-sticky d-flex flex-column h-100">
                        <ul className="nav flex-column text-white">
                            <li className="nav-item mt-3">
                                <h5 className="text-white text-center">User Dashboard</h5>
                            </li>
                            <li className="nav-item mt-4">
                                <a className="nav-link text-white" href="/user/rooms">
                                    Rooms
                                </a>
                            </li>
                            <li className="nav-item">
                                <a className="nav-link text-white" href="/user/resources">
                                    Resources
                                </a>
                            </li>
                            <li className="nav-item">
                                <a className="nav-link text-white" href="/user/feedbacks">
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
                        <div className="col-md-6">
                            <h4 className="mb-3">Booked Rooms</h4>
                            <table className="table table-bordered table-hover">
                                <thead className="thead-dark">
                                    {reservations != null ? <><tr>
                                        <th>Room ID</th>
                                        <th>Room Number</th>
                                        <th>Start Time</th>
                                        <th>Reservation Date</th>
                                    </tr></> : ""
                                    }
                                </thead>
                                <tbody>
                                    {reservations == null ? <><h3>No upcoming reservations</h3></> : reservations.map((room) => (
                                        <tr key={room.room_id}>
                                            <td>{room.room_id}</td>
                                            <td>{room.room_no}</td>
                                            <td>{room.start_time.split('.')[0]}</td>
                                            <td>{room.reservation_date}</td>
                                        </tr>
                                    ))}
                                </tbody>
                            </table>
                        </div>

                        {/* Rented Resources Table */}
                        <div className="col-md-6">
                            <h4 className="mb-3">Rented Resources</h4>
                            <table className="table table-bordered table-hover">
                                <thead className="thead-dark">
                                    {resources != null ? <><tr>
                                        <th>Resource ID</th>
                                        <th>Resource Name</th>
                                        <th>Resevation Date - Return Date</th>
                                    </tr></> : ""
                                    }
                                </thead>
                                <tbody>
                                    {resources == null ? <><h3>No upcoming resources</h3></> : resources.map((room) => (
                                        <tr key={room.resource_id}>
                                            <td>{room.resource_id}</td>
                                            <td>{room.resource_name}</td>
                                            <td>{room.reservation_date} - {room.return_date}</td>
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

