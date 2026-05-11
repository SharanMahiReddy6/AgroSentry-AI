'use client';

import { useState } from 'react';

export default function ScanPage() {
  const [file, setFile] = useState<File | null>(null);
  const [result, setResult] = useState<any>(null);
  const [loading, setLoading] = useState(false);

  const handleUpload = async () => {
    if (!file) return;
    setLoading(true);
    
    const formData = new FormData();
    formData.append('file', file);

    try {
      // Note: In production, use dynamic API URL from env
      const response = await fetch('http://localhost:8000/api/scans/upload', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        },
        body: formData,
      });
      const data = await response.json();
      setResult(data);
    } catch (error) {
      console.error('Upload failed', error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="container">
      <h1 className="title">AI Disease Scanner</h1>
      
      <div className="glass-card" style={{ maxWidth: '600px', margin: '0 auto' }}>
        <p style={{ marginBottom: '2rem', color: 'var(--text-dim)' }}>
          Upload a clear photo of the affected plant leaf. Make sure the lighting is good and the leaf is centered.
        </p>
        
        <input 
          type="file" 
          accept="image/*" 
          onChange={(e) => setFile(e.target.files?.[0] || null)}
          style={{ marginBottom: '1.5rem' }}
        />
        
        <button 
          className="btn btn-primary" 
          style={{ width: '100%' }}
          onClick={handleUpload}
          disabled={!file || loading}
        >
          {loading ? 'Analyzing...' : 'Analyze Leaf'}
        </button>

        {result && result.prediction && (
          <div style={{ marginTop: '2rem', padding: '1rem', borderTop: '1px solid var(--glass-border)' }}>
            <h3 style={{ color: 'var(--primary)', marginBottom: '1rem' }}>AI Analysis Result</h3>
            
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem', marginBottom: '1.5rem' }}>
              <div className="info-box">
                <span className="label">Detected Disease</span>
                <div className="value" style={{ fontSize: '1.2rem', fontWeight: 'bold' }}>
                  {result.prediction.basic_details.disease_name}
                </div>
              </div>
              <div className="info-box">
                <span className="label">Confidence Score</span>
                <div className="value" style={{ color: 'var(--accent)', fontWeight: 'bold' }}>
                  {result.prediction.basic_details.confidence}%
                </div>
              </div>
              <div className="info-box">
                <span className="label">Severity Level</span>
                <div className="value" style={{ color: result.prediction.basic_details.severity === 'High' ? '#ff4d4d' : '#ffcc00' }}>
                  {result.prediction.basic_details.severity}
                </div>
              </div>
              <div className="info-box">
                <span className="label">Infected Area</span>
                <div className="value">{result.prediction.basic_details.infection_percentage}%</div>
              </div>
            </div>

            <div style={{ marginBottom: '1.5rem' }}>
              <h4 style={{ color: 'var(--text-bright)' }}>Organic Treatment</h4>
              <p style={{ fontSize: '0.9rem', color: 'var(--text-dim)' }}>
                <strong>Remedies:</strong> {result.prediction.treatment_plan.organic.remedies.join(', ')}<br/>
                <strong>Instructions:</strong> {result.prediction.treatment_plan.organic.instructions}
              </p>
            </div>

            <div>
              <h4 style={{ color: 'var(--text-bright)' }}>Chemical Treatment</h4>
              <p style={{ fontSize: '0.9rem', color: 'var(--text-dim)' }}>
                <strong>Chemicals:</strong> {result.prediction.treatment_plan.chemical.chemicals.join(', ')}<br/>
                <strong>Dosage:</strong> {result.prediction.treatment_plan.chemical.dosage}
              </p>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
