import React, { useEffect, useState } from 'react'
import { Link, useNavigate } from 'react-router-dom';
import { toast } from 'react-toastify';
import { addFeedbacksResources, addFeedbacksRoom, getAllResourcesApi, getRoomsAllBuildingApi, getRoomsApi } from '../../services/api';
import Cookies from 'js-cookie';

export const Feedbacks = () => {
    const [activeForm, setActiveForm] = useState('viewResource');
    const [selectedResourceId, setSelectedResourceId] = useState('');
    const [selectedRoomId, setSelectedRoomId] = useState('');
    const [resources, setresources] = useState([])
    const [rooms, setrooms] = useState([])
    const [roomsBuild, setroomsBuild] = useState([])

    const navigate = useNavigate()

    const handleButtonClick = (form) => {
        setActiveForm(form);
    };

    const handleResourceSelectChange = (event) => {
        setSelectedResourceId(event.target.value);  // Update the selected resource ID
    };

    const handleRoomSelectChange = (event) => {
        setSelectedRoomId(event.target.value)
    }

    const handleCreateSubmit = async (event) => {
        event.preventDefault();
        try {
            const roomdata = {
                user_id: JSON.parse(Cookies.get('user')).user_id,
                resource_id: selectedResourceId,
                user_comment: event.target.feedbackD.value
            }
            await addFeedbacksResources(roomdata)
            toast.success('Feedback Successfully Entered')
            navigate('/user')
        } catch (error) {
            toast.error('Something is wrong')
        }
    };

    const handeRoomSubmit = async (event) => {
        event.preventDefault();
        try {
            const roomdata = {
                user_id: JSON.parse(Cookies.get('user')).user_id,
                room_id: selectedRoomId,
                user_comment: event.target.feedbackR.value
            }
            await addFeedbacksRoom(roomdata);
            toast.success('Feedback Added Successfully.')
            navigate('/user')
        } catch (error) {
            console.log(error);
            toast.error('Something is wrong')
        }
    }

    const fetchResources = async () => {
        try {
            const response = await getAllResourcesApi();
            setresources(response.data)
        } catch (error) {
            toast.error('Something is wrong')
        }
    }

    const fetchRooms = async () => {
        try {
            const response = await getRoomsAllBuildingApi()
            setrooms(response.data.data)
        } catch (error) {
            toast.error('Something is wrong')
        }
    }

    useEffect(() => {
        fetchResources();
        fetchRooms();
    }, []);

    return (
        <div className="d-flex flex-column min-vh-100">
            <header className="mb-4 p-3" style={{ backgroundColor: '#2c3e50', color: 'white' }}>
                <div className="d-flex justify-content-between align-items-center">
                    <h2>Feedback Management</h2>
                    <div>
                        <button
                            className="btn btn-primary mx-2"
                            onClick={() => handleButtonClick('viewResource')}
                        >
                            Add Resource Feedback
                        </button>
                        <button
                            className="btn btn-success mx-2"
                            onClick={() => handleButtonClick('viewRoom')}
                        >
                            Add Room Feedback
                        </button>
                    </div>
                </div>
            </header>

            <main className="flex-grow-1">
                {activeForm === 'viewResource' && (
                    <div>
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
                                <h4>Give Resource Feedback</h4>
                                <form onSubmit={handleCreateSubmit}>
                                    <div className="mb-3">
                                        <label htmlFor="feedbackD" className="form-label">Feedback Comments</label>
                                        <input type="string" id="feedbackD" className="form-control" required />
                                    </div>
                                    <div className="mb-3">
                                        <label htmlFor="resourceSelect" className="form-label">Select Resource</label>
                                        <select
                                            id="resourceSelect"
                                            className="form-select"
                                            value={selectedResourceId}
                                            onChange={handleResourceSelectChange}
                                        >
                                            <option value="">Choose a Resource...</option>
                                            {resources.map((resource) => (
                                                <option key={resource.resource_id} value={resource.resource_id}>
                                                    {resource.resource_name}
                                                </option>
                                            ))}
                                        </select>
                                    </div>
                                    <button type="submit" className="btn btn-success w-100">
                                        Create
                                    </button>
                                </form>
                            </div>
                        </div>
                    </div>
                )}
                {activeForm === 'viewRoom' && (
                    <div>
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
                                <h4>Add Feedback Room</h4>
                                <form onSubmit={handeRoomSubmit}>
                                    <div className="mb-3">
                                        <label htmlFor="feedbackR" className="form-label">Feedback Comments</label>
                                        <input type="string" id="feedbackR" className="form-control" required />
                                    </div>

                                    <div className="mb-3">
                                        <label htmlFor="buildingSelect" className="form-label">Select Room Number</label>
                                        <select
                                            id="buildingSelect"
                                            className="form-select"
                                            value={selectedRoomId}
                                            onChange={handleRoomSelectChange}
                                            required
                                        >
                                            <option value="">Choose a room number...</option>
                                            {rooms.map((building) => (
                                                <option key={building.room_id} value={building.room_id}>
                                                    {building.room_no},{building.department_name}
                                                </option>
                                            ))}
                                        </select>
                                    </div>
                                    <button type="submit" className="btn btn-warning w-100">
                                        Modify
                                    </button>
                                </form>
                            </div>
                        </div>
                    </div>
                )}

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
