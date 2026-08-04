'use client';

import { useState, useEffect } from 'react';
import { 
  Lightbulb, 
  Droplets, 
  ShieldCheck, 
  Zap, 
  Wind, 
  ArrowRight,
  Plus,
  X,
  Loader2,
  CheckCircle2,
  BookOpen,
  User,
  Sprout
} from 'lucide-react';
import { cn } from '@/app/utils';
import { motion, AnimatePresence } from 'framer-motion';

// Hardcoded fallback list in case database is empty or server is offline
const fallbackTips = [
  { id: 1, title: 'Watering Schedule', category: 'General', read_time: '2 min read', content: 'Water your tomato plants early in the morning to allow leaves to dry during the day, preventing fungal spores from germinating.', detailed_content: 'Watering overhead late in the evening leaves foliage wet overnight, creating a highly conducive environment for leaf spots and mildews to manifest. Drip irrigation or watering directly at the soil line is strongly recommended to protect foliage.', author: 'AgroSentry Agronomist', is_approved: true },
  { id: 2, title: 'Proper Spacing', category: 'General', read_time: '3 min read', content: 'Ensure at least 24 inches between tomato plants to promote airflow, which significantly reduces the risk of Leaf Mold.', detailed_content: 'Stagnant humidity in tight canopies acts as an incubator for pathogens. Pruning lower leaves up to the first fruit cluster and keeping crops appropriately spaced allows breeze to carry away moisture, protecting your crops naturally.', author: 'AgroSentry Agronomist', is_approved: true },
  { id: 3, title: 'Early Detection', category: 'General', read_time: '2 min read', content: 'Inspect the undersides of lower leaves weekly. Early blights usually start from the bottom of the plant.', detailed_content: 'Fungal spores often splash up from the soil onto lower limbs first. Routine scouting of lower vegetation helps isolate infestations before they climb. Cut off infected limbs immediately and disinfect shears with rubbing alcohol.', author: 'AgroSentry Agronomist', is_approved: true },
  { id: 4, title: 'Organic Spray', category: 'Potato', read_time: '3 min read', content: 'A mixture of baking soda and neem oil acts as a powerful preventative organic fungicide for potato late blight.', detailed_content: 'Mix 1 tablespoon of baking soda, 1 teaspoon of liquid dish soap, and 1 tablespoon of neem oil in a gallon of water. Spray this fine mist on leaves every 7-10 days during cool, humid spells to shield leaves before spores attach.', author: 'AgroSentry Agronomist', is_approved: true }
];

