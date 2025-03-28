import React, { createContext, useState } from 'react';

// Creating the AuthContext for managing user authentication
export const AuthContext = createContext();

export const AuthProvider = ({ children }) => {
    const [user, setUser] = useState(null);  // Track logged-in user

    // Login function that updates the user object
    const login = (userData) => {
        console.log("Logging in user:", userData);  // Log to check userData
        setUser(userData);
    };

    // Logout function that resets the user object
    const logout = () => setUser(null);

    return (
        <AuthContext.Provider value={{ user, login, logout }}>
            {children}
        </AuthContext.Provider>
    );
};
