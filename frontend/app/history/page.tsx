'use client';

import { useState, useEffect } from 'react';
import { 
  Search, 
  Filter, 
  Calendar, 
  ChevronRight, 
  Download,
  AlertCircle,
  CheckCircle2,
  Trash2,
  Clock,
  ArrowLeft,
  Eye,
  EyeOff,
  Thermometer,
  Leaf,
  FlaskConical,
  Bug,
  Info,
  ShieldCheck,
  Activity,
  Loader2
} from 'lucide-react';
import { cn } from '@/app/utils';
import { motion, AnimatePresence } from 'framer-motion';

export default function HistoryPage() {
  const [history, setHistory] = useState<any[]>([]);
  const [filteredHistory, setFilteredHistory] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedCrop, setSelectedCrop] = useState('all');

  // Detail View State
  const [activeScan, setActiveScan] = useState<any>(null);
  const [loadingDetails, setLoadingDetails] = useState(false);
  const [activeTab, setActiveTab] = useState('overview');
  const [heatmapOpacity, setHeatmapOpacity] = useState(0.6);
  const [showHeatmap, setShowHeatmap] = useState(true);

  const fetchHistory = async () => {
    setLoading(true);
    try {
      const response = await fetch('http://localhost:8000/api/scans/history', {
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        }
      });
      if (response.ok) {
        const data = await response.json();
        setHistory(data);
        setFilteredHistory(data);
      } else if (response.status === 401) {
        window.location.href = '/login';
      }
    } catch (error) {
      console.error('Failed to fetch history', error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchHistory();
  }, []);

  useEffect(() => {
    let result = history;
    if (searchTerm) {
      result = result.filter(item => 
        item.prediction.toLowerCase().includes(searchTerm.toLowerCase()) ||
        item.crop_type.toLowerCase().includes(searchTerm.toLowerCase())
      );
    }
    if (selectedCrop !== 'all') {
      result = result.filter(item => item.crop_type.toLowerCase() === selectedCrop.toLowerCase());
    }
    setFilteredHistory(result);
  }, [searchTerm, selectedCrop, history]);

  const handleViewDetails = async (scanId: number) => {
    setLoadingDetails(true);
    try {
      const response = await fetch(`http://localhost:8000/api/scans/${scanId}`, {
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        }
      });
      if (response.ok) {
        const data = await response.json();
        setActiveScan(data.data);
        setActiveTab('overview');
      } else {
        alert('Failed to retrieve scan details.');
      }
    } catch (error) {
      console.error('Failed to fetch scan details', error);
      alert('Error connecting to backend.');
    } finally {
      setLoadingDetails(false);
    }
  };

  const handleDeleteScan = async (e: React.MouseEvent, scanId: number) => {
    e.stopPropagation();
    if (!confirm('Are you sure you want to delete this scan from your history?')) return;
    
    try {
      const response = await fetch(`http://localhost:8000/api/scans/${scanId}`, {
        method: 'DELETE',
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        }
      });
      if (response.ok) {
        setHistory(prev => prev.filter(item => item.id !== scanId));
        if (activeScan && activeScan.scan_id === scanId) {
          setActiveScan(null);
        }
      } else {
        alert('Failed to delete scan.');
      }
    } catch (error) {
      console.error('Failed to delete scan', error);
      alert('Error connecting to backend.');
    }
  };

  if (activeScan) {
    return (
      <div className="space-y-8 animate-in">
        {/* Header Action */}
        <div className="flex justify-between items-center bg-white p-4 rounded-xl shadow-sm border border-gray-100">
          <button 
            onClick={() => setActiveScan(null)} 
            className="btn btn-outline flex items-center gap-2 py-2 px-4 text-sm font-bold"
          >
            <ArrowLeft size={16} />
            Back to Scan History
          </button>
          <div className="text-right">
            <span className="badge bg-primary/10 text-primary font-bold">Diagnosis ID: {activeScan.diagnosisId}</span>
            <p className="text-[10px] text-muted font-bold mt-1">Captured: {activeScan.plant.captureDate}</p>
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
          {/* Visual Analysis (Left) */}
          <div className="space-y-6">
            <div className="card p-0 overflow-hidden relative border-none shadow-xl bg-gray-900 aspect-square flex items-center justify-center">
              {/* Fallback pattern to show original image */}
              <img 
                src={`http://localhost:8000/storage/uploads/${activeScan.diagnosisId.substring(2)}.jpg`} 
                alt="original" 
                className="w-full h-full object-cover absolute inset-0 opacity-100" 
                onError={(e: any) => {
                  // Fallback if not absolute path
                  e.target.src = activeScan.highlight.overlayImageUrl ? `http://localhost:8000${activeScan.highlight.overlayImageUrl.replace('heatmaps/heatmap_', 'uploads/')}` : '';
                }}
              />
              <AnimatePresence>
                {showHeatmap && activeScan.highlight.overlayImageUrl && (
                  <motion.img 
                    initial={{ opacity: 0 }}
                    animate={{ opacity: heatmapOpacity }}
                    exit={{ opacity: 0 }}
                    src={`http://localhost:8000${activeScan.highlight.overlayImageUrl}`} 
                    alt="heatmap" 
                    className="w-full h-full object-cover absolute inset-0 z-10 mix-blend-screen pointer-events-none" 
                  />
                )}
              </AnimatePresence>
              
              <div className="absolute bottom-6 left-6 right-6 z-20 flex items-center gap-4 bg-black/60 backdrop-blur-md p-4 rounded-xl border border-white/10">
                <button 
                  onClick={() => setShowHeatmap(!showHeatmap)}
                  className="w-10 h-10 rounded-lg flex items-center justify-center bg-white/20 text-white hover:bg-white/30 transition-colors"
                >
                  {showHeatmap ? <EyeOff size={20} /> : <Eye size={20} />}
                </button>
                <div className="flex-1 flex flex-col gap-1">
                  <div className="flex justify-between text-[10px] font-bold text-white uppercase tracking-widest">
                    <span>AI Attention Layer</span>
                    <span>{Math.round(heatmapOpacity * 100)}%</span>
                  </div>
                  <input 
                    type="range" 
                    min="0" 
                    max="1" 
                    step="0.01" 
                    value={heatmapOpacity} 
                    onChange={(e) => setHeatmapOpacity(parseFloat(e.target.value))}
                    className="w-full h-1.5 bg-white/20 rounded-lg appearance-none cursor-pointer accent-primary"
                  />
                </div>
              </div>
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div className="card p-4 flex items-center gap-4">
                <div className="w-12 h-12 bg-blue-50 rounded-xl flex items-center justify-center text-blue-600">
                  <Activity size={24} />
                </div>
                <div>
                  <p className="text-xs text-muted font-semibold uppercase">Confidence</p>
                  <h4 className="text-xl font-bold text-gray-900">{activeScan.analysis.confidence}%</h4>
                </div>
              </div>
              <div className="card p-4 flex items-center gap-4">
                <div className={cn(
                  "w-12 h-12 rounded-xl flex items-center justify-center",
                  activeScan.analysis.severity === 'High' ? "bg-red-50 text-red-600" : "bg-primary-light text-primary"
                )}>
                  <Thermometer size={24} />
                </div>
                <div>
                  <p className="text-xs text-muted font-semibold uppercase">Severity</p>
                  <h4 className="text-xl font-bold text-gray-900">{activeScan.analysis.severity}</h4>
                </div>
              </div>
            </div>
          </div>

          {/* Diagnosis Details (Right) */}
          <div className="space-y-6">
            <div className="card space-y-4">
              <div>
                <span className="badge bg-primary/10 text-primary mb-2">Detected Threat</span>
                <h3 className="text-3xl font-bold text-gray-900">{activeScan.disease.name}</h3>
                <p className="text-gray-500 italic mt-1 font-medium">{activeScan.disease.scientificName}</p>
              </div>
              <p className="text-gray-600 leading-relaxed py-2 border-t border-gray-50 pt-4">
                {activeScan.disease.description}
              </p>
              {activeScan.analysis.severityMessage && (
                <p className="text-xs font-semibold text-amber-700 bg-amber-50 p-3 rounded-lg border border-amber-100/50">
                  {activeScan.analysis.severityMessage}
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
                          {activeScan.causes.map((cause: string, i: number) => (
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
                          {activeScan.treatment.preventive.map((item: string, i: number) => (
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
                    {activeScan.symptoms.length === 0 ? (
                      <p className="text-sm text-muted text-center py-8">No specific symptoms recorded (plant is healthy).</p>
                    ) : (
                      activeScan.symptoms.map((symptom: any, i: number) => (
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
                      {activeScan.treatment.organic.length === 0 ? (
                        <p className="text-xs text-muted">No organic remedies needed.</p>
                      ) : (
                        <div className="grid grid-cols-1 gap-3">
                          {activeScan.treatment.organic.map((item: any, i: number) => (
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
                      {activeScan.treatment.chemical.safetyMessage && (
                        <p className="text-xs text-purple-700 bg-purple-50/50 p-2.5 rounded-lg border border-purple-100/50 italic font-medium">
                          ⚠️ {activeScan.treatment.chemical.safetyMessage}
                        </p>
                      )}
                      {activeScan.treatment.chemical.products && activeScan.treatment.chemical.products.length > 0 ? (
                        <div className="space-y-3">
                          {activeScan.treatment.chemical.products.map((prod: any, i: number) => (
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
    );
  }

  return (
    <div className="space-y-8 animate-in">
      <header>
        <h1 className="text-3xl font-bold text-gray-900">Scan History</h1>
        <p className="text-muted mt-1">Review and manage your previous diagnostic reports.</p>
      </header>

      {/* Loading Details Overlay */}
      {loadingDetails && (
        <div className="fixed inset-0 bg-black/20 backdrop-blur-xs flex items-center justify-center z-50">
          <div className="bg-white p-6 rounded-2xl shadow-xl flex items-center gap-4 border border-gray-100">
            <Loader2 className="w-6 h-6 text-primary animate-spin" />
            <span className="font-bold text-sm text-gray-900">Reconstructing AI Attention Heatmaps...</span>
          </div>
        </div>
      )}

      {/* Filters */}
      <div className="card flex flex-col md:flex-row gap-4 p-4 border-none shadow-sm">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-3 text-gray-400" size={18} />
          <input 
            type="text" 
            placeholder="Search by disease or crop..." 
            className="input pl-10"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
        </div>
        <div className="flex gap-4">
          <div className="relative min-w-[150px]">
            <Filter className="absolute left-3 top-3 text-gray-400" size={18} />
            <select 
              className="input pl-10 appearance-none bg-white"
              value={selectedCrop}
              onChange={(e) => setSelectedCrop(e.target.value)}
            >
              <option value="all">All Crops</option>
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
          <button className="btn btn-outline px-4" onClick={() => window.print()}>
            <Download size={18} />
          </button>
        </div>
      </div>

      {/* History Table */}
      <div className="card p-0 overflow-hidden border-none shadow-xl">
        <div className="overflow-x-auto">
          <table className="w-full text-left">
            <thead>
              <tr className="bg-gray-50 border-b border-gray-100">
                <th className="px-6 py-4 text-xs font-bold text-muted uppercase tracking-wider">Crop Image</th>
                <th className="px-6 py-4 text-xs font-bold text-muted uppercase tracking-wider">Crop Type</th>
                <th className="px-6 py-4 text-xs font-bold text-muted uppercase tracking-wider">Diagnosis</th>
                <th className="px-6 py-4 text-xs font-bold text-muted uppercase tracking-wider">Severity</th>
                <th className="px-6 py-4 text-xs font-bold text-muted uppercase tracking-wider">Date</th>
                <th className="px-6 py-4 text-xs font-bold text-muted uppercase tracking-wider text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-50">
              {loading ? (
                Array(5).fill(0).map((_, i) => (
                  <tr key={i} className="animate-pulse">
                    <td className="px-6 py-4"><div className="w-12 h-12 bg-gray-100 rounded-lg" /></td>
                    <td className="px-6 py-4"><div className="w-24 h-4 bg-gray-100 rounded" /></td>
                    <td className="px-6 py-4"><div className="w-32 h-4 bg-gray-100 rounded" /></td>
                    <td className="px-6 py-4"><div className="w-16 h-6 bg-gray-100 rounded-full" /></td>
                    <td className="px-6 py-4"><div className="w-24 h-4 bg-gray-100 rounded" /></td>
                    <td className="px-6 py-4"><div className="w-8 h-8 bg-gray-100 rounded float-right" /></td>
                  </tr>
                ))
              ) : filteredHistory.length === 0 ? (
                <tr>
                  <td colSpan={6} className="px-6 py-12 text-center text-muted">
                    <div className="flex flex-col items-center gap-2">
                      <Clock size={40} className="text-gray-200" />
                      <p>No history records found matching your filters.</p>
                    </div>
                  </td>
                </tr>
              ) : (
                filteredHistory.map((scan) => (
                  <tr 
                    key={scan.id} 
                    onClick={() => handleViewDetails(scan.id)}
                    className="hover:bg-gray-50 transition-colors group cursor-pointer"
                  >
                    <td className="px-6 py-4">
                      <div className="w-12 h-12 rounded-lg overflow-hidden border border-gray-100">
                        {/* Dynamic URL pointing to backend static server */}
                        <img 
                          src={`http://localhost:8000${scan.image_url}`} 
                          alt="scan" 
                          className="w-full h-full object-cover"
                          onError={(e: any) => e.target.src = 'https://images.unsplash.com/photo-1592417817098-8f3d6eb19675?auto=format&fit=crop&q=80&w=100'}
                        />
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <span className="text-sm font-bold text-gray-700 capitalize">{scan.crop_type}</span>
                    </td>
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-2">
                        {scan.prediction.toLowerCase().includes('healthy') ? (
                          <CheckCircle2 size={16} className="text-primary" />
                        ) : (
                          <AlertCircle size={16} className="text-danger" />
                        )}
                        <span className="text-sm font-bold text-gray-900">{scan.prediction}</span>
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <span className={cn(
                        "badge",
                        scan.severity === 'High' ? "bg-red-100 text-red-600" : "bg-green-100 text-primary"
                      )}>
                        {scan.severity}
                      </span>
                    </td>
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-2 text-sm text-muted">
                        <Calendar size={14} />
                        {new Date(scan.created_at).toLocaleDateString()}
                      </div>
                    </td>
                    <td className="px-6 py-4 text-right">
                      <div className="flex items-center justify-end gap-2">
                        <button 
                          onClick={(e) => handleDeleteScan(e, scan.id)}
                          className="w-8 h-8 rounded-lg flex items-center justify-center text-gray-400 hover:text-danger hover:bg-red-50 transition-all"
                        >
                          <Trash2 size={16} />
                        </button>
                        <button 
                          className="w-8 h-8 rounded-lg flex items-center justify-center bg-gray-100 text-gray-600 hover:bg-primary hover:text-white transition-all"
                        >
                          <ChevronRight size={16} />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
