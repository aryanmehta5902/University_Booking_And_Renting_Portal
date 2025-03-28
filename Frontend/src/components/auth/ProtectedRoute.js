import React from 'react';
import { Navigate } from 'react-router-dom';
import Cookies from 'js-cookie';

const ProtectedRoute = ({ children, requiredRole }) => {
    const user = JSON.parse(Cookies.get('user') || null);

    if (!user) {
        return <Navigate to="/login" />;
    }

    if (requiredRole && user.user_role !== requiredRole) {
        if (user.user_role == 'Student') {
            return <Navigate to={`/user`} />;
        }
        if (user.user_role == 'Admin') {
            return <Navigate to={`/admin`} />;
        }

    }

    return children;
};

export default ProtectedRoute;
