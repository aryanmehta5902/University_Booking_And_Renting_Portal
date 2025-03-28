import React, { useEffect, useState } from 'react'
import { feebackRoomsApi, feedbackResourcesApi, feedbackRoomsApi, getRoomsApi } from '../../services/api';
import { Link } from 'react-router-dom';

export const ViewFeedbacks = () => {
    const [activeForm, setActiveForm] = useState('viewRooms');
    const [feedbacks, setFeedbacks] = useState([]);
    const [resourceFeedbacks, setresourceFeedbacks] = useState([])

    const fetchFeedbacks = async () => {
        try {
            const response = await feedbackRoomsApi();
            const response1 = await feedbackResourcesApi();
            setFeedbacks(response.data);
            setresourceFeedbacks(response1.data);
        } catch (err) {
            console.log(err);
        }
    };
    useEffect(() => {
        fetchFeedbacks();
    }, []);

    const handleButtonClick = (form) => {
        setActiveForm(form);
    };

    return (
        <div className="d-flex flex-column min-vh-100">
            <header className="mb-4 p-3" style={{ backgroundColor: '#2c3e50', color: 'white' }}>
                <div className="d-flex align-items-center justify-content-between">
                    <h2>Feedbacks</h2>
                    <div className="d-flex gap-2">
                        <button
                            className="btn btn-primary"
                            onClick={() => handleButtonClick('viewRooms')}
                        >
                            View Room Feedbacks
                        </button>
                        <button
                            className="btn btn-primary"
                            onClick={() => handleButtonClick('viewResources')}
                        >
                            View Resource Feedbacks
                        </button>
                    </div>
                </div>
            </header>

            <main className="flex-grow-1">
                {activeForm === 'viewRooms' && (
                    <div className="mt-5 p-4" style={{ padding: '20px' }}>

                        <div >
                            <h4>View Rooms Feedbacks</h4>
                            <table className="table table-bordered table-hover"
                                style={{
                                    backgroundColor: '#d6d6d6',
                                    borderRadius: '8px',
                                    boxShadow: '0 4px 8px rgba(0, 0, 0, 0.2)'
                                }}
                            >
                                <thead className="thead-dark">
                                    <tr>
                                        <th>Feedback Id</th>
                                        <th>Feedback</th>
                                        <th>Username</th>
                                        <th>Room Number</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    {feedbacks.map((feedback) => (
                                        <tr key={feedback.feedback_id}>
                                            <td>{feedback.feedback_id}</td>
                                            <td>{feedback.user_comment}</td>
                                            <td>{feedback.username}</td>
                                            <td>{feedback.room_no}</td>
                                        </tr>
                                    ))}
                                </tbody>
                            </table>
                        </div>
                    </div >
                )}
                {
                    activeForm === 'viewResources' && (
                        <div className="mt-5 p-4" style={{ padding: '20px' }}>

                            <div >
                                <h4>View Rooms Feedbacks</h4>
                                <table className="table table-bordered table-hover"
                                    style={{
                                        backgroundColor: '#d6d6d6',
                                        borderRadius: '8px',
                                        boxShadow: '0 4px 8px rgba(0, 0, 0, 0.2)'
                                    }}
                                >
                                    <thead className="thead-dark">
                                        <tr>
                                            <th>Feedback Id</th>
                                            <th>Feedback</th>
                                            <th>Username</th>
                                            <th>Resource Name</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        {resourceFeedbacks.map((feedback) => (
                                            <tr key={feedback.feedback_id}>
                                                <td>{feedback.feedback_id}</td>
                                                <td>{feedback.user_comment}</td>
                                                <td>{feedback.username}</td>
                                                <td>{feedback.resource_name}</td>
                                            </tr>
                                        ))}
                                    </tbody>
                                </table>
                            </div>
                        </div >
                    )
                }
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