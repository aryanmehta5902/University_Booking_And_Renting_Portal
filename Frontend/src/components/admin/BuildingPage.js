import React, { useEffect, useState } from 'react'
import { createBuildingApi, deleteBuildingApi, getAllBuildingsApi, modifyBuildingApi } from '../../services/api';
import { toast } from 'react-toastify';
import { Link } from 'react-router-dom';

export const BuildingPage = () => {
    {
        const [activeForm, setActiveForm] = useState('viewBuildings');
        const [buildings, setBuildings] = useState([])
        const [loading, setLoading] = useState(false);
        const [error, setError] = useState(null);

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
            fetchBuildings();
        }, []);

        const createBuilding = async (buildingData) => {
            try {
                await createBuildingApi(buildingData);
                fetchBuildings();
                setActiveForm("viewBuildings")
                toast.success('Building created successfully!');
            } catch (err) {
                setError(err.message);
            }
        };

        const modifyBuilding = async (buildingId, updatedData) => {
            try {
                await modifyBuildingApi(buildingId, updatedData);
                fetchBuildings();
                setActiveForm("viewBuildings")
                toast.success('Building modified successfully!');
            } catch (err) {
                setError(err.message);
            }
        };

        const deleteBuilding = async (buildingId) => {
            try {
                await deleteBuildingApi(buildingId)
                fetchBuildings();
                setActiveForm("viewBuildings")
                toast.success("Building deleted successfully!")
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
                department_name: event.target.buildingDepart.value,
                no_of_floors: event.target.num_of_floor.value,
                no_of_rooms: 0
            };
            createBuilding(roomData);
        };

        const handleModifySubmit = (event) => {
            event.preventDefault();
            if (event.target.buildingSelect.value === "") {
                toast.error('Please select building')
            } else {
                const buildingId = event.target.buildingSelect.value;
                const updatedData = {
                    department_name: event.target.departmentNameModify.value,
                    no_of_floors: event.target.numfloorsModify.value
                };
                modifyBuilding(buildingId, updatedData);
            }
        };

        const handleBuildingSelectChange = (event) => {
            const selectedBuildingId = event.target.value;
            const selectedBuilding = buildings.find((building) => building.building_id === selectedBuildingId)
            if (selectedBuilding) {
                console.log(selectedBuilding.department_name);
                document.getElementById('departmentNameModify').value = selectedBuilding.department_name;
                document.getElementById('numfloorsModify').value = selectedBuilding.no_of_floors;
            }
        };

        const handleDeleteSubmit = (event) => {
            event.preventDefault();
            const buildingId = event.target.buildingDelete.value;
            deleteBuilding(buildingId);
        };

        if (loading) return <p>Loading...</p>;
        if (error) return <p>Error: {error}</p>;

        return (
            <div className="d-flex flex-column min-vh-100">
                <header className="mb-4 p-3" style={{ backgroundColor: '#2c3e50', color: 'white' }}>
                    <div className="d-flex justify-content-between align-items-center">
                        <h2>Building Management</h2>
                        <div>
                            <button
                                className="btn btn-primary mx-2"
                                onClick={() => handleButtonClick('viewBuildings')}
                            >
                                View Buildings
                            </button>
                            <button
                                className="btn btn-success mx-2"
                                onClick={() => handleButtonClick('createBuilding')}
                            >
                                Create Buildings
                            </button>
                            <button
                                className="btn btn-warning mx-2"
                                onClick={() => handleButtonClick('modifyBuilding')}
                            >
                                Modify Buildings
                            </button>
                            <button
                                className="btn btn-danger mx-2"
                                onClick={() => handleButtonClick('deleteBuilding')}
                            >
                                Delete Buildings
                            </button>
                        </div>
                    </div>
                </header>

                <main className="flex-grow-1">
                    <div className="mt-5 p-4" style={{ padding: '20px' }}>
                        {activeForm === 'viewBuildings' && (
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
                                            <th>Building ID</th>
                                            <th>Building Name</th>
                                            <th>Number of Floors</th>
                                            <th>Number of Rooms</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        {buildings.map((building) => (
                                            <tr key={building.building_id}>
                                                <td>{building.building_id}</td>
                                                <td>{building.department_name}</td>
                                                <td>{building.no_of_floors}</td>
                                                <td>{building.no_of_rooms}</td>
                                            </tr>
                                        ))}
                                    </tbody>
                                </table>
                            </div>
                        )}
                        {(activeForm === 'createBuilding' || activeForm === 'modifyBuilding' || activeForm === 'deleteBuilding') && (
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
                                    {activeForm === 'createBuilding' && (
                                        <div>
                                            <h4>Create Building</h4>
                                            <form onSubmit={handleCreateSubmit}>
                                                <div className="mb-3">
                                                    <label htmlFor="buildingDepart" className="form-label">Building Department</label>
                                                    <input type="string" id="buildingDepart" className="form-control" required />
                                                </div>
                                                <div className="mb-3">
                                                    <label htmlFor="num_of_floor" className="form-label">Number of Floors</label>
                                                    <input type="number" id="num_of_floor" className="form-control" required />
                                                </div>
                                                <button type="submit" className="btn btn-success w-100" sub>
                                                    Create
                                                </button>
                                            </form>
                                        </div>
                                    )}
                                    {activeForm === 'modifyBuilding' && (
                                        <div>
                                            <h4>Modify Building</h4>
                                            <form onSubmit={handleModifySubmit}>
                                                <div className="mb-3">
                                                    <label htmlFor="buildingSelect" className="form-label">Select Building</label>
                                                    <select id="buildingSelect" className="form-select" onChange={handleBuildingSelectChange}>
                                                        <option value="">Choose a building...</option>
                                                        {buildings.map((building) => (
                                                            <option key={building.building_id} value={building.building_id}>
                                                                {building.department_name}
                                                            </option>
                                                        ))}
                                                    </select>
                                                </div>
                                                <div className="mb-3">
                                                    <label htmlFor="departmentNameModify" className="form-label">Department Namne</label>
                                                    <input type="string" id="departmentNameModify" className="form-control" />
                                                </div>
                                                <div className="mb-3">
                                                    <label htmlFor="numfloorsModify" className="form-label">Number of Floors</label>
                                                    <input type="number" id="numfloorsModify" className="form-control" required />
                                                </div>
                                                <button type="submit" className="btn btn-warning w-100">
                                                    Modify
                                                </button>
                                            </form>
                                        </div>
                                    )}
                                    {activeForm === 'deleteBuilding' && (
                                        <div>
                                            <h4>Delete Building</h4>
                                            <form onSubmit={handleDeleteSubmit}>
                                                <div className="mb-3">
                                                    <label htmlFor="buildingDelete" className="form-label">Select Building</label>
                                                    <select id="buildingDelete" className="form-select">
                                                        <option value="">Choose a Building...</option>
                                                        {buildings.map((building) => (
                                                            <option key={building.building_id} value={building.building_id}>
                                                                {building.department_name}
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
    }
};
