import React, { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import Cookies from 'js-cookie';

const Logout = () => {
    const navigate = useNavigate();

    useEffect(() => {
        console.log(Cookies.get("user"));
        Cookies.remove('user');
        navigate('/login');
    }, [navigate]);

    return null; // No UI is needed, as the effect handles everything
};

export default Logout;
