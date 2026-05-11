'use client';

import Link from 'next/link';

export default function LoginPage() {
  return (
    <div style={{ 
      minHeight: '100vh', 
      display: 'flex', 
      alignItems: 'center', 
      justifyContent: 'center',
      padding: '1rem'
    }}>
      <div className="card animate-fade" style={{ maxWidth: '450px', width: '100%', padding: '3rem' }}>
        <div style={{ textAlign: 'center', marginBottom: '2.5rem' }}>
          <div style={{ 
            width: '64px', 
            height: '64px', 
            background: 'var(--bg-soft)', 
            borderRadius: '20px', 
            display: 'flex', 
            alignItems: 'center', 
            justifyContent: 'center',
            margin: '0 auto 1.5rem auto'
          }}>
            <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="var(--primary)" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
              <path d="M12 3v19M5 8h14M12 12a4 4 0 1 0 0-8 4 4 0 0 0 0 8z" />
            </svg>
          </div>
          <h1 style={{ fontSize: '2rem', marginBottom: '0.5rem' }}>AgroSentry</h1>
          <p style={{ color: 'var(--text-secondary)' }}>Empowering Farmers with AI</p>
        </div>

        <div className="input-group">
          <label>Email Address</label>
          <input type="email" placeholder="farmer@example.com" defaultValue="demo@agrosentry.ai" />
        </div>

        <div className="input-group">
          <label>Password</label>
          <input type="password" placeholder="••••••••" defaultValue="password123" />
        </div>

        <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '2rem', fontSize: '0.85rem' }}>
          <label style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', cursor: 'pointer' }}>
            <input type="checkbox" defaultChecked style={{ accentColor: 'var(--primary)' }} />
            Remember me
          </label>
          <a href="#" style={{ color: 'var(--primary)', fontWeight: '600' }}>Forgot password?</a>
        </div>

        <Link href="/" className="btn btn-primary" style={{ width: '100%', marginBottom: '1.5rem' }}>
          Sign In
        </Link>

        <p style={{ textAlign: 'center', fontSize: '0.9rem', color: 'var(--text-secondary)' }}>
          Don't have an account? <a href="#" style={{ color: 'var(--primary)', fontWeight: '600' }}>Join the community</a>
        </p>
      </div>
    </div>
  );
}
