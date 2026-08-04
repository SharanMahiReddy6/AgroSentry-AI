'use client';

import { useState, useRef } from 'react';
import { 
  Upload, 
  X, 
  Search, 
  Activity, 
  Info,
  Bug,
  Thermometer,
  ShieldCheck,
  FlaskConical,
  CheckCircle2,
  Leaf
} from 'lucide-react';
import { cn } from '@/app/utils';
import { motion, AnimatePresence } from 'framer-motion';

export default function ScanPage() {
  const [file, setFile] = useState<File | null>(null);
  const [preview, setPreview] = useState<string | null>(null);
  const [cropType, setCropType] = useState('apple');
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState<any>(null);
  const [activeTab, setActiveTab] = useState('overview');
  // Three-way viewer: 'original' | 'gradcam' | 'spotlight'
  const [viewMode, setViewMode] = useState<'original' | 'gradcam' | 'spotlight'>('gradcam');
  const fileInputRef = useRef<HTMLInputElement>(null);

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const selectedFile = e.target.files?.[0] || null;
    if (selectedFile) {
      setFile(selectedFile);
      setPreview(URL.createObjectURL(selectedFile));
      setResult(null);
    }
  };

  const handleUpload = async () => {
    if (!file) return;
    setLoading(true);
    
    const formData = new FormData();
    formData.append('file', file);
    formData.append('crop_type', cropType);

    try {
      const response = await fetch('http://localhost:8000/api/scans/upload', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        },
        body: formData,
      });
      
      if (response.ok) {
        const data = await response.json();
        setResult(data.data);
      } else if (response.status === 401) {
        alert('Please login to perform a scan.');
        window.location.href = '/login';
      } else if (response.status === 400) {
        const errorData = await response.json();
        alert(errorData.detail || 'Analysis failed. Please try again.');
      } else {
        alert('Analysis failed. Please try again.');
      }
    } catch (error) {
      console.error('Upload failed', error);
      alert('Error connecting to backend.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="space-y-8 max-w-6xl mx-auto animate-in">
      {!result ? (
        <div className="max-w-2xl mx-auto space-y-6">
          <div className="text-center space-y-2">
            <h1 className="text-3xl font-bold text-gray-900">New Diagnosis</h1>
            <p className="text-muted">Upload a clear photo of the infected leaf for AI analysis.</p>
          </div>

          <div className="card space-y-6">
            <div className="space-y-2">
              <label className="text-sm font-semibold text-gray-700">Select Crop Category</label>
              <select 
                value={cropType} 
                onChange={(e) => setCropType(e.target.value)}
                className="input"
              >
                <option value="apple">Apple</option>
                <option value="blueberry">Blueberry</option>
                <option value="cherry">Cherry</option>
                <option value="corn">Corn</option>
                <option value="grape">Grape</option>
                <option value="orange">Orange</option>
                <option value="peach">Peach</option>
                <option value="pepper">Pepper (Bell)</option>
                <option value="potato">Potato</option>
              </select>
            </div>

            <div 
              onClick={() => fileInputRef.current?.click()}
              className={cn(
                "relative h-80 border-2 border-dashed rounded-2xl flex flex-col items-center justify-center cursor-pointer transition-all duration-300",
                preview ? "border-primary border-solid bg-gray-50" : "border-gray-200 hover:border-primary hover:bg-primary/5"
              )}
            >
              {preview ? (
                <>
                  <img src={preview} alt="preview" className="w-full h-full object-contain p-4" />
                  <button 
                    onClick={(e) => { e.stopPropagation(); setFile(null); setPreview(null); }}
                    className="absolute top-4 right-4 w-10 h-10 bg-white rounded-full shadow-lg flex items-center justify-center text-gray-500 hover:text-danger transition-colors"
                  >
                    <X size={20} />
                  </button>
                </>
              ) : (
                <div className="text-center space-y-4">
                  <div className="w-16 h-16 bg-primary/10 rounded-full flex items-center justify-center mx-auto text-primary">
                    <Upload size={32} />
                  </div>
                  <div>
                    <p className="font-bold text-gray-900 text-lg">Click or Drag Image</p>
                    <p className="text-sm text-muted mt-1">Supports JPG, PNG (Max 10MB)</p>
                  </div>
                </div>
              )}
              <input 
                type="file" 
                ref={fileInputRef} 
                className="hidden" 
                onChange={handleFileChange} 
                accept="image/*"
              />
            </div>

            <button 
              className="btn btn-primary w-full py-4 text-lg font-bold shadow-lg shadow-primary/20 flex items-center justify-center gap-3 disabled:bg-gray-200 disabled:shadow-none" 
              onClick={handleUpload}
              disabled={!file || loading}
            >
              {loading ? (
                <>
                  <div className="w-6 h-6 border-3 border-white/30 border-t-white rounded-full animate-spin" />
                  Analyzing Tissue Patterns...
                </>
              ) : (
                <>
                  <Search size={22} />
                  Run AI Diagnosis
                </>
              )}
            </button>
          </div>
        </div>
      ) : (
        <div className="space-y-8 animate-in">
          {/* Header Action */}
          <div className="flex justify-between items-center bg-white p-4 rounded-xl shadow-sm border border-gray-100">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 bg-primary/10 rounded-lg flex items-center justify-center text-primary">
                <Activity size={24} />
              </div>
              <div>
                <h2 className="font-bold text-gray-900">Analysis Complete</h2>
                <p className="text-xs text-muted">Scan ID: #AG-{result?.scan_id || '8492'}</p>
              </div>
            </div>
            <button onClick={() => {setResult(null); setFile(null); setPreview(null);}} className="btn btn-outline py-2 px-6">
              New Scan
            </button>
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
            {/* Visual Analysis (Left) */}
            <div className="space-y-6">
              {/* Three-way Toggle */}
              <div className="flex gap-1 bg-gray-900 p-1 rounded-xl">
                {([
                  { id: 'original', label: 'Original' },
                  { id: 'gradcam',  label: 'Grad-CAM' },
                  { id: 'spotlight', label: 'Lesion Spotlight' },
                ] as const).map(v => (
                  <button
                    key={v.id}
                    onClick={() => setViewMode(v.id)}
                    className={cn(
                      "flex-1 py-2 text-xs font-bold rounded-lg transition-all duration-200",
                      viewMode === v.id
                        ? "bg-primary text-white shadow-md"
                        : "text-gray-400 hover:text-white"
                    )}
                  >
                    {v.label}
                  </button>
                ))}
              </div>

              {/* Image Viewer */}
              <div className="card p-0 overflow-hidden relative border-none shadow-xl bg-gray-900 aspect-square flex items-center justify-center">
                <AnimatePresence mode="wait">
                  {viewMode === 'original' && (
                    <motion.img key="original"
                      initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
                      src={preview || ''} alt="original"
                      className="w-full h-full object-contain absolute inset-0"
                    />
                  )}
                  {viewMode === 'gradcam' && (
                    <motion.img key="gradcam"
                      initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
                      src={`http://localhost:8000${result.highlight.gradcamUrl || result.highlight.overlayImageUrl}`}
                      alt="Grad-CAM"
                      className="w-full h-full object-contain absolute inset-0"
                    />
                  )}
                  {viewMode === 'spotlight' && (
                    <motion.img key="spotlight"
                      initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
                      src={`http://localhost:8000${result.highlight.spotlightUrl || result.highlight.overlayImageUrl}`}
                      alt="Lesion Spotlight"
                      className="w-full h-full object-contain absolute inset-0"
                    />
                  )}
                </AnimatePresence>

                {/* Mode Label Badge */}
                <div className="absolute top-4 left-4 z-10">
                  <span className={cn(
                    "px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-wider",
                    viewMode === 'original' ? "bg-gray-700 text-gray-200" :
                    viewMode === 'gradcam' ? "bg-orange-500/90 text-white" :
                    "bg-cyan-500/90 text-white"
                  )}>
                    {viewMode === 'original' ? '📷 Original' : viewMode === 'gradcam' ? '🔥 Grad-CAM Heat' : '🎯 Lesion Spotlight'}
                  </span>
                </div>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div className="card p-4 flex items-center gap-4">
                  <div className="w-12 h-12 bg-blue-50 rounded-xl flex items-center justify-center text-blue-600">
                    <Activity size={24} />
                  </div>
                  <div>
                    <p className="text-xs text-muted font-semibold uppercase">Confidence</p>
                    <h4 className="text-xl font-bold text-gray-900">{result.analysis.confidence}%</h4>
                  </div>
                </div>
                <div className="card p-4 flex items-center gap-4">
                  <div className={cn(
                    "w-12 h-12 rounded-xl flex items-center justify-center",
                    result.analysis.severity === 'High' ? "bg-red-50 text-red-600" : "bg-primary-light text-primary"
                  )}>
                    <Thermometer size={24} />
                  </div>
                  <div>
                    <p className="text-xs text-muted font-semibold uppercase">Severity</p>
                    <h4 className="text-xl font-bold text-gray-900">{result.analysis.severity}</h4>
                  </div>
                </div>
              </div>
            </div>

            {/* Diagnosis Details (Right) */}
            <div className="space-y-6">
              <div className="card space-y-4">
                <div>
                  <span className="badge bg-primary/10 text-primary mb-2">Detected Disease</span>
                  <h3 className="text-3xl font-bold text-gray-900">{result.disease.name}</h3>
                  <p className="text-gray-500 italic mt-1 font-medium">{result.disease.scientificName}</p>
                </div>
                <p className="text-gray-600 leading-relaxed py-2 border-t border-gray-50 pt-4">
                  {result.disease.description}
                </p>
                {result.analysis.severityMessage && (
                  <p className="text-xs font-semibold text-amber-700 bg-amber-50 p-3 rounded-lg border border-amber-100/50">
                    {result.analysis.severityMessage}
                  </p>
                )}
              </div>

              {/* Tabs Section */}
              <div className="card p-0 overflow-hidden border-none shadow-lg">
                <div className="flex bg-gray-50 p-1">
                  {['overview', 'symptoms', 'treatment'].map((tab) => (
                    <button
                      key={tab}
                      onClick={() => setActiveTab(tab)}
                      className={cn(
                        "flex-1 py-3 text-sm font-bold capitalize rounded-lg transition-all duration-200",
                        activeTab === tab 
                          ? "bg-white text-primary shadow-sm" 
                          : "text-gray-400 hover:text-gray-600"
                      )}
                    >
                      {tab}
                    </button>
                  ))}
                </div>
                
                <div className="p-6 min-h-[300px]">
                  {activeTab === 'overview' && (
                    <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} className="space-y-6">
                      <div className="grid grid-cols-1 gap-6">
                        <div>
                          <h5 className="flex items-center gap-2 text-sm font-bold text-gray-800 mb-3">
                            <Info size={18} className="text-blue-500" />
                            Primary Causes
                          </h5>
                          <ul className="space-y-2">
                            {result.causes.map((cause: string, i: number) => (
                              <li key={i} className="flex items-center gap-3 text-sm text-gray-600 bg-gray-50 p-2 rounded-lg">
                                <div className="w-1.5 h-1.5 bg-blue-400 rounded-full" />
                                {cause}
                              </li>
                            ))}
                          </ul>
                        </div>
                        <div>
                          <h5 className="flex items-center gap-2 text-sm font-bold text-gray-800 mb-3">
                            <ShieldCheck size={18} className="text-primary" />
                            Preventive Measures
                          </h5>
                          <ul className="space-y-2">
                            {result.treatment.preventive.map((item: string, i: number) => (
                              <li key={i} className="flex items-center gap-3 text-sm text-gray-600 bg-primary/5 p-2 rounded-lg">
                                <CheckCircle2 size={14} className="text-primary" />
                                {item}
                              </li>
                            ))}
                          </ul>
                        </div>
                      </div>
                    </motion.div>
                  )}

                  {activeTab === 'symptoms' && (
                    <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} className="grid grid-cols-1 gap-4">
                      {result.symptoms.length === 0 ? (
                        <p className="text-sm text-muted text-center py-8">No specific symptoms recorded (plant is healthy).</p>
                      ) : (
                        result.symptoms.map((symptom: any, i: number) => (
                          <div key={i} className="flex gap-4 p-4 rounded-xl border border-gray-100 bg-white">
                            <div className="w-10 h-10 bg-amber-50 rounded-lg flex items-center justify-center text-amber-600 flex-shrink-0">
                              <Bug size={20} />
                            </div>
                            <div className="flex-1">
                              <h6 className="font-bold text-gray-900 text-sm">{symptom.title}</h6>
                              <p className="text-xs text-muted mt-1 leading-relaxed">{symptom.description}</p>
                            </div>
                            {symptom.imageUrl && (
                              <div className="w-14 h-14 rounded-lg overflow-hidden border border-gray-100 flex-shrink-0 bg-gray-50">
                                <img src={`http://localhost:8000${symptom.imageUrl}`} alt={symptom.title} className="w-full h-full object-cover" onError={(e: any) => e.target.style.display = 'none'} />
                              </div>
                            )}
                          </div>
                        ))
                      )}
                    </motion.div>
                  )}

                  {activeTab === 'treatment' && (
                    <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} className="space-y-6">
                      {/* Organic Treatment */}
                      <div className="space-y-3">
                        <h5 className="flex items-center gap-2 text-sm font-bold text-gray-800 uppercase tracking-wider">
                          <Leaf size={16} className="text-primary" />
                          Organic Remedies
                        </h5>
                        {result.treatment.organic.length === 0 ? (
                          <p className="text-xs text-muted">No organic remedies needed.</p>
                        ) : (
                          <div className="grid grid-cols-1 gap-3">
                            {result.treatment.organic.map((item: any, i: number) => (
                              <div key={i} className="p-4 rounded-xl bg-primary/5 border border-primary/10">
                                <h6 className="font-bold text-primary text-sm mb-1">{item.step}. {item.title}</h6>
                                <p className="text-xs text-gray-600 leading-relaxed">{item.description}</p>
                              </div>
                            ))}
                          </div>
                        )}
                      </div>

                      {/* Chemical Treatment */}
                      <div className="space-y-3 pt-4 border-t border-gray-50">
                        <h5 className="flex items-center gap-2 text-sm font-bold text-gray-800 uppercase tracking-wider">
                          <FlaskConical size={16} className="text-purple-500" />
                          Chemical Protocols
                        </h5>
                        {result.treatment.chemical.safetyMessage && (
                          <p className="text-xs text-purple-700 bg-purple-50/50 p-2.5 rounded-lg border border-purple-100/50 italic font-medium">
                            ⚠️ {result.treatment.chemical.safetyMessage}
                          </p>
                        )}
                        {result.treatment.chemical.products && result.treatment.chemical.products.length > 0 ? (
                          <div className="space-y-3">
                            {result.treatment.chemical.products.map((prod: any, i: number) => (
                              <div key={i} className="p-4 rounded-xl bg-purple-50 border border-purple-100 space-y-2">
                                <div className="flex justify-between items-start">
                                  <h6 className="font-bold text-purple-900 text-sm">{prod.name}</h6>
                                  <span className="text-[10px] font-bold px-2 py-0.5 bg-purple-200 text-purple-700 rounded-md">
                                    {prod.strength}
                                  </span>
                                </div>
                                <p className="text-xs text-purple-700 leading-relaxed">{prod.description}</p>
                                <div className="pt-2 flex items-center gap-2 text-[10px] font-bold text-purple-900">
                                  <div className="w-2 h-2 bg-purple-400 rounded-full" />
                                  Dosage: {prod.dosage}
                                </div>
                              </div>
                            ))}
                          </div>
                        ) : (
                          <p className="text-xs text-muted">No chemical treatments recommended.</p>
                        )}
                      </div>
                    </motion.div>
                  )}
                </div>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
