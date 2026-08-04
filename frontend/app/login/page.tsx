'use client';

import { useState } from 'react';
import Link from 'next/link';
import { Leaf, Mail, Lock, ArrowRight } from 'lucide-react';

export default function LoginPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    
    try {
      const formData = new URLSearchParams();
      formData.append('username', email);
      formData.append('password', password);

      const response = await fetch('http://localhost:8000/api/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: formData,
      });

      if (response.ok) {
        const data = await response.json();
        localStorage.setItem('token', data.access_token);
        // Force the app to completely re-render with the new auth state
        window.location.href = '/';
      } else {
        alert('Invalid credentials. Please try again.');
        setLoading(false);
      }
    } catch {
      alert('Error connecting to backend. Make sure the server is running on port 8000.');
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center p-4">
      <div className="w-full max-w-md animate-in">
        <div className="text-center mb-8">
          <div className="inline-flex items-center justify-center w-16 h-16 bg-primary rounded-2xl text-white shadow-xl shadow-primary/20 mb-4">
            <Leaf size={32} />
          </div>
          <h1 className="text-3xl font-bold text-gray-900">AgroSentry</h1>
          <p className="text-gray-500 mt-2">Sign in to manage your crop health</p>
        </div>

        <div className="card shadow-xl border-none">
          <form onSubmit={handleLogin} className="space-y-5">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1.5">Email Address</label>
              <div className="relative">
                <Mail className="absolute left-3 top-3.5 text-gray-400" size={18} />
                <input 
                  type="email" 
                  className="input pl-10" 
                  placeholder="name@example.com"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  required
                />
              </div>
            </div>

            <div>
              <div className="flex justify-between items-center mb-1.5">
                <label className="block text-sm font-medium text-gray-700">Password</label>
                <Link href="/forgot-password" className="text-xs text-primary hover:underline font-semibold">
                  Forgot Password?
                </Link>
              </div>
              <div className="relative">
                <Lock className="absolute left-3 top-3.5 text-gray-400" size={18} />
                <input 
                  type="password" 
                  className="input pl-10" 
                  placeholder="••••••••"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  required
                />
              </div>
            </div>

            <button 
              type="submit" 
              className="btn btn-primary w-full py-4 text-lg mt-2 group"
              disabled={loading}
            >
              {loading ? 'Authenticating...' : 'Sign In'}
              {!loading && <ArrowRight className="ml-2 group-hover:translate-x-1 transition-transform" size={20} />}
            </button>
          </form>

          <div className="mt-8 text-center border-t border-gray-50 pt-6">
            <p className="text-sm text-gray-600">
              Don&apos;t have an account?{' '}
              <Link href="/register" className="text-primary font-bold hover:underline">
                Create one for free
              </Link>
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
