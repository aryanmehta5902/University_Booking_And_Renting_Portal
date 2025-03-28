import axios from 'axios';

const AdminAPI = axios.create({ baseURL: 'http://127.0.0.1:8000' });

export const getRoomsApi = () => AdminAPI.get('/admins/rooms/');
export const createRoomApi = (data) => AdminAPI.post('/admins/rooms/', data);
export const modifyRoomApi = (id, data) => AdminAPI.put(`/admins/rooms/${id}/`, data);
export const deleteRoomApi = (id) => AdminAPI.delete(`/admins/rooms/${id}/`);

export const getAllBuildingsApi = () => AdminAPI.get('/admins/buildings/');
export const createBuildingApi = (data) => AdminAPI.post('/admins/buildings/', data);
export const modifyBuildingApi = (id, data) => AdminAPI.put(`/admins/buildings/${id}/`, data);
export const deleteBuildingApi = (id) => AdminAPI.delete(`/admins/buildings/${id}/`);

export const getAllResourcesApi = () => AdminAPI.get('/admins/resources-details/');
export const createResourceApi = (data) => AdminAPI.post('/admins/resources-details/', data);
export const modifyResourceApi = (id, data) => AdminAPI.put(`/admins/resources-details/${id}/`, data);
export const deleteResourceApi = (id) => AdminAPI.delete(`/admins/resources/${id}/`);

export const getAllPolicyApi = () => AdminAPI.get('/admins/room-policies/')
export const createPolicyApi = (data) => AdminAPI.post('/admins/room-policies/', data);
export const modifyPolicyApi = (id, data) => AdminAPI.put(`/admins/room-policies/${id}/`, data);
export const deletePolicyApi = (id) => AdminAPI.delete(`/admins/room-policies/${id}/`);

export const feedbackRoomsApi = () => AdminAPI.get('/admins/feedbacks_rooms/')
export const feedbackResourcesApi = () => AdminAPI.get('/admins/feedbacks_resources/')

export const userGetRoomApi = (data) => AdminAPI.post('/users/room_list/', data)
export const bookRoomApi = (data) => AdminAPI.post('/users/insert_room_user/', data)

export const userGetResourceApi = (data) => AdminAPI.post('/users/resource_available/', data)
export const rentResourceApi = (data) => AdminAPI.post('/users/rent/', data)

export const getRoomsAllBuildingApi = () => AdminAPI.get('/users/room-building-data/')

export const addFeedbacksResources = (data) => AdminAPI.post('/users/give_feedback_resources/', data)
export const addFeedbacksRoom = (data) => AdminAPI.post('/users/give_feedback_room/', data)

export const userDashboardReservation = (data) => AdminAPI.post('/users/upcoming-reservations/', data)
export const userDashboardResouces = (data) => AdminAPI.post('/users/upcoming-resources/', data)

export const adminDashboardReservation = () => AdminAPI.get('/admins/rented-rooms/')
export const adminDashboardResource = () => AdminAPI.get('/admins/rented-resources/')

export const loginUser = (credentials) => AdminAPI.post('/login_verification/', credentials);
export const signupUser = (data) => AdminAPI.post('/signup', data);
