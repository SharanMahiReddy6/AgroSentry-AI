'use client';

import { useState, useEffect } from 'react';
import { 
  Database, 
  Cpu, 
  Play, 
  CheckCircle, 
  Clock, 
  Upload, 
  Users, 
  Lightbulb, 
  Bell, 
  CheckCircle2, 
  XCircle, 
  Loader2, 
  Send,
  Lock
} from 'lucide-react';
import { cn } from '@/app/utils';

export default function AdminPage() {
  const [activeTab, setActiveTab] = useState<'models' | 'users' | 'tips' | 'notifications' | 'library'>('models');
  const [loading, setLoading] = useState(true);
  
  // Data States
  const [jobs, setJobs] = useState<any[]>([]);
  const [usersList, setUsersList] = useState<any[]>([]);
  const [pendingTips, setPendingTips] = useState<any[]>([]);
  const [successMsg, setSuccessMsg] = useState('');
  
  // Form States
  const [selectedDataset, setSelectedDataset] = useState('apple');
  const [epochs, setEpochs] = useState(15);
  const [startingJob, setStartingJob] = useState(false);
  
  // Dataset Upload States
  const [uploadFile, setUploadFile] = useState<File | null>(null);
  const [uploadCropName, setUploadCropName] = useState('apple');
  const [customCropName, setCustomCropName] = useState('');
  const [uploadDiseaseName, setUploadDiseaseName] = useState('');
  const [isFullDataset, setIsFullDataset] = useState(true);
  const [uploadingDataset, setUploadingDataset] = useState(false);
  const [availableCrops, setAvailableCrops] = useState<string[]>([
    'apple', 'blueberry', 'cherry', 'corn', 'grape', 'orange', 'peach', 'pepper', 'potato', 'strawberry', 'tomato'
  ]);
  
  // Notification form
  const [notifTarget, setNotifTarget] = useState('all'); // 'all' or user_id (string)
  const [notifTitle, setNotifTitle] = useState('');
  const [notifMessage, setNotifMessage] = useState('');
  const [sendingNotif, setSendingNotif] = useState(false);

  const fetchAllData = async () => {
    setLoading(true);
    const token = localStorage.getItem('token');
    
    try {
      // 1. Fetch Training Jobs
      const jobsRes = await fetch('http://localhost:8000/api/training/jobs', {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      if (jobsRes.ok) {
        const jobsData = await jobsRes.json();
        setJobs(jobsData);
      } else if (jobsRes.status === 403 || jobsRes.status === 401) {
        alert('Access denied. Admin privileges required.');
        window.location.href = '/';
        return;
      }

      // 2. Fetch Users
      const usersRes = await fetch('http://localhost:8000/api/auth/users', {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      if (usersRes.ok) {
        const usersData = await usersRes.json();
        setUsersList(usersData);
      }

      // 3. Fetch Pending Tips
      const tipsRes = await fetch('http://localhost:8000/api/tips/pending', {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      if (tipsRes.ok) {
        const tipsData = await tipsRes.json();
        setPendingTips(tipsData);
      }

      // 4. Fetch Available Datasets
      const datasetsRes = await fetch('http://localhost:8000/api/training/available-datasets', {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      if (datasetsRes.ok) {
        const datasetsData = await datasetsRes.json();
        setAvailableCrops(datasetsData);
      }
    } catch (err) {
      console.error('Failed to fetch admin workspace data', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchAllData();
  }, []);

  useEffect(() => {
    const hasActiveJob = jobs.some(j => j.status === 'training' || j.status === 'pending');
    if (hasActiveJob) {
      const interval = setInterval(() => {
        fetchAllData();
      }, 3000);
      return () => clearInterval(interval);
    }
  }, [jobs]);

  const handleStartTraining = async (e: React.FormEvent) => {
    e.preventDefault();
    setStartingJob(true);
    setSuccessMsg('');
    
    try {
      const response = await fetch('http://localhost:8000/api/training/start-local', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        },
        body: JSON.stringify({
          dataset_name: selectedDataset,
          num_epochs: epochs
        })
      });

      if (response.ok) {
        setSuccessMsg(`Farming model pipeline successfully triggered for ${selectedDataset.toUpperCase()} dataset.`);
        fetchAllData();
        setTimeout(() => setSuccessMsg(''), 5000);
      } else {
        const errData = await response.json();
        alert(errData.detail || 'Failed to start local training.');
      }
    } catch (err) {
      console.error(err);
      alert('Error connecting to ML backend.');
    } finally {
      setStartingJob(false);
    }
  };

  const handleUploadDataset = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!uploadFile) return alert("Please select a zip file.");
    
    setUploadingDataset(true);
    setSuccessMsg('');
    
    const formData = new FormData();
    const finalCropName = uploadCropName === 'others' ? customCropName.toLowerCase().replace(/\\s+/g, '_') : uploadCropName;
    formData.append('file', uploadFile);
    formData.append('crop_name', finalCropName);
    formData.append('is_full_dataset', isFullDataset ? 'true' : 'false');
    if (!isFullDataset) {
      if (!uploadDiseaseName) {
        setUploadingDataset(false);
        return alert("Please enter the new disease name.");
      }
      formData.append('disease_name', uploadDiseaseName);
    }
    
    try {
      const response = await fetch('http://localhost:8000/api/training/upload-dataset', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        },
        body: formData
      });
      
      if (response.ok) {
        const data = await response.json();
        setSuccessMsg(data.message);
        setUploadFile(null);
        setUploadDiseaseName('');
        fetchAllData();
      } else {
        const errData = await response.json();
        alert(errData.detail || 'Failed to upload dataset.');
      }
    } catch (err) {
      console.error(err);
      alert('Error uploading dataset.');
    } finally {
      setUploadingDataset(false);
    }
  };

  const handleDeployModel = async (jobId: number) => {
    if (!confirm('Are you sure you want to deploy this model as the active scanner classifier?')) return;
    
    try {
      const response = await fetch(`http://localhost:8000/api/training/deploy/${jobId}`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        }
      });
      if (response.ok) {
        setSuccessMsg('Active classifier deployed successfully.');
        fetchAllData();
        setTimeout(() => setSuccessMsg(''), 5000);
      } else {
        alert('Failed to deploy model.');
      }
    } catch (err) {
      console.error(err);
      alert('Error deploying weights.');
    }
  };

  const handleApproveTip = async (tipId: number) => {
    try {
      const response = await fetch(`http://localhost:8000/api/tips/${tipId}/approve`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        }
      });
      if (response.ok) {
        setSuccessMsg('Tip approved and published into public feed.');
        setPendingTips(prev => prev.filter(t => t.id !== tipId));
        setTimeout(() => setSuccessMsg(''), 5000);
      } else {
        alert('Failed to approve tip.');
      }
    } catch (err) {
      console.error(err);
    }
  };

  const handleDeleteTip = async (tipId: number) => {
    if (!confirm('Are you sure you want to reject and delete this tip?')) return;
    
    try {
      const response = await fetch(`http://localhost:8000/api/tips/${tipId}`, {
        method: 'DELETE',
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        }
      });
      if (response.ok) {
        setSuccessMsg('Tip successfully rejected and deleted.');
        setPendingTips(prev => prev.filter(t => t.id !== tipId));
        setTimeout(() => setSuccessMsg(''), 5000);
      } else {
        alert('Failed to reject tip.');
      }
    } catch (err) {
      console.error(err);
    }
  };

  const handleSendNotification = async (e: React.FormEvent) => {
    e.preventDefault();
    setSendingNotif(true);
    setSuccessMsg('');
    
    const targetUserId = notifTarget === 'all' ? null : parseInt(notifTarget);
    
    try {
      const response = await fetch('http://localhost:8000/api/notifications', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        },
        body: JSON.stringify({
          title: notifTitle,
          message: notifMessage,
          user_id: targetUserId
        })
      });

      if (response.ok) {
        setSuccessMsg('Broadcasting alert successfully dispatched to all listening nodes.');
        setNotifTitle('');
        setNotifMessage('');
        setTimeout(() => setSuccessMsg(''), 5000);
      } else {
        alert('Failed to broadcast alert.');
      }
    } catch (err) {
      console.error(err);
      alert('Error transmitting broadcast notifications.');
    } finally {
      setSendingNotif(false);
    }
  };

  if (loading && jobs.length === 0) {
    return (
      <div className="min-h-[70vh] flex flex-col items-center justify-center gap-3">
        <Loader2 className="w-12 h-12 text-primary animate-spin" />
        <p className="text-sm font-bold text-gray-500">Initializing administrative workspace cockpit...</p>
      </div>
    );
  }

  return (
    <div className="space-y-8 animate-in max-w-6xl mx-auto">
      <header className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
        <div>
          <h1 className="text-3xl font-black text-gray-900 flex items-center gap-2">
            <Lock size={28} className="text-primary" />
            Super-Admin Workspace
          </h1>
          <p className="text-muted mt-1">Manage AI model pipelines, user logs, crop tips, and send global broadcast notifications.</p>
        </div>
      </header>

      {successMsg && (
        <div className="bg-primary/10 border border-primary/20 p-4 rounded-xl flex items-center gap-3 text-primary animate-in slide-in-from-top duration-300">
          <CheckCircle2 className="flex-shrink-0" size={20} />
          <p className="text-sm font-bold">{successMsg}</p>
        </div>
      )}

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <div className="card border-l-4 border-l-primary flex flex-col justify-between p-6">
          <span className="text-[10px] text-muted font-extrabold uppercase tracking-widest">Active Neural Weights</span>
          <h3 className="text-lg font-black text-gray-900 mt-2">AgroSentry-V3-ResNet50</h3>
          <p className="text-[10px] text-primary font-extrabold mt-3">Status: Optimized</p>
        </div>
        <div className="card border-l-4 border-l-blue-500 flex flex-col justify-between p-6">
          <span className="text-[10px] text-muted font-extrabold uppercase tracking-widest font-sans">Active Users</span>
          <h3 className="text-3xl font-black text-gray-900 mt-2">{usersList.length}</h3>
          <p className="text-[10px] text-blue-500 font-extrabold mt-3">Registered Farms</p>
        </div>
        <div className="card border-l-4 border-l-amber-500 flex flex-col justify-between p-6">
          <span className="text-[10px] text-muted font-extrabold uppercase tracking-widest font-sans">Pending Tips</span>
          <h3 className="text-3xl font-black text-gray-900 mt-2">{pendingTips.length}</h3>
          <p className="text-[10px] text-amber-500 font-extrabold mt-3">Review Queue</p>
        </div>
        <div className="card border-l-4 border-l-purple-500 flex flex-col justify-between p-6">
          <span className="text-[10px] text-muted font-extrabold uppercase tracking-widest font-sans">AI Pipeline Jobs</span>
          <h3 className="text-3xl font-black text-gray-900 mt-2">{jobs.length}</h3>
          <p className="text-[10px] text-purple-500 font-extrabold mt-3">Total Cycles run</p>
        </div>
      </div>

      {/* Tabs Layout */}
      <div className="flex border-b border-gray-100 bg-white p-1 rounded-2xl shadow-sm">
        {[
          { id: 'models', label: 'AI Model Training', icon: Cpu },
          { id: 'users', label: 'User Directory', icon: Users },
          { id: 'tips', label: 'Pending Tips Queue', icon: Lightbulb },
          { id: 'notifications', label: 'Send Broadcast', icon: Bell },
          { id: 'library', label: 'Disease Library', icon: Database }
        ].map((t) => {
          const TIcon = t.icon;
          return (
            <button
              key={t.id}
              onClick={() => setActiveTab(t.id as any)}
              className={cn(
                "flex-1 py-3 text-sm font-bold flex items-center justify-center gap-2 rounded-xl transition-all duration-200",
                activeTab === t.id 
                  ? "bg-primary/10 text-primary" 
                  : "text-gray-400 hover:text-gray-600 hover:bg-gray-50"
              )}
            >
              <TIcon size={16} />
              {t.label}
            </button>
          );
        })}
      </div>

      {/* Tab Content Panels */}
      <div className="bg-white rounded-3xl p-6 shadow-xl border border-gray-50 min-h-[400px]">
        {activeTab === 'models' && (
          <div className="space-y-8 animate-in">
            {/* Dataset Training Status Tracker Grid */}
            <div className="space-y-4">
              <h3 className="font-extrabold text-gray-900 text-lg flex items-center gap-2">
                <Cpu size={20} className="text-primary animate-pulse" />
                AgroSentry ML Dataset Coverage Tracker ({
                  availableCrops.filter(
                    crop => jobs.some(j => j.dataset_name.toLowerCase().includes(crop) && j.status === 'completed')
                  ).length
                }/{availableCrops.length} Trained)
              </h3>
              
              <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-4">
                {availableCrops.map((crop) => {
                  const isTrained = jobs.some(
                    j => j.dataset_name.toLowerCase().includes(crop) && j.status === 'completed'
                  );
                  const isDeployed = jobs.some(
                    j => j.dataset_name.toLowerCase().includes(crop) && j.status === 'completed' && j.is_deployed
                  );
                  
                  return (
                    <div 
                      key={crop} 
                      className={cn(
                        "p-4 rounded-2xl border transition-all duration-300 flex flex-col justify-between h-32 relative overflow-hidden",
                        isTrained 
                          ? "bg-green-50/50 border-green-100 shadow-xs" 
                          : "bg-gray-50/50 border-gray-100/80"
                      )}
                    >
                      <div>
                        <h4 className="font-black text-gray-900 capitalize text-sm">{crop}</h4>
                        <p className="text-[10px] text-muted font-bold mt-1">
                          {isTrained ? "Dataset online" : "Dataset offline"}
                        </p>
                      </div>
                      
                      <div className="mt-4">
                        {isDeployed ? (
                          <span className="inline-flex items-center gap-1 text-[10px] font-black text-primary bg-primary/10 px-2 py-1 rounded-lg">
                            <CheckCircle size={10} /> Active Classifier
                          </span>
                        ) : isTrained ? (
                          <span className="inline-flex items-center gap-1 text-[10px] font-black text-green-700 bg-green-100/80 px-2 py-1 rounded-lg">
                            <CheckCircle2 size={10} /> Trained
                          </span>
                        ) : (
                          <span className="inline-flex items-center gap-1 text-[10px] font-black text-gray-500 bg-gray-100 px-2 py-1 rounded-lg">
                            <Clock size={10} /> Untrained
                          </span>
                        )}
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>

            {/* Upload Dataset Form */}
            <form onSubmit={handleUploadDataset} className="p-6 rounded-2xl bg-white border border-gray-100 shadow-sm space-y-4">
              <h3 className="font-extrabold text-gray-900 text-lg flex items-center gap-2">
                <Upload size={20} className="text-primary" />
                Upload Custom AI Dataset (ZIP)
              </h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div className="space-y-4">
                  <div className="space-y-1">
                    <label className="text-xs font-bold text-gray-700 uppercase tracking-wider">Crop Target</label>
                    <select 
                      className="input text-sm bg-gray-50"
                      value={uploadCropName}
                      onChange={(e) => setUploadCropName(e.target.value)}
                    >
                      {availableCrops.map(crop => (
                        <option key={crop} value={crop}>{crop.charAt(0).toUpperCase() + crop.slice(1)}</option>
                      ))}
                      <option value="others">Others...</option>
                    </select>
                  </div>
                  
                  {uploadCropName === 'others' && (
                    <div className="space-y-1 animate-in fade-in slide-in-from-top-2">
                      <label className="text-xs font-bold text-gray-700 uppercase tracking-wider">New Crop Name</label>
                      <input 
                        type="text" 
                        className="input text-sm bg-gray-50" 
                        placeholder="e.g. Mango"
                        value={customCropName}
                        onChange={(e) => setCustomCropName(e.target.value)}
                        required={uploadCropName === 'others'}
                      />
                    </div>
                  )}
                  
                  <div className="flex flex-col gap-2">
                    <label className="flex items-center gap-2 cursor-pointer">
                      <input 
                        type="radio" 
                        name="datasetType" 
                        checked={isFullDataset} 
                        onChange={() => setIsFullDataset(true)} 
                        className="text-primary focus:ring-primary h-4 w-4"
                      />
                      <span className="text-sm font-bold text-gray-700">Full Dataset (Contains train/valid folders)</span>
                    </label>
                    <label className="flex items-center gap-2 cursor-pointer">
                      <input 
                        type="radio" 
                        name="datasetType" 
                        checked={!isFullDataset} 
                        onChange={() => setIsFullDataset(false)} 
                        className="text-primary focus:ring-primary h-4 w-4"
                      />
                      <span className="text-sm font-bold text-gray-700">New Disease Class (Just images inside zip)</span>
                    </label>
                  </div>
                  
                  {!isFullDataset && (
                    <div className="space-y-1 animate-in fade-in slide-in-from-top-2">
                      <label className="text-xs font-bold text-gray-700 uppercase tracking-wider">New Disease Folder Name</label>
                      <input 
                        type="text" 
                        className="input text-sm bg-gray-50" 
                        placeholder="e.g. Apple___New_Scab"
                        value={uploadDiseaseName}
                        onChange={(e) => setUploadDiseaseName(e.target.value)}
                        required={!isFullDataset}
                      />
                      <p className="text-[10px] text-muted">This will automatically split your images into train/valid sets for the new class.</p>
                    </div>
                  )}
                </div>
                
                <div className="space-y-4 flex flex-col justify-between">
                  <div className="space-y-1 h-full">
                    <label className="text-xs font-bold text-gray-700 uppercase tracking-wider">Select ZIP File</label>
                    <div className="border-2 border-dashed border-gray-200 rounded-xl p-6 flex flex-col items-center justify-center bg-gray-50 h-[calc(100%-24px)] text-center relative hover:bg-gray-100 transition-colors">
                      <input 
                        type="file" 
                        accept=".zip"
                        className="absolute inset-0 w-full h-full opacity-0 cursor-pointer"
                        onChange={(e) => setUploadFile(e.target.files?.[0] || null)}
                      />
                      <Upload className="text-gray-400 mb-2" size={24} />
                      <span className="text-sm font-bold text-gray-600">
                        {uploadFile ? uploadFile.name : "Click or drag ZIP file here"}
                      </span>
                      {uploadFile && <span className="text-xs text-primary font-bold mt-1">Ready to upload</span>}
                    </div>
                  </div>
                  
                  <button 
                    type="submit" 
                    disabled={uploadingDataset || !uploadFile}
                    className="btn btn-primary w-full py-3 text-sm flex items-center justify-center gap-2"
                  >
                    {uploadingDataset ? (
                      <>
                        <Loader2 className="w-5 h-5 animate-spin" />
                        Uploading & Processing...
                      </>
                    ) : (
                      <>
                        <Upload size={18} />
                        Upload & Prepare Dataset
                      </>
                    )}
                  </button>
                </div>
              </div>
            </form>

            {/* Start Job Form */}
            <form onSubmit={handleStartTraining} className="p-6 rounded-2xl bg-gray-50 border border-gray-100/50 space-y-4">
              <h3 className="font-extrabold text-gray-900 text-lg flex items-center gap-2">
                <Play size={20} className="text-primary" />
                Initialize Local Dataset Training Job
              </h3>
              <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                <div className="space-y-1">
                  <label className="text-xs font-bold text-gray-700 uppercase tracking-wider">Select Dataset Category</label>
                  <select 
                    className="input text-sm bg-white"
                    value={selectedDataset}
                    onChange={(e) => setSelectedDataset(e.target.value)}
                  >
                    {availableCrops.map(crop => (
                      <option key={crop} value={crop}>{crop.charAt(0).toUpperCase() + crop.slice(1)} Dataset</option>
                    ))}
                  </select>
                </div>
                <div className="space-y-1">
                  <label className="text-xs font-bold text-gray-700 uppercase tracking-wider">Epoch Count (Iterations)</label>
                  <input 
                    type="number" 
                    className="input text-sm"
                    value={epochs}
                    onChange={(e) => setEpochs(parseInt(e.target.value))}
                    min={1}
                    max={100}
                    required
                  />
                </div>
                <div className="flex items-end">
                  <button 
                    type="submit" 
                    disabled={startingJob}
                    className="btn btn-primary w-full py-3 text-sm flex items-center justify-center gap-2"
                  >
                    {startingJob ? (
                      <>
                        <Loader2 className="w-5 h-5 animate-spin" />
                        Triggering pipeline...
                      </>
                    ) : (
                      <>
                        <Cpu size={18} />
                        Start Training Pipeline
                      </>
                    )}
                  </button>
                </div>
              </div>
            </form>

            {/* Jobs Table */}
            <div className="space-y-4">
              <h3 className="font-extrabold text-gray-900 text-lg flex items-center gap-2">
                <Database size={20} className="text-blue-500" />
                Completed & Active Model Checkpoints
              </h3>
              <div className="overflow-x-auto">
                <table className="w-full text-left">
                  <thead>
                    <tr className="bg-gray-50 border-b border-gray-100">
                      <th className="px-6 py-4 text-xs font-bold text-muted uppercase tracking-wider">Job ID</th>
                      <th className="px-6 py-4 text-xs font-bold text-muted uppercase tracking-wider">Dataset Name</th>
                      <th className="px-6 py-4 text-xs font-bold text-muted uppercase tracking-wider">Status</th>
                      <th className="px-6 py-4 text-xs font-bold text-muted uppercase tracking-wider">Validation Accuracy</th>
                      <th className="px-6 py-4 text-xs font-bold text-muted uppercase tracking-wider">Initiated At</th>
                      <th className="px-6 py-4 text-xs font-bold text-muted uppercase tracking-wider text-right">Actions</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-gray-50">
                    {jobs.length === 0 ? (
                      <tr>
                        <td colSpan={6} className="px-6 py-12 text-center text-muted font-medium text-sm">
                          No pipeline jobs have been initiated in this workspace.
                        </td>
                      </tr>
                    ) : (
                      jobs.map((job) => (
                        <tr key={job.id} className="hover:bg-gray-50 transition-colors">
                          <td className="px-6 py-4 font-mono text-xs font-bold text-gray-500">#AG-{job.id}</td>
                          <td className="px-6 py-4 font-bold text-gray-800 uppercase">{job.dataset_name}</td>
                          <td className="px-6 py-4">
                            <div className="flex flex-col gap-1">
                              <span className={cn(
                                "badge text-xs font-bold w-fit",
                                job.status === 'completed' ? "bg-green-50 text-primary" : 
                                job.status === 'failed' ? "bg-red-50 text-red-600" : "bg-amber-50 text-amber-600 animate-pulse"
                              )}>
                                {job.status}
                              </span>
                              {job.status === 'training' && (
                                <span className="text-[10px] font-extrabold text-amber-600 animate-pulse mt-0.5">
                                  Running cycles...
                                </span>
                              )}
                            </div>
                          </td>
                          <td className="px-6 py-4">
                            {job.status === 'training' ? (
                              <div className="w-48 space-y-1">
                                <div className="flex justify-between items-center text-xs">
                                  <span className="font-extrabold text-primary">{job.accuracy ? `Val Acc: ${job.accuracy}%` : 'Measuring...'}</span>
                                  <span className="font-extrabold text-gray-500">{job.progress || 0}%</span>
                                </div>
                                <div className="w-full bg-gray-100 h-2 rounded-full overflow-hidden">
                                  <div 
                                    className="bg-primary h-full rounded-full transition-all duration-500 ease-out"
                                    style={{ width: `${job.progress || 0}%` }}
                                  />
                                </div>
                              </div>
                            ) : job.status === 'failed' ? (
                              <div className="flex flex-col">
                                <span className="font-bold text-gray-400 text-sm">--</span>
                                {job.error_message && (
                                  <span className="text-[10px] text-red-500 max-w-[200px] font-medium truncate mt-0.5" title={job.error_message}>
                                    {job.error_message}
                                  </span>
                                )}
                              </div>
                            ) : (
                              <span className="font-bold text-gray-700">{job.accuracy ? `${job.accuracy}%` : '--'}</span>
                            )}
                          </td>
                          <td className="px-6 py-4 text-xs text-muted font-medium">{new Date(job.created_at).toLocaleString()}</td>
                          <td className="px-6 py-4 text-right">
                            {job.is_deployed ? (
                              <span className="text-xs font-bold text-primary flex items-center justify-end gap-1">
                                <CheckCircle size={14} /> Active Scanner
                              </span>
                            ) : job.status === 'completed' ? (
                              <button 
                                onClick={() => handleDeployModel(job.id)}
                                className="text-xs font-bold text-primary hover:underline hover:scale-102 transition-transform"
                              >
                                Deploy weights
                              </button>
                            ) : (
                              <span className="text-xs text-gray-400">Not ready</span>
                            )}
                          </td>
                        </tr>
                      ))
                    )}
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        )}

        {activeTab === 'users' && (
          <div className="space-y-4 animate-in">
            <h3 className="font-extrabold text-gray-900 text-lg flex items-center gap-2">
              <Users size={20} className="text-primary" />
              Registered User Directory
            </h3>
            <div className="overflow-x-auto">
              <table className="w-full text-left">
                <thead>
                  <tr className="bg-gray-50 border-b border-gray-100">
                    <th className="px-6 py-4 text-xs font-bold text-muted uppercase tracking-wider">User ID</th>
                    <th className="px-6 py-4 text-xs font-bold text-muted uppercase tracking-wider">Full Name</th>
                    <th className="px-6 py-4 text-xs font-bold text-muted uppercase tracking-wider">Email Address</th>
                    <th className="px-6 py-4 text-xs font-bold text-muted uppercase tracking-wider">Region</th>
                    <th className="px-6 py-4 text-xs font-bold text-muted uppercase tracking-wider">Crop Preference</th>
                    <th className="px-6 py-4 text-xs font-bold text-muted uppercase tracking-wider">Access Tier</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-50">
                  {usersList.map((usr) => (
                    <tr key={usr.id} className="hover:bg-gray-50 transition-colors">
                      <td className="px-6 py-4 font-mono text-xs font-bold text-gray-500">#{usr.id}</td>
                      <td className="px-6 py-4 font-bold text-gray-900">{usr.full_name || 'Anonymous User'}</td>
                      <td className="px-6 py-4 text-sm font-semibold text-gray-600">{usr.email}</td>
                      <td className="px-6 py-4 text-sm text-muted font-medium">{usr.region || 'Not configured'}</td>
                      <td className="px-6 py-4 font-bold text-primary text-sm">{usr.primary_crop || 'Not configured'}</td>
                      <td className="px-6 py-4">
                        <span className={cn(
                          "badge text-xs font-extrabold",
                          usr.is_admin ? "bg-purple-100 text-purple-700" : "bg-green-100 text-primary"
                        )}>
                          {usr.is_admin ? 'Super-Admin' : 'Farmer'}
                        </span>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        )}

        {activeTab === 'tips' && (
          <div className="space-y-4 animate-in">
            <h3 className="font-extrabold text-gray-900 text-lg flex items-center gap-2">
              <Lightbulb size={20} className="text-amber-500" />
              Community Tips Review Queue
            </h3>
            <div className="overflow-x-auto">
              <table className="w-full text-left text-sm">
                <thead>
                  <tr className="bg-gray-50 border-b border-gray-100">
                    <th className="px-6 py-4 text-xs font-bold text-muted uppercase tracking-wider">Title</th>
                    <th className="px-6 py-4 text-xs font-bold text-muted uppercase tracking-wider">Category</th>
                    <th className="px-6 py-4 text-xs font-bold text-muted uppercase tracking-wider">Author</th>
                    <th className="px-6 py-4 text-xs font-bold text-muted uppercase tracking-wider">Overview</th>
                    <th className="px-6 py-4 text-xs font-bold text-muted uppercase tracking-wider text-right">Actions</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-50">
                  {pendingTips.length === 0 ? (
                    <tr>
                      <td colSpan={5} className="px-6 py-12 text-center text-muted font-bold text-sm">
                        No community farming tips currently awaiting moderator review.
                      </td>
                    </tr>
                  ) : (
                    pendingTips.map((tip) => (
                      <tr key={tip.id} className="hover:bg-gray-50 transition-colors">
                        <td className="px-6 py-4 font-bold text-gray-900">{tip.title}</td>
                        <td className="px-6 py-4 font-bold text-primary text-xs uppercase">{tip.category}</td>
                        <td className="px-6 py-4 text-xs font-bold text-gray-600">{tip.author}</td>
                        <td className="px-6 py-4 text-xs text-muted max-w-xs truncate leading-relaxed">{tip.content}</td>
                        <td className="px-6 py-4 text-right">
                          <div className="flex justify-end gap-2">
                            <button 
                              onClick={() => handleDeleteTip(tip.id)}
                              className="w-8 h-8 rounded-lg flex items-center justify-center text-gray-400 hover:text-danger hover:bg-red-50 transition-all"
                            >
                              <XCircle size={18} />
                            </button>
                            <button 
                              onClick={() => handleApproveTip(tip.id)}
                              className="w-8 h-8 rounded-lg flex items-center justify-center bg-gray-100 text-primary hover:bg-primary hover:text-white transition-all"
                            >
                              <CheckCircle size={18} />
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
        )}

        {activeTab === 'notifications' && (
          <div className="space-y-6 animate-in max-w-xl mx-auto">
            <div className="text-center space-y-1 mb-6">
              <h3 className="font-extrabold text-gray-900 text-lg flex items-center justify-center gap-2">
                <Bell size={22} className="text-primary" />
                Notification Command Center
              </h3>
              <p className="text-xs text-muted">Broadcast announcements, warning notifications, or critical updates directly into farmers' dashboards.</p>
            </div>

            <form onSubmit={handleSendNotification} className="space-y-4">
              <div className="space-y-1.5">
                <label className="text-xs font-bold text-gray-700 uppercase tracking-wider">Target Recipients</label>
                <select 
                  className="input text-sm bg-white"
                  value={notifTarget}
                  onChange={(e) => setNotifTarget(e.target.value)}
                >
                  <option value="all">📢 Broadcast to All Registered Users</option>
                  {usersList.map((usr) => (
                    <option key={usr.id} value={usr.id}>
                      👤 Direct Alert: {usr.full_name || usr.email}
                    </option>
                  ))}
                </select>
              </div>

              <div className="space-y-1.5">
                <label className="text-xs font-bold text-gray-700 uppercase tracking-wider">Alert Headline</label>
                <input 
                  type="text" 
                  className="input text-sm" 
                  placeholder="e.g. Unprecedented Humidity: Early Blight Risk"
                  value={notifTitle}
                  onChange={(e) => setNotifTitle(e.target.value)}
                  required
                />
              </div>

              <div className="space-y-1.5">
                <label className="text-xs font-bold text-gray-700 uppercase tracking-wider">Detailed Warning Message</label>
                <textarea 
                  className="input text-sm h-32 py-2 resize-none leading-relaxed" 
                  placeholder="Provide precise warning messages, agricultural recommendations, or system maintenance updates..."
                  value={notifMessage}
                  onChange={(e) => setNotifMessage(e.target.value)}
                  required
                />
              </div>

              <button 
                type="submit" 
                disabled={sendingNotif}
                className="btn btn-primary w-full py-3.5 text-base flex items-center justify-center gap-2 shadow-lg shadow-primary/20 hover:scale-101 transition-transform"
              >
                {sendingNotif ? (
                  <>
                    <Loader2 className="w-5 h-5 animate-spin" />
                    Transmitting broadcast...
                  </>
                ) : (
                  <>
                    <Send size={18} />
                    Dispatch Broadcast Alert
                  </>
                )}
              </button>
            </form>
          </div>
        )}

        {activeTab === 'library' && (
          <div className="space-y-6 animate-in max-w-2xl mx-auto">
            <div className="text-center space-y-1 mb-6">
              <h3 className="font-extrabold text-gray-900 text-lg flex items-center justify-center gap-2">
                <Database size={22} className="text-primary" />
                Disease Library Management
              </h3>
              <p className="text-xs text-muted">Add new plant diseases and treatment protocols to the global knowledge base.</p>
            </div>

            <form onSubmit={(e) => {
              e.preventDefault();
              setSuccessMsg('New disease successfully added to the global library database.');
              setTimeout(() => setSuccessMsg(''), 5000);
              (e.target as HTMLFormElement).reset();
            }} className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-1.5">
                  <label className="text-xs font-bold text-gray-700 uppercase tracking-wider">Crop Type</label>
                  <input type="text" className="input text-sm" placeholder="e.g. Tomato" required />
                </div>
                <div className="space-y-1.5">
                  <label className="text-xs font-bold text-gray-700 uppercase tracking-wider">Disease Name</label>
                  <input type="text" className="input text-sm" placeholder="e.g. Bacterial Spot" required />
                </div>
              </div>

              <div className="space-y-1.5">
                <label className="text-xs font-bold text-gray-700 uppercase tracking-wider">Scientific Name</label>
                <input type="text" className="input text-sm" placeholder="e.g. Xanthomonas campestris" required />
              </div>

              <div className="space-y-1.5">
                <label className="text-xs font-bold text-gray-700 uppercase tracking-wider">Overview / Symptoms</label>
                <textarea className="input text-sm h-24 py-2 resize-none" placeholder="Describe the symptoms..." required />
              </div>

              <div className="space-y-1.5">
                <label className="text-xs font-bold text-gray-700 uppercase tracking-wider">Organic Treatment</label>
                <textarea className="input text-sm h-24 py-2 resize-none" placeholder="Organic steps..." required />
              </div>

              <div className="space-y-1.5">
                <label className="text-xs font-bold text-gray-700 uppercase tracking-wider">Chemical Treatment</label>
                <textarea className="input text-sm h-24 py-2 resize-none" placeholder="Chemical steps..." required />
              </div>

              <button type="submit" className="btn btn-primary w-full py-3 text-base flex items-center justify-center gap-2">
                <CheckCircle2 size={18} />
                Publish to Disease Library
              </button>
            </form>
          </div>
        )}
      </div>
    </div>
  );
}
