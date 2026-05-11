'use client';

import { useState, useEffect } from 'react';

export default function TrainingPage() {
  const [file, setFile] = useState<File | null>(null);
  const [jobs, setJobs] = useState<any[]>([]);
  const [loading, setLoading] = useState(false);

  const fetchJobs = async () => {
    try {
      const response = await fetch('http://localhost:8000/api/training/jobs');
      const data = await response.json();
      setJobs(data);
    } catch (error) {
      console.error('Failed to fetch jobs', error);
    }
  };

  useEffect(() => {
    fetchJobs();
    const interval = setInterval(fetchJobs, 5000); // Poll for status
    return () => clearInterval(interval);
  }, []);

  const handleStartTraining = async () => {
    if (!file) return;
    setLoading(true);
    
    const formData = new FormData();
    formData.append('file', file);

    try {
      await fetch('http://localhost:8000/api/training/start', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        },
        body: formData,
      });
      setFile(null);
      fetchJobs();
    } catch (error) {
      console.error('Training start failed', error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="container">
      <h1 className="title">Model Training Portal</h1>
      <p style={{ color: 'var(--text-dim)', marginBottom: '2rem' }}>
        Upload a .zip file containing folders of images categorized by disease name to retrain the AI.
      </p>

      <div className="grid">
        <div className="glass-card">
          <h3 style={{ marginBottom: '1.5rem' }}>Upload New Dataset</h3>
          <input 
            type="file" 
            accept=".zip" 
            onChange={(e) => setFile(e.target.files?.[0] || null)}
          />
          <button 
            className="btn btn-primary" 
            style={{ width: '100%' }}
            onClick={handleStartTraining}
            disabled={!file || loading}
          >
            {loading ? 'Uploading...' : 'Start Training Task'}
          </button>
        </div>

        <div className="glass-card" style={{ gridColumn: 'span 2' }}>
          <h3 style={{ marginBottom: '1.5rem' }}>Recent Training Jobs</h3>
          <table style={{ width: '100%', borderCollapse: 'collapse' }}>
            <thead>
              <tr style={{ textAlign: 'left', borderBottom: '1px solid var(--glass-border)' }}>
                <th style={{ padding: '0.5rem' }}>Dataset</th>
                <th style={{ padding: '0.5rem' }}>Status</th>
                <th style={{ padding: '0.5rem' }}>Accuracy</th>
                <th style={{ padding: '0.5rem' }}>Created</th>
                <th style={{ padding: '0.5rem' }}>Action</th>
              </tr>
            </thead>
            <tbody>
              {jobs.map((job) => (
                <tr key={job.id} style={{ borderBottom: '1px solid var(--glass-border)' }}>
                  <td style={{ padding: '0.5rem' }}>{job.dataset_name}</td>
                  <td style={{ padding: '0.5rem' }}>
                    <span style={{ 
                      color: job.status === 'completed' ? 'var(--primary)' : 
                             job.status === 'training' ? 'var(--accent)' : 
                             job.status === 'failed' ? '#e74c3c' : 'white'
                    }}>
                      {job.status.toUpperCase()}
                      {job.is_deployed && <span style={{ marginLeft: '8px', fontSize: '0.7rem', background: 'var(--primary)', color: 'black', padding: '2px 6px', borderRadius: '4px' }}>LIVE</span>}
                    </span>
                  </td>
                  <td style={{ padding: '0.5rem' }}>{job.accuracy ? `${job.accuracy}%` : '-'}</td>
                  <td style={{ padding: '0.5rem', fontSize: '0.8rem', color: 'var(--text-dim)' }}>
                    {new Date(job.created_at).toLocaleDateString()}
                  </td>
                  <td style={{ padding: '0.5rem' }}>
                    {job.status === 'completed' && !job.is_deployed && (
                      <button 
                        className="btn btn-primary" 
                        style={{ padding: '4px 12px', fontSize: '0.8rem' }}
                        onClick={async () => {
                          const res = await fetch(`http://localhost:8000/api/training/deploy/${job.id}`, {
                            method: 'POST',
                            headers: { 'Authorization': `Bearer ${localStorage.getItem('token')}` }
                          });
                          if (res.ok) fetchJobs();
                        }}
                      >
                        Deploy
                      </button>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
