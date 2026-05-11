'use client';

import Link from 'next/link';

export default function Dashboard() {
  return (
    <div className="animate-fade">
      {/* Header Section */}
      <header style={{ marginBottom: '3rem', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div>
          <h1 style={{ fontSize: '2.5rem', marginBottom: '0.25rem' }}>Good morning, Mahi! 👋</h1>
          <p style={{ color: 'var(--text-secondary)', fontSize: '1.1rem' }}>Here's what's happening with your crops today.</p>
        </div>
        <Link href="/scan" className="btn btn-primary" style={{ padding: '1rem 2rem' }}>
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
            <path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z" /><circle cx="12" cy="13" r="4" />
          </svg>
          Start New Scan
        </Link>
      </header>

      {/* Stats Grid */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))', gap: '2rem', marginBottom: '3rem' }}>
        
        {/* Watering Schedule Widget */}
        <div className="card">
          <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '1.5rem' }}>
            <h3 style={{ fontSize: '1.1rem' }}>Watering Schedule</h3>
            <span style={{ padding: '0.25rem 0.75rem', background: 'var(--bg-soft)', borderRadius: '20px', fontSize: '0.8rem', color: 'var(--primary)', fontWeight: '700' }}>In 2 hours</span>
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '1rem', marginBottom: '1rem' }}>
            <div style={{ fontSize: '2.5rem' }}>💧</div>
            <div>
              <div style={{ fontSize: '1.2rem', fontWeight: '700' }}>Tomato Section A</div>
              <div style={{ color: 'var(--text-secondary)', fontSize: '0.9rem' }}>Optimal time: 10:30 AM</div>
            </div>
          </div>
          <div style={{ height: '8px', background: 'var(--bg-soft)', borderRadius: '4px', overflow: 'hidden' }}>
            <div style={{ width: '75%', height: '100%', background: 'var(--primary-light)' }}></div>
          </div>
        </div>

        {/* Crop Health Widget */}
        <div className="card">
          <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '1.5rem' }}>
            <h3 style={{ fontSize: '1.1rem' }}>Overall Health</h3>
            <span style={{ color: 'var(--primary)', fontWeight: '700' }}>92%</span>
          </div>
          <div style={{ display: 'flex', alignItems: 'flex-end', gap: '0.5rem', marginBottom: '1rem' }}>
            {[40, 60, 45, 90, 85, 92].map((h, i) => (
              <div key={i} style={{ flex: 1, height: `${h}px`, background: i === 5 ? 'var(--primary)' : 'var(--bg-soft)', borderRadius: '4px' }}></div>
            ))}
          </div>
          <p style={{ fontSize: '0.85rem', color: 'var(--text-secondary)' }}>Your crops are performing 12% better than last month.</p>
        </div>

        {/* Rotation Alert Widget */}
        <div className="card" style={{ background: 'var(--primary)', color: 'white' }}>
          <h3 style={{ color: 'white', fontSize: '1.1rem', marginBottom: '1rem' }}>Crop Rotation Tip</h3>
          <p style={{ fontSize: '0.95rem', marginBottom: '1.5rem', opacity: 0.9 }}>
            Consider planting legumes in Plot B after this harvest to naturally restore soil nitrogen levels.
          </p>
          <button className="btn" style={{ background: 'rgba(255,255,255,0.2)', color: 'white', width: '100%', border: '1px solid rgba(255,255,255,0.3)' }}>
            Learn More
          </button>
        </div>

      </div>

      {/* Recent Scans Section */}
      <section>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1.5rem' }}>
          <h2 style={{ fontSize: '1.5rem' }}>Recent Activity</h2>
          <Link href="/history" style={{ color: 'var(--primary)', fontWeight: '600', textDecoration: 'none' }}>View all history →</Link>
        </div>
        
        <div className="card" style={{ padding: 0, overflow: 'hidden' }}>
          {[
            { id: 1, plant: 'Tomato', disease: 'Healthy', date: '2 hours ago', status: 'Success' },
            { id: 2, plant: 'Potato', disease: 'Late Blight', date: 'Yesterday', status: 'Alert' },
            { id: 3, plant: 'Corn', disease: 'Common Rust', date: '3 days ago', status: 'Alert' },
          ].map((scan, i) => (
            <div key={scan.id} style={{ 
              padding: '1.25rem 2rem', 
              display: 'flex', 
              alignItems: 'center', 
              justifyContent: 'space-between',
              borderBottom: i === 2 ? 'none' : '1px solid var(--border-soft)',
              background: i % 2 === 0 ? 'transparent' : 'rgba(0,0,0,0.01)'
            }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '1.5rem' }}>
                <div style={{ width: '48px', height: '48px', borderRadius: '12px', background: 'var(--bg-soft)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '1.5rem' }}>
                  {scan.plant === 'Tomato' ? '🍅' : scan.plant === 'Potato' ? '🥔' : '🌽'}
                </div>
                <div>
                  <div style={{ fontWeight: '700' }}>{scan.plant}</div>
                  <div style={{ fontSize: '0.85rem', color: scan.disease === 'Healthy' ? 'var(--primary)' : '#d32f2f' }}>{scan.disease}</div>
                </div>
              </div>
              <div style={{ textAlign: 'right' }}>
                <div style={{ fontSize: '0.9rem', fontWeight: '500' }}>{scan.date}</div>
                <div style={{ fontSize: '0.8rem', color: 'var(--text-dim)' }}>ID: #SCN-00{scan.id}</div>
              </div>
            </div>
          ))}
        </div>
      </section>
    </div>
  );
}
