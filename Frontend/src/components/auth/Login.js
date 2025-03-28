import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import Cookies from 'js-cookie';
import { loginUser } from '../../services/api';
import { toast } from 'react-toastify';

const Login = () => {
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const navigate = useNavigate();

    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            const credentials = {
                email: email,
                password: password
            };
            const response = await loginUser(credentials);

            if (response.status === 404) {
                toast.error("Invalid credentials");
            } else if (response.status === 200) {
                const data = response.data[0];
                Cookies.set('user', JSON.stringify(data), { expires: 7 });
                if (data.user_role === 'Admin') {
                    toast.success('Admin Login Successful')
                    navigate("/admin");
                } else {
                    toast.success('Student Login Successful')
                    navigate("/user");
                }
            }
        } catch (error) {
            toast.error("Invalid Credentials Entered");
        }
    };

    return (
        <div className="container vh-100 d-flex align-items-center justify-content-center">
            <div className="card p-4 shadow" style={{ width: '24rem' }}>
                <h3 className="card-title text-center mb-4">Login</h3>
                <form onSubmit={handleSubmit}>
                    <div className="mb-3">
                        <label htmlFor="email" className="form-label">Email address</label>
                        <input
                            type="email"
                            id="email"
                            className="form-control"
                            value={email}
                            onChange={(e) => setEmail(e.target.value)}
                            required
                        />
                    </div>
                    <div className="mb-3">
                        <label htmlFor="password" className="form-label">Password</label>
                        <input
                            type="password"
                            id="password"
                            className="form-control"
                            value={password}
                            onChange={(e) => setPassword(e.target.value)}
                            required
                        />
                    </div>
                    <button type="submit" className="btn btn-primary w-100">Login</button>
                </form>
                <p className="text-center mt-3">
                    Don't have an account? Contact Student Hub Administrator
                </p>
            </div>
        </div>
    );
};

export default Login;
