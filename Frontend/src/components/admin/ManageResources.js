import React, { useEffect, useState } from 'react'
import { createResourceApi, deleteResourceApi, getAllResourcesApi, getRoomsApi, modifyResourceApi } from '../../services/api';
import { toast } from 'react-toastify';
import { Link } from 'react-router-dom';

const ManageResources = () => {
    const [activeForm, setActiveForm] = useState('viewResources');
    const [viewType, setViewType] = useState('Hardware');
    const [resources, setResources] = useState([]);
    const [bookresources, setbookResources] = useState([]);
    const [hardwareresources, sethardwareResources] = useState([]);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState(null);

    const fetchAllResources = async () => {
        try {
            setLoading(true);
            const response = await getAllResourcesApi();
            setResources(response.data)

            const hardwareResources = [];
            const bookResources = [];
            response.data.forEach(resource => {
                if (resource.resource_type === 'hardware') {
                    hardwareResources.push({
                        resource_id: resource.resource_id,
                        resource_name: resource.resource_name,
                        resource_type: resource.resource_type,
                        warranty_status: resource.warranty_status,
                        model_number: resource.model_number,
                        device_type: resource.device_type,
                        device_condition: resource.device_condition,
                        date_purchased: resource.date_purchased
                    });
                } else if (resource.resource_type === 'books') {
                    bookResources.push({
                        resource_id: resource.resource_id,
                        resource_name: resource.resource_name,
                        resource_type: resource.resource_type,
                        author: resource.author,
                        description: resource.description,
                        language: resource.language
                    });
                }
            });

            setbookResources(bookResources)
            sethardwareResources(hardwareResources)
            setLoading(false);
        } catch (err) {
            setError(err.message);
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchAllResources();
    }, []);

    const createResource = async (resourceData) => {
        try {
            await createResourceApi(resourceData);
            fetchAllResources();
            setActiveForm('viewResources');
            toast.success('Resource created successfully!')
        } catch (err) {
            console.log(err);
            setError(err.message)
        }
    }

    const modifyResource = async (resourceId, updatedData) => {
        try {
            if (resourceId == null) {
                toast.error('Please select resource')
            } else {
                await modifyResourceApi(resourceId, updatedData);
                fetchAllResources();
                setActiveForm("viewResources")
                toast.success('Resource modified successfully!');
            }

        } catch (err) {
            setError(err.message);
        }
    };

    const deleteResource = async (resourceId) => {
        try {
            await deleteResourceApi(resourceId);
            fetchAllResources();
            setActiveForm('viewResources');
            toast.success('Resource deleted successfully!')
        } catch (err) {
            setError(err.message)
        }
    }

    const handleButtonClick = (form) => {
        setActiveForm(form);
    }
    const handleViewTypeChange = (event) => {
        setViewType(event.target.value);
    };

    const handleCreateSubmit = (event) => {
        event.preventDefault();
        let resourceForm;
        if (viewType === 'Hardware') {
            resourceForm = {
                resource_name: event.target.resourceName.value,
                availability_status: event.target.availableStatus.value ? 1 : 0,
                quantity_required: event.target.quantity.value,
                device_type: event.target.deviceType.value,
                model_number: event.target.modelNumber.value,
                device_condition: event.target.deviceCondition.value,
                warranty_status: event.target.warrantyStatus.value ? 1 : 0,
                date_purchased: event.target.datePurchased.value,
                resource_type: 'hardware',
                hardware_flag: true
            }

        } else {
            resourceForm = {
                resource_name: event.target.resourceName.value,
                availability_status: event.target.availableStatus.value ? 1 : 0,
                quantity_required: event.target.quantity.value,
                author: event.target.author.value,
                description: event.target.description.value,
                language: event.target.language.value,
                resource_type: 'books',
                books_flag: true,
            }
        }
        createResource(resourceForm);
    }

    const handleModifySubmit = (event) => {
        event.preventDefault();
        if (event.target.resourceSelect.value === "") {
            toast.error('Please select resource')
        } else {
            const resourceId = event.target.resourceSelect.value;
            let resourceForm;
            if (viewType === 'Hardware') {
                resourceForm = {
                    device_type: event.target.deviceModify.value,
                    model_number: event.target.modelModify.value,
                    device_condition: event.target.conditionModify.value,
                    warranty_status: event.target.warrantyModify.value === true ? 1 : 0,
                    date_purchased: event.target.dateModify.value,
                    hardware_flag: true
                }
            } else {
                resourceForm = {
                    author: event.target.authorModify.value,
                    publisher: event.target.descriptionModify.value,
                    language: event.target.languageModify.value,
                    books_flag: true,
                }
            }
            modifyResource(resourceId, resourceForm)
        }
    }

    const handleResourceSelectChange = (event) => {
        const selectedResourceId = event.target.value;
        const selectedResource = resources.find((resource) => resource.resource_id === selectedResourceId)
        if (selectedResource) {
            if (viewType == 'Hardware') {
                document.getElementById('deviceModify').value = selectedResource.device_type
                document.getElementById('modelModify').value = selectedResource.model_number
                document.getElementById('conditionModify').value = selectedResource.device_condition
                document.getElementById('warrantyModify').value = selectedResource.warranty_status === 1 ? true : false
                document.getElementById('dateModify').value = selectedResource.date_purchased
            } else {
                document.getElementById('authorModify').value = selectedResource.author
                document.getElementById('descriptionModify').value = selectedResource.description
                document.getElementById('languageModify').value = selectedResource.language
            }
        }
    }

    const handleDeleteSubmit = (event) => {
        event.preventDefault();
        const resourceId = event.target.resourceDelete.value;
        deleteResource(resourceId);
    }

    if (loading) return <p>Loading...</p>;
    if (error) return <p>Error: {error}</p>;

    return (
        <div className="d-flex flex-column min-vh-100">
            <header className="mb-4 p-3" style={{ backgroundColor: '#2c3e50', color: 'white' }}>
                <div className="d-flex justify-content-between align-items-center">
                    <h2>Resource Management</h2>
                    <div>
                        <button
                            className="btn btn-primary mx-2"
                            onClick={() => handleButtonClick('viewResources')}
                        >
                            View Resource
                        </button>
                        <button
                            className="btn btn-success mx-2"
                            onClick={() => handleButtonClick('createResources')}
                        >
                            Create Resource
                        </button>
                        <button
                            className="btn btn-warning mx-2"
                            onClick={() => handleButtonClick('modifyResources')}
                        >
                            Modify Resource
                        </button>
                        <button
                            className="btn btn-danger mx-2"
                            onClick={() => handleButtonClick('deleteResources')}
                        >
                            Delete Resource
                        </button>
                    </div>
                </div>
            </header>
            <main className="flex-grow-1">
                <div className="mt-5 p-4" style={{ padding: '20px' }}>
                    {activeForm === 'viewResources' && (
                        <div>
                            <h4>View Resource</h4>
                            <div className="mb-3">
                                <label htmlFor="viewType" className="form-label">Select Resource Type:</label>
                                <select
                                    id="viewType"
                                    className="form-select"
                                    value={viewType}
                                    onChange={handleViewTypeChange}
                                >
                                    <option value="Hardware">Hardware</option>
                                    <option value="Book">Book</option>
                                </select>
                            </div>
                            <table className="table table-bordered table-hover"
                                style={{
                                    backgroundColor: '#d6d6d6',
                                    borderRadius: '8px',
                                    boxShadow: '0 4px 8px rgba(0, 0, 0, 0.2)'
                                }}
                            >
                                <thead className="thead-dark">
                                    {viewType === 'Hardware' ? (
                                        <tr>
                                            <th>Resource Name</th>
                                            <th>Device Type</th>
                                            <th>Model Number</th>
                                            <th>Condition</th>
                                            <th>Warranty</th>
                                            <th>Date Purchased</th>
                                        </tr>
                                    ) : (
                                        <tr>
                                            <th>Resource Name</th>
                                            <th>Author</th>
                                            <th>Description</th>
                                            <th>Language</th>
                                        </tr>
                                    )}
                                </thead>
                                <tbody>
                                    {viewType === 'Hardware' && (
                                        hardwareresources.map((resource) => {
                                            return (
                                                <tr key={resource.resource_id}>
                                                    <td>{resource.resource_name}</td>
                                                    <td>{resource.device_type}</td>
                                                    <td>{resource.model_number}</td>
                                                    <td>{resource.device_condition}</td>
                                                    <td>{resource.warranty_status ? "Yes" : "No"}</td>
                                                    <td>{resource.date_purchased}</td>
                                                </tr>
                                            );
                                        })
                                    )}
                                    {viewType === 'Book' && (
                                        bookresources.map((resource) => {
                                            return (
                                                <tr key={resource.resource_id}>
                                                    <td>{resource.resource_name}</td>
                                                    <td>{resource.author}</td>
                                                    <td>{resource.description}</td>
                                                    <td>{resource.language}</td>
                                                </tr>
                                            );
                                        })
                                    )}
                                </tbody>

                            </table>
                        </div>
                    )}
                    {(activeForm === 'createResources' || activeForm === 'modifyResources' || activeForm === 'deleteResources') && (
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
                                {activeForm === 'createResources' && (
                                    <div>
                                        <h4>Create Resource</h4>
                                        <div className="mb-3">
                                            <label htmlFor="createType" className="form-label">Select Resource Type:</label>
                                            <select
                                                id="createType"
                                                className="form-select"
                                                value={viewType}
                                                onChange={handleViewTypeChange}
                                            >
                                                <option value="Hardware">Hardware</option>
                                                <option value="Book">Book</option>
                                            </select>
                                        </div>
                                        <form onSubmit={handleCreateSubmit}>
                                            {viewType === 'Hardware' ? (
                                                <>
                                                    <div className="mb-3">
                                                        <label htmlFor="resourceName" className="form-label">Resource Name</label>
                                                        <input type="text" className="form-control" id="resourceName" required />
                                                    </div>
                                                    <div className="mb-3">
                                                        <label htmlFor="availableStatus" className="form-label">Availability Status</label>
                                                        <select id="availableStatus" className="form-select" required>
                                                            <option value={true}>Yes</option>
                                                            <option value={false}>No</option>
                                                        </select>
                                                    </div>
                                                    <div className="mb-3">
                                                        <label htmlFor="quantity" className="form-label">Quantity</label>
                                                        <input type="number" className="form-control" id="quantity" required />
                                                    </div>
                                                    <div className="mb-3">
                                                        <label htmlFor="brand" className="form-label">Brand</label>
                                                        <input type="text" className="form-control" id="brand" required />
                                                    </div>
                                                    <div className="mb-3">
                                                        <label htmlFor="deviceType" className="form-label">Device Type</label>
                                                        <input type="text" className="form-control" id="deviceType" required />
                                                    </div>
                                                    <div className="mb-3">
                                                        <label htmlFor="modelNumber" className="form-label">Model Number</label>
                                                        <input type="text" className="form-control" id="modelNumber" required />
                                                    </div>
                                                    <div className="mb-3">
                                                        <label htmlFor="deviceCondition" className="form-label">Condition</label>
                                                        <input type="text" className="form-control" id="deviceCondition" required />
                                                    </div>
                                                    <div className="mb-3">
                                                        <label htmlFor="warrantyStatus" className="form-label">Warranty Status</label>
                                                        <select id="warrantyStatus" className="form-select" required>
                                                            <option value={true}>Yes</option>
                                                            <option value={false}>No</option>
                                                        </select>
                                                    </div>
                                                    <div className="mb-3">
                                                        <label htmlFor="datePurchased" className="form-label">Date Purchased</label>
                                                        <input type="date" className="form-control" id="datePurchased" required />
                                                    </div>
                                                </>
                                            ) : (
                                                <>
                                                    <div className="mb-3">
                                                        <label htmlFor="resourceName" className="form-label">Resource Name</label>
                                                        <input type="text" className="form-control" id="resourceName" required />
                                                    </div>
                                                    <div className="mb-3">
                                                        <label htmlFor="availableStatus" className="form-label">Availability Status</label>
                                                        <select id="availableStatus" className="form-select" required>
                                                            <option value={true}>Yes</option>
                                                            <option value={false}>No</option>
                                                        </select>
                                                    </div>
                                                    <div className="mb-3">
                                                        <label htmlFor="quantity" className="form-label">Quantity</label>
                                                        <input type="number" className="form-control" id="quantity" required />
                                                    </div>
                                                    <div className="mb-3">
                                                        <label htmlFor="author" className="form-label">Author</label>
                                                        <input type="text" className="form-control" id="author" required />
                                                    </div>
                                                    <div className="mb-3">
                                                        <label htmlFor="description" className="form-label">description</label>
                                                        <input type="text" className="form-control" id="description" required />
                                                    </div>
                                                    <div className="mb-3">
                                                        <label htmlFor="language" className="form-label">Language</label>
                                                        <input type="text" className="form-control" id="language" />
                                                    </div>
                                                </>
                                            )}
                                            <button type="submit" className="btn btn-primary">Create Resource</button>
                                        </form>
                                    </div>
                                )}
                                {activeForm === 'modifyResources' && (
                                    <div>
                                        <h4>Modify Resource</h4>
                                        <form onSubmit={handleModifySubmit}>
                                            <div className="mb-3">
                                                <label htmlFor="resourceSelect1" className="form-label">Select Resource to Modify:</label>
                                                <select
                                                    id="viewType"
                                                    className="form-select"
                                                    value={viewType}
                                                    onChange={handleViewTypeChange}
                                                >
                                                    <option value="Hardware">Hardware</option>
                                                    <option value="Book">Book</option>
                                                </select>
                                            </div>
                                            <div className="mb-3">
                                                <label htmlFor="resourceSelect" className="form-label">Select Resource</label>
                                                <select id="resourceSelect" className="form-select" onChange={handleResourceSelectChange}>
                                                    <option value="">Choose a Resource...</option>
                                                    {resources
                                                        .filter(resource =>
                                                            viewType === 'Hardware' ? resource.resource_type === 'hardware' : resource.resource_type === 'books'
                                                        )
                                                        .map(resource => (
                                                            <option key={resource.resource_id} value={resource.resource_id}>
                                                                {resource.resource_name}
                                                            </option>
                                                        ))}
                                                </select>
                                            </div>
                                            {viewType === 'Hardware' ? (
                                                <>
                                                    <div className="mb-3">
                                                        <label htmlFor="deviceModify" className="form-label">Device Type</label>
                                                        <input type="text" className="form-control" id="deviceModify" required />
                                                    </div>
                                                    <div className="mb-3">
                                                        <label htmlFor="modelModify" className="form-label">Model Number</label>
                                                        <input type="text" className="form-control" id="modelModify" required />
                                                    </div>
                                                    <div className="mb-3">
                                                        <label htmlFor="conditionModify" className="form-label">Condition</label>
                                                        <input type="text" className="form-control" id="conditionModify" required />
                                                    </div>
                                                    <div className="mb-3">
                                                        <label htmlFor="warrantyModify" className="form-label">Warranty Status</label>
                                                        <select id="warrantyModify" className="form-select" required>
                                                            <option value={true}>Yes</option>
                                                            <option value={false}>No</option>
                                                        </select>
                                                    </div>
                                                    <div className="mb-3">
                                                        <label htmlFor="dateModify" className="form-label">Date Purchased</label>
                                                        <input type="date" className="form-control" id="dateModify" required />
                                                    </div>
                                                </>
                                            ) : (
                                                <>
                                                    <div className="mb-3">
                                                        <label htmlFor="authorModify" className="form-label">Author</label>
                                                        <input type="text" className="form-control" id="authorModify" required />
                                                    </div>
                                                    <div className="mb-3">
                                                        <label htmlFor="descriptionModify" className="form-label">Description</label>
                                                        <input type="text" className="form-control" id="descriptionModify" required />
                                                    </div>
                                                    <div className="mb-3">
                                                        <label htmlFor="languageModify" className="form-label">Language</label>
                                                        <input type="text" className="form-control" id="languageModify" />
                                                    </div>
                                                </>
                                            )}
                                            <button type="submit" className="btn btn-warning">Modify Resource</button>
                                        </form>
                                    </div>
                                )}
                                {activeForm === 'deleteResources' && (
                                    <div>
                                        <h4>Delete Room</h4>
                                        <form onSubmit={handleDeleteSubmit}>
                                            <div className="mb-3">
                                                <label htmlFor="resourceDelete" className="form-label">Select resource</label>
                                                <select id="resourceDelete" className="form-select">
                                                    <option value="">Choose a resource...</option>
                                                    {resources.map((resource) => (
                                                        <option key={resource.resource_id} value={resource.resource_id}>
                                                            {resource.resource_name}
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
                    )}
                </div>
            </main>
            <footer className="p-3" style={{ backgroundColor: '#2c3e50', color: 'white' }}>
                <div className="text-center">
                    <Link to="/admin" className="btn btn-secondary">
                        Back to Admin Dashboard
                    </Link>
                    <p>&copy; 2024 Room Management System. All rights reserved.</p>
                </div>
            </footer>
        </div>
    )
}

export default ManageResources