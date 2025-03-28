import React, { useEffect, useState } from 'react'
import { createPolicyApi, deletePolicyApi, getAllPolicyApi, modifyPolicyApi } from '../../services/api';
import { Link } from 'react-router-dom';
import { toast } from 'react-toastify';

export const ManagePolicy = () => {
    const [activeForm, setActiveForm] = useState('viewPolicy');
    const [policy, setPolicy] = useState([]);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState(null);


    const fetchPolicy = async () => {
        try {
            setLoading(true);
            const response = await getAllPolicyApi();
            setPolicy(response.data);
            setLoading(false);
        } catch (err) {
            setError(err.message);
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchPolicy();
    }, []);

    const createPolicy = async (policyData) => {
        try {
            await createPolicyApi(policyData);
            fetchPolicy();
            setActiveForm("viewPolicy")
            toast.success('Policy created successfully!');
        } catch (err) {
            setError(err.message);
        }
    };

    const modifyPolicy = async (policyId, updatedData) => {
        try {
            await modifyPolicyApi(policyId, updatedData);
            fetchPolicy();
            setActiveForm("viewPolicy")
            toast.success('Policy modified successfully!');
        } catch (err) {
            setError(err.message);
        }
    };

    const deletePolicy = async (policyId) => {
        try {
            await deletePolicyApi(policyId)
            fetchPolicy();
            setActiveForm("viewPolicy")
            toast.success("Policy deleted successfully!")
        } catch (err) {
            setError(err.message);
        }
    };

    const handleButtonClick = (form) => {
        setActiveForm(form);
    };

    const handleCreateSubmit = (event) => {
        event.preventDefault();
        const policyData = {
            policy_text: event.target.policyText.value
        };
        createPolicy(policyData);
    };

    const handleModifySubmit = (event) => {
        event.preventDefault();
        const policyId = event.target.policy.value;
        const updatedData = {
            policy_text: event.target.policyTextModify.value
        };
        modifyPolicy(policyId, updatedData);
    };

    const handleRoomSelectChange = (event) => {
        const selectedPolicyId = event.target.value;
        const selectedPolicy = policy.find((policy1) => policy1.policy_id == selectedPolicyId)
        if (selectedPolicy) {
            document.getElementById('policyTextModify').value = selectedPolicy.policy_text;
        }
    };

    const handleDeleteSubmit = (event) => {
        event.preventDefault();
        const policyId = event.target.policyDelete.value;
        deletePolicy(policyId);
    };

    if (loading) return <p>Loading...</p>;
    if (error) return <p>Error: {error}</p>;

    return (
        <div className="d-flex flex-column min-vh-100">
            <header className="mb-4 p-3" style={{ backgroundColor: '#2c3e50', color: 'white' }}>
                <div className="d-flex justify-content-between align-items-center">
                    <h2>Policy Management</h2>
                    <div>
                        <button
                            className="btn btn-primary mx-2"
                            onClick={() => handleButtonClick('viewPolicy')}
                        >
                            View Policy
                        </button>
                        <button
                            className="btn btn-success mx-2"
                            onClick={() => handleButtonClick('createPolicy')}
                        >
                            Create Policy
                        </button>
                        <button
                            className="btn btn-warning mx-2"
                            onClick={() => handleButtonClick('modifyPolicy')}
                        >
                            Modify Policy
                        </button>
                        <button
                            className="btn btn-danger mx-2"
                            onClick={() => handleButtonClick('deletePolicy')}
                        >
                            Delete Policy
                        </button>
                    </div>
                </div>
            </header>

            <main className="flex-grow-1">
                <div className="mt-5 p-4" style={{ padding: '20px' }}>
                    {activeForm === 'viewPolicy' && (
                        <div >
                            <h4>View Policy</h4>
                            <table className="table table-bordered table-hover"
                                style={{
                                    backgroundColor: '#d6d6d6',
                                    borderRadius: '8px',
                                    boxShadow: '0 4px 8px rgba(0, 0, 0, 0.2)'
                                }}
                            >
                                <thead className="thead-dark">
                                    <tr>
                                        <th>Policy ID</th>
                                        <th>Policy Text</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    {policy.map((policy1) => (
                                        <tr key={policy1.policy_id}>
                                            <td>{policy1.policy_id}</td>
                                            <td>{policy1.policy_text}</td>
                                        </tr>
                                    ))}
                                </tbody>
                            </table>
                        </div>
                    )}
                    {(activeForm === 'createPolicy' || activeForm === 'modifyPolicy' || activeForm === 'deletePolicy') && (
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
                                {activeForm === 'createPolicy' && (
                                    <div>
                                        <h4>Create Policy</h4>
                                        <form onSubmit={handleCreateSubmit}>
                                            <div className="mb-3">
                                                <label htmlFor="policyText" className="form-label">Policy Text</label>
                                                <input type="text" id="policyText" className="form-control" required />
                                            </div>

                                            <button type="submit" className="btn btn-success w-100" sub>
                                                Create
                                            </button>
                                        </form>
                                    </div>
                                )}
                                {activeForm === 'modifyPolicy' && (
                                    <div>
                                        <h4>Modify Policy</h4>
                                        <form onSubmit={handleModifySubmit}>
                                            <div className="mb-3">
                                                <label htmlFor="policy" className="form-label">Select Policy</label>
                                                <select id="policy" className="form-select" onChange={handleRoomSelectChange}>
                                                    <option value="">Choose a policy...</option>
                                                    {policy.map((policy1) => (
                                                        <option key={policy1.policy_id} value={policy1.policy_id}>
                                                            {policy1.policy_text}
                                                        </option>
                                                    ))}
                                                </select>
                                            </div>
                                            <div className="mb-3">
                                                <label htmlFor="policyTextModify" className="form-label">Policy Text</label>
                                                <input type="text" id="policyTextModify" className="form-control" />
                                            </div>
                                            <button type="submit" className="btn btn-warning w-100">
                                                Modify
                                            </button>
                                        </form>
                                    </div>
                                )}
                                {activeForm === 'deletePolicy' && (
                                    <div>
                                        <h4>Delete Policy</h4>
                                        <form onSubmit={handleDeleteSubmit}>
                                            <div className="mb-3">
                                                <label htmlFor="policyDelete" className="form-label">Select Room</label>
                                                <select id="policyDelete" className="form-select">
                                                    <option value="">Choose a policy...</option>
                                                    {policy.map((policy1) => (
                                                        <option key={policy1.policy_id} value={policy1.policy_id}>
                                                            {policy1.policy_text}
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
