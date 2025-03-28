import React, { useEffect, useState } from 'react'
import { Link, useNavigate } from 'react-router-dom';
import { toast } from 'react-toastify';
import Cookies from 'js-cookie';
import { getAllResourcesApi, bookRoomApi, userGetResourceApi, rentResourceApi } from '../../services/api';

export const Resources = () => {
    const [selectedCategory, setSelectedCategory] = useState(''); // for storing the selected category ('Hardware' or 'Books')
    const [options, setOptions] = useState([]); // for storing options fetched from the API
    const [showTable, setShowTable] = useState(false); // control the table visibility
    const [tableData, setTableData] = useState([]);
    const [selectedResourceId, setSelectedResourceId] = useState(''); // store the selected resource id

    const handleCategoryChange = async (event) => {
        const selectedValue = event.target.value;
        setSelectedCategory(selectedValue);
        try {
            const response = await getAllResourcesApi();
            let data = response.data;
            let filteredData = [];
            if (selectedValue === 'Hardware') {
                filteredData = data.filter(item => item.resource_type === "hardware");
            } else if (selectedValue === 'Books') {
                filteredData = data.filter(item => item.resource_type === "books");
            }
            setOptions(filteredData);
        } catch (error) {
            console.error('Error fetching options:', error);
        }
    };

    const navigate = useNavigate();

    const handleSearch = async () => {
        if (!selectedResourceId) {
            toast.error('Please select a resource');
            return;
        }
        try {
            const roomData = {
                resource_id: selectedResourceId,
            };
            const response = await userGetResourceApi(roomData);
            setTableData(response.data);
            setShowTable(true);
        } catch (error) {
            toast.error('Resource not available for booking')
        }
    };

    const handleSelect = async () => {
        if (!selectedResourceId) {
            toast.error('Please select a resource');
            return;
        }
        const currentDate = new Date();
        const returnDate = new Date(currentDate);
        returnDate.setDate(currentDate.getDate() + 7);
        const roomData = {
            resource_id: selectedResourceId,
            user_id: JSON.parse(Cookies.get('user')).user_id,
            reservation_date: currentDate.toISOString().split('T')[0],
            return_date: returnDate.toISOString().split('T')[0]
        };
        try {
            const response = await rentResourceApi(roomData);
            toast.success('Resource Rented');
            navigate('/user');
        } catch (err) {
            toast.error('Something went wrong');
        }
    };

    return (
        <div className="d-flex flex-column min-vh-100">
            <header className="mb-4 p-3" style={{ backgroundColor: '#2c3e50', color: 'white' }}>
                <div className="d-flex justify-content-between align-items-center">
                    <h2>Resource Management</h2>
                </div>
            </header>

            <main className="flex-grow-1">
                <div className="d-flex justify-content-center mb-4">
                    <div className="d-flex flex-column me-3" style={{ minWidth: '150px' }}>
                        <label htmlFor="category" className="mb-2">Category</label>
                        <select
                            id="category"
                            className="form-select"
                            value={selectedCategory}
                            onChange={handleCategoryChange}
                        >
                            <option value="">Select Category</option>
                            <option value="Hardware">Hardware</option>
                            <option value="Books">Books</option>
                        </select>
                    </div>

                    {selectedCategory && (
                        <div className="d-flex flex-column me-3" style={{ minWidth: '150px' }}>
                            <label htmlFor="subCategory" className="mb-2">{selectedCategory}</label>
                            <select
                                id="subCategory"
                                className="form-select"
                                value={selectedResourceId}
                                onChange={(e) => setSelectedResourceId(e.target.value)} // update resource_id when selected
                            >
                                <option value="">Select {selectedCategory}</option>
                                {options.map((option, index) => (
                                    <option key={index} value={option.resource_id}>
                                        {option.resource_name}
                                    </option>
                                ))}
                            </select>
                        </div>
                    )}

                    {/* Search Button */}
                    <div className="d-flex align-items-center mt-4">
                        <button className="btn btn-primary" onClick={handleSearch}>
                            Search
                        </button>
                    </div>
                </div>
                {
                    tableData.length == 0 ? <h2 color='red'>Resources not available or selected.</h2> : <></>
                }
                {selectedCategory === 'Hardware' && tableData.length > 0 && (
                    <div className="mt-4">
                        <h3>Hardware Resources</h3>
                        <table className="table table-bordered">
                            <thead>
                                <tr>
                                    <th>Hardware Name</th>
                                    <th>Device Type</th>
                                    <th>Model Number</th>
                                    <th>Rent Hardware</th>
                                    {/* Add other columns if needed */}
                                </tr>
                            </thead>
                            <tbody>
                                {tableData.map((item, index) => (
                                    <tr key={index}>
                                        <td>{item.resource_name}</td>
                                        <td>{item.device_type}</td>
                                        <td>{item.model_number}</td>
                                        <td>
                                            <button className="btn btn-success" onClick={() => handleSelect()}>Rent</button>
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                )}

                {selectedCategory === 'Books' && tableData.length > 0 && (
                    <div className="mt-4">
                        <h3>Book Resources</h3>
                        <table className="table table-bordered">
                            <thead>
                                <tr>
                                    <th>Book Name</th>
                                    <th>Description</th>
                                    <th>Author</th>
                                    <th>Rent Book</th>
                                </tr>
                            </thead>
                            <tbody>
                                {tableData.map((item, index) => (
                                    <tr key={index}>
                                        <td>{item.resource_name}</td>
                                        <td>{item.description}</td>
                                        <td>{item.author}</td>
                                        <td>
                                            <button className="btn btn-success" onClick={() => handleSelect()}>Rent</button>
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
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
