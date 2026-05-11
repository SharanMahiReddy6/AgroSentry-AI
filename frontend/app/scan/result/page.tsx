'use client';

import Link from 'next/link';

export default function ScanResultPage() {
  // Static placeholder data – will be replaced with real API response later
  const result = {
    disease: 'Tomato Late Blight',
    confidence: 94,
    severity: 'High',
    infectionPercentage: 68,
    organic: {
      remedies: ['Copper fungicide', 'Neem oil'],
      instructions: 'Apply spray early morning and repeat every 7 days until disease subsides.'
    },
    chemical: {
      chemicals: ['Mancozeb', 'Chlorothalonil'],
      dosage: '2 L per 100 L of water, repeat weekly.'
    },
    heatmapUrl: '/placeholder-heatmap.png'
  };

  return (
    <div className="animate-fade" style={{ maxWidth: '800px', margin: '0 auto', padding: '2rem' }}>
      <h1 className="title" style={{ textAlign: 'center', marginBottom: '2rem' }}>AI Diagnosis Result</h1>

      <div className="card" style={{ marginBottom: '2rem' }}>
        <h2 style={{ color: 'var(--primary)', marginBottom: '0.5rem' }}>{result.disease}</h2>
        <p style={{ marginBottom: '0.5rem' }}><strong>Confidence:</strong> {result.confidence}%</p>
        <p style={{ marginBottom: '0.5rem' }}><strong>Severity:</strong> <span style={{ color: result.severity === 'High' ? '#d32f2f' : '#ffb300' }}>{result.severity}</span></p>
        <p style={{ marginBottom: '0.5rem' }}><strong>Infected Area:</strong> {result.infectionPercentage}%</p>
      </div>

      {/* Treatment Sections */}
      <div className="grid" style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1.5rem', marginBottom: '2rem' }}>
        <div className="card">
          <h3 style={{ color: 'var(--primary)', marginBottom: '0.5rem' }}>Organic Treatment</h3>
          <p><strong>Remedies:</strong> {result.organic.remedies.join(', ')}</p>
          <p><strong>Instructions:</strong> {result.organic.instructions}</p>
        </div>
        <div className="card">
          <h3 style={{ color: 'var(--primary)', marginBottom: '0.5rem' }}>Chemical Treatment</h3>
          <p><strong>Chemicals:</strong> {result.chemical.chemicals.join(', ')}</p>
          <p><strong>Dosage:</strong> {result.chemical.dosage}</p>
        </div>
      </div>

      {/* Heatmap toggle – placeholder image */}
      <div className="card" style={{ textAlign: 'center' }}>
        <h3 style={{ color: 'var(--primary)', marginBottom: '0.5rem' }}>Grad‑CAM Heatmap</h3>
        <img src={result.heatmapUrl} alt="Heatmap" style={{ maxWidth: '100%', borderRadius: 'var(--radius-md)', boxShadow: 'var(--shadow-soft)' }} />
        <p style={{ marginTop: '0.5rem', color: 'var(--text-secondary)' }}>(Placeholder – will be replaced by backend image)</p>
      </div>

      <div style={{ marginTop: '2rem', textAlign: 'center' }}>
        <Link href="/scan" className="btn btn-soft" style={{ marginRight: '1rem' }}>
          New Scan
        </Link>
        <Link href="/" className="btn btn-primary">
          Back to Dashboard
        </Link>
      </div>
    </div>
  );
}
