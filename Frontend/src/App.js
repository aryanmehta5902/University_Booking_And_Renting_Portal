import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider } from './context/AuthContext';  // Import the context
import Login from './components/auth/Login';
import Signup from './components/auth/Signup';
import { UserDashboard } from './components/user/UserDashboard';
import { AdminDashboard } from './components/admin/AdminDashboard';
import { RoomsPage } from './components/admin/RoomsPage';
import ProtectedRoute from './components/auth/ProtectedRoute';
import { ViewFeedbacks } from './components/admin/ViewFeedbacks';
import { ToastContainer } from 'react-toastify';
import { BuildingPage } from './components/admin/BuildingPage';
import Logout from './components/auth/Logout';
import ManageResources from './components/admin/ManageResources';
import { ManagePolicy } from './components/admin/ManagePolicy';
import { Rooms } from './components/user/Rooms';
import { Resources } from './components/user/Resources';
import { Feedbacks } from './components/user/Feedbacks';

function App() {
  return (
    <AuthProvider>
      <ToastContainer
        position="top-center"
        autoClose={5000}
        hideProgressBar={false}
        newestOnTop={false}
        closeOnClick
        rtl={false}
        pauseOnFocusLoss
        draggable
        pauseOnHover
      />

      <Router>
        <Routes>
          <Route path="/login" element={<Login />} />
          <Route path="/logout" element={<Logout />} />
          <Route path="/signup" element={<Signup />} />

          {/* Admin Routes */}
          <Route
            path="/admin"
            element={
              <ProtectedRoute requiredRole="Admin">
                <AdminDashboard />
              </ProtectedRoute>
            }
          />
          <Route
            path="/admin/rooms"
            element={
              <ProtectedRoute requiredRole="Admin">
                <RoomsPage />
              </ProtectedRoute>
            }
          />

          <Route
            path="/admin/building"
            element={
              <ProtectedRoute requiredRole="Admin">
                <BuildingPage />
              </ProtectedRoute>
            }
          />

          <Route
            path="/admin/feedbacks"
            element={
              <ProtectedRoute requiredRole="Admin">
                <ViewFeedbacks />
              </ProtectedRoute>
            }
          />

          <Route
            path="/admin/resources"
            element={
              <ProtectedRoute requiredRole="Admin">
                <ManageResources />
              </ProtectedRoute>
            }
          />

          <Route
            path="/admin/policy"
            element={
              <ProtectedRoute requiredRole="Admin">
                <ManagePolicy />
              </ProtectedRoute>
            }
          />

          {/* User Routes */}
          <Route
            path="/user"
            element={
              <ProtectedRoute requiredRole="Student">
                <UserDashboard />
              </ProtectedRoute>
            }
          />

          <Route
            path="/user/rooms"
            element={
              <ProtectedRoute requiredRole="Student">
                <Rooms />
              </ProtectedRoute>
            }
          />

          <Route
            path="/user/resources"
            element={
              <ProtectedRoute requiredRole="Student">
                <Resources />
              </ProtectedRoute>
            }
          />

          <Route
            path="/user/feedbacks"
            element={
              <ProtectedRoute requiredRole="Student">
                <Feedbacks />
              </ProtectedRoute>
            }
          />

          <Route path="*" element={<Navigate to="/login" />} />
        </Routes>
      </Router>
    </AuthProvider>
  );
}

export default App;