export default function TipsPage() {
  const [tips, setTips] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  
  // Modal states
  const [selectedTip, setSelectedTip] = useState<any>(null);
  const [showSubmitModal, setShowSubmitModal] = useState(false);
  const [successMsg, setSuccessMsg] = useState('');
  
  // Submit Form states
  const [newTip, setNewTip] = useState({
    title: '',
    category: 'General',
    content: '',
    detailed_content: ''
  });
  const [submitting, setSubmitting] = useState(false);

  const fetchTips = async () => {
    try {
      const response = await fetch('http://localhost:8000/api/tips');
      if (response.ok) {
        const data = await response.json();
        setTips(data.length > 0 ? data : fallbackTips);
      } else {
        setTips(fallbackTips);
      }
    } catch (error) {
      console.error('Failed to fetch tips', error);
      setTips(fallbackTips);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchTips();
  }, []);

  const getTipIcon = (title: string) => {
    const t = title.toLowerCase();
    if (t.includes('water')) return Droplets;
    if (t.includes('space') || t.includes('airflow')) return Wind;
    if (t.includes('detect') || t.includes('early')) return Lightbulb;
    if (t.includes('spray') || t.includes('organic')) return ShieldCheck;
    return Sprout;
  };

  const getTipBgColor = (title: string) => {
    const t = title.toLowerCase();
    if (t.includes('water')) return 'bg-blue-50 text-blue-500';
    if (t.includes('space') || t.includes('airflow')) return 'bg-green-50 text-green-500';
    if (t.includes('detect') || t.includes('early')) return 'bg-amber-50 text-amber-500';
    if (t.includes('spray') || t.includes('organic')) return 'bg-primary-light text-primary';
    return 'bg-purple-50 text-purple-500';
  };

  const handleSubmitTip = async (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitting(true);
    setSuccessMsg('');
    try {
      const response = await fetch('http://localhost:8000/api/tips/submit', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        },
        body: JSON.stringify(newTip),
      });

      if (response.ok) {
        const data = await response.json();
        setShowSubmitModal(false);
        setSuccessMsg(
          data.is_approved 
            ? 'Insight submitted! Since you are an Admin, your tip has been automatically approved and published!'
            : 'Insight submitted! An agronomist will review and approve your submission shortly.'
        );
        setNewTip({ title: '', category: 'General', content: '', detailed_content: '' });
        fetchTips();
        setTimeout(() => setSuccessMsg(''), 6000);
      } else if (response.status === 401) {
        alert('Please login to submit a tip.');
      } else {
        alert('Failed to submit tip. Please check all fields.');
      }
    } catch (error) {
      console.error('Failed to submit tip', error);
      alert('Error connecting to backend.');
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="space-y-8 animate-in relative">
      <header className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Quick Tips</h1>
          <p className="text-muted mt-1">Best practices for maintaining a healthy harvest.</p>
        </div>
        <button 
          onClick={() => setShowSubmitModal(true)}
          className="btn btn-primary flex items-center gap-2 shadow-lg shadow-primary/20 hover:scale-102 transition-transform"
        >
          <Plus size={18} />
          Submit Tip
        </button>
      </header>

      {successMsg && (
        <div className="bg-primary/10 border border-primary/20 p-4 rounded-xl flex items-center gap-3 text-primary animate-in slide-in-from-top duration-300">
          <CheckCircle2 className="flex-shrink-0" size={20} />
          <p className="text-sm font-bold">{successMsg}</p>
        </div>
      )}

      {loading ? (
        <div className="min-h-[40vh] flex flex-col items-center justify-center gap-3">
          <Loader2 className="w-10 h-10 text-primary animate-spin" />
          <p className="text-sm font-bold text-gray-500 font-sans">Cultivating Farming Tips...</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {tips.map((tip) => {
            const Icon = getTipIcon(tip.title);
            const badgeClasses = getTipBgColor(tip.title);
            return (
              <div 
                key={tip.id} 
                onClick={() => setSelectedTip(tip)}
                className="card p-8 group hover:border-primary cursor-pointer hover:shadow-xl transition-all duration-300 flex flex-col justify-between"
              >
                <div>
                  <div className={cn("w-16 h-16 rounded-2xl flex items-center justify-center mb-6 shadow-inner", badgeClasses.split(' ')[0])}>
                    <Icon size={32} className={badgeClasses.split(' ')[1]} />
                  </div>
                  <h3 className="text-2xl font-bold text-gray-900 mb-3 group-hover:text-primary transition-colors">{tip.title}</h3>
                  <p className="text-gray-600 leading-relaxed text-sm line-clamp-3">
                    {tip.content}
                  </p>
                </div>
                
                <div className="mt-8 pt-8 border-t border-gray-50 flex justify-between items-center group-hover:border-primary/10 transition-colors">
                  <span className="text-[10px] font-extrabold text-muted uppercase tracking-widest bg-gray-50 px-2 py-0.5 rounded border border-gray-100">{tip.category} Guide</span>
                  <button className="text-primary font-bold text-sm flex items-center gap-2 group-hover:translate-x-1 transition-transform">
                    Read More <ArrowRight size={18} />
                  </button>
                </div>
              </div>
            );
          })}
        </div>
      )}

      {/* Extra Advice Banner */}
      <div className="card bg-gray-900 border-none p-12 text-center space-y-4 shadow-2xl relative overflow-hidden">
        <div className="absolute -right-16 -top-16 w-48 h-48 bg-primary/20 rounded-full blur-2xl" />
        <div className="absolute -left-16 -bottom-16 w-48 h-48 bg-blue-500/10 rounded-full blur-2xl" />
        <h2 className="text-3xl font-extrabold text-white">Need customized advice?</h2>
        <p className="text-gray-400 max-w-lg mx-auto text-base">
          Our agronomists and AI neural nodes are standing by to inspect specific anomalies. Upload a crop scan today.
        </p>
        <div className="pt-4">
          <button 
            onClick={() => window.location.href = '/scan'} 
            className="btn btn-primary px-10 py-4 text-base font-bold shadow-xl shadow-primary/20 hover:scale-102 transition-transform"
          >
            Go to Scanner
          </button>
        </div>
      </div>

      {/* Stunning Read More Tip Modal */}
      <AnimatePresence>
        {selectedTip && (
          <div className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50 p-4">
            <motion.div 
              initial={{ scale: 0.9, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              exit={{ scale: 0.9, opacity: 0 }}
              className="bg-white w-full max-w-2xl rounded-3xl overflow-hidden shadow-2xl border border-gray-100 flex flex-col max-h-[90vh]"
            >
              <div className={cn("p-8 relative border-b border-gray-50 flex items-center gap-4", getTipBgColor(selectedTip.title).split(' ')[0])}>
                <button 
                  onClick={() => setSelectedTip(null)}
                  className="absolute top-4 right-4 w-10 h-10 bg-white rounded-full shadow-lg flex items-center justify-center text-gray-500 hover:text-danger hover:scale-105 transition-all"
                >
                  <X size={20} />
                </button>
                <div className="p-3 bg-white rounded-2xl shadow-md">
                  {(() => {
                    const Icon = getTipIcon(selectedTip.title);
                    return <Icon size={32} className={getTipBgColor(selectedTip.title).split(' ')[1]} />;
                  })()}
                </div>
                <div className="space-y-1">
                  <span className="badge bg-white/60 text-primary-dark border border-primary/20 font-bold uppercase tracking-wider text-[10px]">{selectedTip.category} Framework</span>
                  <h3 className="text-2xl font-black text-gray-900 leading-tight">{selectedTip.title}</h3>
                </div>
              </div>

              <div className="p-8 overflow-y-auto space-y-6 flex-1 bg-white leading-relaxed">
                <div className="space-y-2">
                  <span className="text-xs font-bold text-gray-400 uppercase tracking-widest">Brief Insight</span>
                  <p className="text-gray-700 text-base font-bold bg-gray-50 p-4 rounded-2xl border border-gray-100/50 italic">{selectedTip.content}</p>
                </div>

                {selectedTip.detailed_content && (
                  <div className="space-y-2 pt-4 border-t border-gray-50">
                    <span className="text-xs font-bold text-gray-400 uppercase tracking-widest">Actionable Guidelines & Analysis</span>
                    <p className="text-gray-600 text-sm font-medium leading-relaxed">{selectedTip.detailed_content}</p>
                  </div>
                )}

                <div className="flex justify-between items-center pt-6 border-t border-gray-50 text-xs font-bold text-gray-400">
                  <div className="flex items-center gap-2">
                    <User size={14} className="text-primary" />
                    <span>Contributor: {selectedTip.author}</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <BookOpen size={14} className="text-blue-500" />
                    <span>Estimated: {selectedTip.read_time}</span>
                  </div>
                </div>
              </div>

              <div className="p-4 bg-gray-50 border-t border-gray-100 flex justify-end">
                <button 
                  onClick={() => setSelectedTip(null)}
                  className="btn btn-primary px-8 py-2.5 text-sm"
                >
                  Close Framework
                </button>
              </div>
            </motion.div>
          </div>
        )}
      </AnimatePresence>

      {/* Stunning Submit Tip Modal */}
      <AnimatePresence>
        {showSubmitModal && (
          <div className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50 p-4 overflow-y-auto">
            <motion.div 
              initial={{ scale: 0.9, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              exit={{ scale: 0.9, opacity: 0 }}
              className="bg-white w-full max-w-xl rounded-3xl overflow-hidden shadow-2xl border border-gray-100"
            >
              <form onSubmit={handleSubmitTip}>
                <div className="p-6 bg-gradient-to-r from-primary/10 to-primary-light border-b border-gray-100 relative">
                  <button 
                    type="button"
                    onClick={() => setShowSubmitModal(false)}
                    className="absolute top-4 right-4 w-10 h-10 bg-white rounded-full shadow-lg flex items-center justify-center text-gray-500 hover:text-danger transition-colors"
                  >
                    <X size={20} />
                  </button>
                  <h3 className="text-2xl font-black text-gray-900 flex items-center gap-2">
                    <Lightbulb size={24} className="text-primary" />
                    Submit Custom Farming Insight
                  </h3>
                  <p className="text-xs text-gray-500 mt-1">Share your knowledge with our global agricultural community.</p>
                </div>

                <div className="p-6 space-y-4">
                  <div className="space-y-1.5">
                    <label className="text-xs font-bold text-gray-700 uppercase tracking-wider">Tip Title</label>
                    <input 
                      type="text" 
                      className="input text-sm" 
                      placeholder="e.g. Tomato Leaf Pruning"
                      value={newTip.title}
                      onChange={(e) => setNewTip({...newTip, title: e.target.value})}
                      required
                    />
                  </div>

                  <div className="space-y-1.5">
                    <label className="text-xs font-bold text-gray-700 uppercase tracking-wider">Crop Category / Category</label>
                    <select 
                      className="input text-sm bg-white"
                      value={newTip.category}
                      onChange={(e) => setNewTip({...newTip, category: e.target.value})}
                    >
                      <option value="General">General Gardening</option>
                      <option value="Apple">Apple Orchard</option>
                      <option value="Blueberry">Blueberry Farming</option>
                      <option value="Cherry">Cherry Orchard</option>
                      <option value="Corn">Cornfield Management</option>
                      <option value="Grape">Vineyard Management</option>
                      <option value="Potato">Potato Plots</option>
                    </select>
                  </div>

                  <div className="space-y-1.5">
                    <label className="text-xs font-bold text-gray-700 uppercase tracking-wider">Brief Summary Description</label>
                    <textarea 
                      className="input text-sm h-20 py-2 resize-none" 
                      placeholder="Write a clear, concise summary of your advice..."
                      value={newTip.content}
                      onChange={(e) => setNewTip({...newTip, content: e.target.value})}
                      required
                    />
                  </div>

                  <div className="space-y-1.5">
                    <label className="text-xs font-bold text-gray-700 uppercase tracking-wider">Detailed Guidelines & Actionable Explanations</label>
                    <textarea 
                      className="input text-sm h-28 py-2 resize-none" 
                      placeholder="Give a thorough explanation, including ingredients, dosages, or detailed techniques..."
                      value={newTip.detailed_content}
                      onChange={(e) => setNewTip({...newTip, detailed_content: e.target.value})}
                      required
                    />
                  </div>
                </div>

                <div className="p-4 bg-gray-50 border-t border-gray-100 flex justify-end gap-3">
                  <button 
                    type="button" 
                    onClick={() => setShowSubmitModal(false)}
                    className="btn btn-outline py-2 px-6"
                  >
                    Cancel
                  </button>
                  <button 
                    type="submit" 
                    disabled={submitting}
                    className="btn btn-primary py-2 px-8 flex items-center gap-2"
                  >
                    {submitting ? (
                      <>
                        <Loader2 className="w-4 h-4 animate-spin" />
                        Submitting...
                      </>
                    ) : (
                      'Submit Insight'
                    )}
                  </button>
                </div>
              </form>
            </motion.div>
          </div>
        )}
      </AnimatePresence>
    </div>
  );
}
