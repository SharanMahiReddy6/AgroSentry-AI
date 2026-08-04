'use client';

import { useState, useEffect } from 'react';
import { 
  Search, 
  Leaf, 
  Sprout, 
  Zap, 
  Bug, 
  ArrowRight,
  ChevronRight,
  Info,
  X,
  ShieldCheck,
  FlaskConical,
  Activity,
  Loader2,
  CheckCircle2
} from 'lucide-react';
import { cn } from '@/app/utils';
import { motion, AnimatePresence } from 'framer-motion';

// Hardcoded fallback list in case backend is offline
const fallbackDiseases = [
  { id: '1', common_name: 'Late Blight', crop_type: 'Potato', scientific_name: 'Phytophthora infestans', overview: 'A highly destructive fungal-like pathogen causing rapid browning and rot on potatoes and tomatoes.', causes: ['High humidity', 'Wet leaves', 'Cool temperatures'], symptoms: [{'title': 'Dark Spotting', 'description': 'Dark water-soaked spots on leaves.'}], treatments: { 'Medium': { organic: [], chemical: { safetyMessage: 'Use protective clothing.', products: [] }, preventive: [] } } },
  { id: '2', common_name: 'Early Blight', crop_type: 'Tomato', scientific_name: 'Alternaria solani', overview: 'Common fungus causing concentric ring brown spots on older tomato leaves.', causes: ['Warm damp conditions', 'Overcrowding'], symptoms: [{'title': 'Target Rings', 'description': 'Dark spots with concentric target-like rings.'}], treatments: { 'Medium': { organic: [], chemical: { safetyMessage: '', products: [] }, preventive: [] } } },
  { id: '3', common_name: 'Black Rot', crop_type: 'Apple', scientific_name: 'Botryosphaeria obtusa', overview: 'Fungal infection causing frog-eye leaf spots, sunken wood lesions, and fruit shrivel.', causes: ['Dead wood in canopy', 'Insect punctures'], symptoms: [{'title': 'Frog-Eye Spotting', 'description': 'Small purple spots with tan centers.'}], treatments: { 'Medium': { organic: [], chemical: { safetyMessage: '', products: [] }, preventive: [] } } },
  { id: '4', common_name: 'Leaf Mold', crop_type: 'Tomato', scientific_name: 'Passalora fulva', overview: 'Velvety olive-green mold appearing on lower tomato leaves in highly humid greenhouses.', causes: ['High greenhouse humidity', 'Lack of ventilation'], symptoms: [{'title': 'Velvety underside', 'description': 'Greenish-black mold on leaf bottoms.'}], treatments: { 'Medium': { organic: [], chemical: { safetyMessage: '', products: [] }, preventive: [] } } },
  { id: '5', common_name: 'Apple Scab', crop_type: 'Apple', scientific_name: 'Venturia inaequalis', overview: 'Causes dark, velvety scabby lesions on apple leaves and fruit, causing cracking.', causes: ['Fallen leaf debris', 'Spring rainfall'], symptoms: [{'title': 'Velvety Spots', 'description': 'Olive-green to black rough spots.'}], treatments: { 'Medium': { organic: [], chemical: { safetyMessage: '', products: [] }, preventive: [] } } },
  { id: '6', common_name: 'Cedar Apple Rust', crop_type: 'Apple', scientific_name: 'Gymnosporangium juniperi-virginianae', overview: 'Requires both cedar and apple hosts to complete life cycle; leaves show bright orange spots.', causes: ['Nearby cedar trees', 'Warm spring rains'], symptoms: [{'title': 'Orange Spots', 'description': 'Bright orange-yellow spots on leaves.'}], treatments: { 'Medium': { organic: [], chemical: { safetyMessage: '', products: [] }, preventive: [] } } },
];

export default function LibraryPage() {
  const [diseases, setDiseases] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedCategory, setSelectedCategory] = useState('All');
  
  // Modal states
  const [selectedDisease, setSelectedDisease] = useState<any>(null);
  const [activeSeverity, setActiveSeverity] = useState<'Low' | 'Medium' | 'High'>('Medium');
  const [activeTab, setActiveTab] = useState<'overview' | 'symptoms' | 'treatment' | 'prevention'>('overview');

  const categories = ['All', 'Apple', 'Blueberry', 'Cherry', 'Corn', 'Grape', 'Orange', 'Peach', 'Pepper', 'Potato', 'Tomato'];

  useEffect(() => {
    const fetchDiseases = async () => {
      try {
        const response = await fetch('http://localhost:8000/api/scans/diseases');
        if (response.ok) {
          const data = await response.json();
          // Transform dictionary to array
          const list = Object.entries(data).map(([key, val]: any) => ({
            id: key,
            ...val
          }));
          setDiseases(list);
        } else {
          setDiseases(fallbackDiseases);
        }
      } catch (error) {
        console.error('Failed to fetch diseases', error);
        setDiseases(fallbackDiseases);
      } finally {
        setLoading(false);
      }
    };
    fetchDiseases();
  }, []);

  const filteredDiseases = diseases.filter(d => {
    const matchesSearch = d.common_name.toLowerCase().includes(searchTerm.toLowerCase()) || 
                          d.scientific_name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                          d.crop_type.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesCategory = selectedCategory === 'All' || d.crop_type.toLowerCase() === selectedCategory.toLowerCase();
    return matchesSearch && matchesCategory;
  });

  const getDiseaseIcon = (crop: string) => {
    switch (crop.toLowerCase()) {
      case 'apple': return Leaf;
      case 'tomato': return Sprout;
      case 'potato': return Zap;
      default: return Bug;
    }
  };

  const openDetails = (disease: any) => {
    setSelectedDisease(disease);
    setActiveSeverity('Medium');
    setActiveTab('overview');
  };

  return (
    <div className="space-y-8 animate-in relative">
      <header className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Disease Library</h1>
          <p className="text-muted mt-1">Learn about common crop threats and how to fight them.</p>
        </div>
        <div className="relative w-full md:w-80">
          <Search className="absolute left-3 top-3 text-gray-400" size={18} />
          <input 
            type="text" 
            placeholder="Search diseases..." 
            className="input pl-10" 
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
        </div>
      </header>

      {/* Categories */}
      <div className="flex gap-2 overflow-x-auto pb-2 no-scrollbar">
        {categories.map((cat) => (
          <button
            key={cat}
            onClick={() => setSelectedCategory(cat)}
            className={cn(
              "px-6 py-2 rounded-full text-sm font-bold whitespace-nowrap transition-all duration-200",
              selectedCategory === cat 
                ? "bg-primary text-white shadow-md shadow-primary/20" 
                : "bg-white text-gray-500 hover:bg-gray-50 border border-gray-100"
            )}
          >
            {cat}
          </button>
        ))}
      </div>

      {/* Disease Grid */}
      {loading ? (
        <div className="min-h-[40vh] flex flex-col items-center justify-center gap-3">
          <Loader2 className="w-10 h-10 text-primary animate-spin" />
          <p className="text-sm font-bold text-gray-500 font-sans">Syncing Disease Library...</p>
        </div>
      ) : filteredDiseases.length === 0 ? (
        <div className="card p-12 text-center text-muted">
          <Bug className="mx-auto text-gray-200 mb-4" size={48} />
          <p className="font-bold text-lg text-gray-900">No diseases found</p>
          <p className="text-sm text-gray-500 mt-1">Try relaxing your search terms or choosing a different category.</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {filteredDiseases.map((disease) => {
            const Icon = getDiseaseIcon(disease.crop_type);
            return (
              <div 
                key={disease.id} 
                onClick={() => openDetails(disease)}
                className="card group flex flex-col cursor-pointer hover:border-primary hover:shadow-xl transition-all duration-300"
              >
                <div className="flex justify-between items-start mb-4">
                  <div className="w-12 h-12 bg-primary/10 rounded-xl flex items-center justify-center text-primary group-hover:bg-primary group-hover:text-white transition-all duration-300">
                    <Icon size={24} />
                  </div>
                  <span className={cn(
                    "badge bg-primary-light text-primary",
                    disease.id.includes('Rust') || disease.id.includes('Blight') ? "bg-red-50 text-red-600" : ""
                  )}>
                    {disease.crop_type}
                  </span>
                </div>
                
                <div className="space-y-2 flex-1">
                  <h3 className="text-xl font-bold text-gray-900 group-hover:text-primary transition-colors">{disease.common_name}</h3>
                  <p className="text-xs italic text-gray-400 font-medium">
                    {disease.scientific_name}
                  </p>
                  <p className="text-sm text-muted leading-relaxed mt-2 line-clamp-3">{disease.overview}</p>
                </div>

                <div className="pt-6 mt-6 border-t border-gray-50 flex items-center justify-between group-hover:border-primary/10 transition-colors">
                  <button className="text-sm font-bold text-primary flex items-center gap-1 group/btn">
                    Learn More <ArrowRight size={14} className="group-hover/btn:translate-x-1 transition-transform" />
                  </button>
                  <ChevronRight size={18} className="text-gray-300" />
                </div>
              </div>
            );
          })}
        </div>
      )}

      {/* Stunning Interactive Learn More Modal */}
      <AnimatePresence>
        {selectedDisease && (
          <div className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50 p-4 overflow-y-auto">
            <motion.div 
              initial={{ scale: 0.9, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              exit={{ scale: 0.9, opacity: 0 }}
              className="bg-white w-full max-w-3xl rounded-3xl overflow-hidden shadow-2xl flex flex-col max-h-[90vh] border border-gray-100"
            >
              {/* Modal Header */}
              <div className="p-6 bg-gradient-to-r from-primary/10 to-primary-light border-b border-gray-100 relative">
                <button 
                  onClick={() => setSelectedDisease(null)}
                  className="absolute top-4 right-4 w-10 h-10 bg-white rounded-full shadow-lg flex items-center justify-center text-gray-500 hover:text-danger hover:scale-105 transition-all"
                >
                  <X size={20} />
                </button>
                <div className="space-y-1">
                  <span className="badge bg-primary text-white text-xs font-bold uppercase tracking-wider">{selectedDisease.crop_type} Threat</span>
                  <h2 className="text-3xl font-extrabold text-gray-900 leading-tight">{selectedDisease.common_name}</h2>
                  <p className="text-sm text-gray-500 italic font-semibold">{selectedDisease.scientific_name}</p>
                </div>
              </div>

              {/* Modal Severity Selector (Low, Medium, High tabs) */}
              {selectedDisease.treatments && (
                <div className="px-6 py-3 bg-gray-50 border-b border-gray-100 flex items-center gap-4">
                  <span className="text-xs font-extrabold text-gray-500 uppercase tracking-widest">Select Threat Level:</span>
                  <div className="flex bg-white rounded-xl p-1 shadow-inner border border-gray-100">
                    {(['Low', 'Medium', 'High'] as const).map((sev) => (
                      <button
                        key={sev}
                        onClick={() => setActiveSeverity(sev)}
                        className={cn(
                          "px-4 py-1.5 text-xs font-bold rounded-lg transition-all",
                          activeSeverity === sev 
                            ? sev === 'High' 
                              ? "bg-red-500 text-white shadow-md shadow-red-200"
                              : "bg-primary text-white shadow-md shadow-primary/20"
                            : "text-gray-400 hover:text-gray-600"
                        )}
                      >
                        {sev}
                      </button>
                    ))}
                  </div>
                </div>
              )}

              {/* Tabs Selection */}
              <div className="flex bg-white border-b border-gray-50 p-2">
                {[
                  { id: 'overview', label: 'Overview', icon: Info },
                  { id: 'symptoms', label: 'Symptoms', icon: Bug },
                  { id: 'treatment', label: 'Remedies', icon: FlaskConical },
                  { id: 'prevention', label: 'Prevention', icon: ShieldCheck }
                ].map((t) => {
                  const TIcon = t.icon;
                  return (
                    <button
                      key={t.id}
                      onClick={() => setActiveTab(t.id as any)}
                      className={cn(
                        "flex-1 py-3 text-sm font-bold flex items-center justify-center gap-2 border-b-2 transition-all",
                        activeTab === t.id 
                          ? "border-primary text-primary" 
                          : "border-transparent text-gray-400 hover:text-gray-600"
                      )}
                    >
                      <TIcon size={16} />
                      <span className="hidden sm:inline">{t.label}</span>
                    </button>
                  );
                })}
              </div>

              {/* Tab Contents */}
              <div className="p-6 overflow-y-auto flex-1 min-h-[300px] bg-white">
                {activeTab === 'overview' && (
                  <div className="space-y-6 animate-in">
                    <div className="space-y-3">
                      <h4 className="text-lg font-bold text-gray-900">About this Disease</h4>
                      <p className="text-gray-600 leading-relaxed">{selectedDisease.overview}</p>
                    </div>

                    {/* Scientific Properties Grid */}
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 bg-gray-50 p-5 rounded-2xl border border-gray-100/50">
                      <div>
                        <span className="text-[10px] font-extrabold uppercase text-gray-400 tracking-wider">Pathogen Type</span>
                        <p className="text-sm font-extrabold text-gray-800">{selectedDisease.pathogen_type || 'Microscopic Fungus'}</p>
                      </div>
                      <div>
                        <span className="text-[10px] font-extrabold uppercase text-gray-400 tracking-wider">Disease Category</span>
                        <p className="text-sm font-extrabold text-gray-800">{selectedDisease.disease_category || 'Foliar Infection'}</p>
                      </div>
                      <div>
                        <span className="text-[10px] font-extrabold uppercase text-gray-400 tracking-wider">Spread Mechanism</span>
                        <p className="text-sm font-medium text-gray-600">{selectedDisease.spread_mechanism || 'Wind splash and airborne spores'}</p>
                      </div>
                      <div>
                        <span className="text-[10px] font-extrabold uppercase text-gray-400 tracking-wider">Favored Conditions</span>
                        <p className="text-sm font-medium text-gray-600">{selectedDisease.environmental_conditions || 'Relative humidity above 85%'}</p>
                      </div>
                      <div className="sm:col-span-2 border-t border-gray-200/50 pt-3">
                        <span className="text-[10px] font-extrabold uppercase text-danger/80 tracking-wider">Economic & Yield Impact</span>
                        <p className="text-sm font-bold text-danger/90">{selectedDisease.economic_impact || 'Up to 30-50% foliar degradation and yield loss if left untreated.'}</p>
                      </div>
                    </div>

                    <div className="space-y-3">
                      <h4 className="text-sm font-extrabold text-gray-800 uppercase tracking-wider">Primary Causes</h4>
                      <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                        {selectedDisease.causes.map((c: string, idx: number) => (
                          <div key={idx} className="p-3 bg-blue-50/50 rounded-xl border border-blue-100/50 flex items-center gap-3">
                            <div className="w-2 h-2 bg-blue-500 rounded-full flex-shrink-0" />
                            <span className="text-xs font-bold text-blue-900">{c}</span>
                          </div>
                        ))}
                      </div>
                    </div>

                    {selectedDisease.farmer_tips && (
                      <div className="p-4 bg-amber-50 rounded-2xl border border-amber-100 flex items-start gap-3">
                        <span className="text-lg">💡</span>
                        <div>
                          <span className="text-[10px] font-extrabold uppercase text-amber-700 tracking-wider">Expert Farmer Tip</span>
                          <p className="text-xs text-amber-900 font-medium mt-0.5 leading-relaxed">{selectedDisease.farmer_tips}</p>
                        </div>
                      </div>
                    )}
                  </div>
                )}

                {activeTab === 'symptoms' && (
                  <div className="space-y-6 animate-in">
                    <h4 className="text-lg font-bold text-gray-900">Disease Manifestation</h4>

                    {/* Timeline representation of symptoms */}
                    <div className="space-y-4 bg-gray-50 p-5 rounded-2xl border border-gray-100">
                      <div>
                        <span className="badge bg-green-50 text-green-700 border border-green-100 font-bold mb-1 text-[10px]">Low Severity (Early Stage)</span>
                        <p className="text-xs text-gray-600 font-medium leading-relaxed">{selectedDisease.early_stage_symptoms || 'Minor chlorotic spots or superficial lesions on lower foliage.'}</p>
                      </div>
                      <div className="border-t border-gray-200/60 pt-3">
                        <span className="badge bg-amber-50 text-amber-700 border border-amber-100 font-bold mb-1 text-[10px]">Medium Severity (Moderate Stage)</span>
                        <p className="text-xs text-gray-600 font-medium leading-relaxed">{selectedDisease.moderate_stage_symptoms || 'Spots expand with dark margins and noticeable yellow halos.'}</p>
                      </div>
                      <div className="border-t border-gray-200/60 pt-3">
                        <span className="badge bg-red-50 text-red-700 border border-red-100 font-bold mb-1 text-[10px]">High Severity (Severe Stage)</span>
                        <p className="text-xs text-gray-600 font-medium leading-relaxed">{selectedDisease.severe_stage_symptoms || 'Widespread foliar drying, crispy tissue collapse, and leaf drop.'}</p>
                      </div>
                    </div>

                    <div className="space-y-4">
                      <h5 className="text-xs font-extrabold text-gray-500 uppercase tracking-widest">Key Structural Indicators</h5>
                      <div className="grid grid-cols-1 gap-4">
                        {selectedDisease.symptoms.map((s: any, idx: number) => (
                          <div key={idx} className="flex gap-4 p-4 rounded-xl border border-gray-100 bg-white shadow-xs">
                            <div className="w-10 h-10 bg-amber-50 rounded-lg flex items-center justify-center text-amber-600 flex-shrink-0">
                              <Bug size={20} />
                            </div>
                            <div>
                              <h6 className="font-bold text-gray-900 text-sm">{s.title}</h6>
                              <p className="text-xs text-muted mt-1 leading-relaxed">{s.description}</p>
                            </div>
                          </div>
                        ))}
                      </div>
                    </div>
                  </div>
                )}

                {activeTab === 'treatment' && selectedDisease.treatments && (
                  <div className="space-y-6 animate-in">
                    {/* Organic Remedies */}
                    <div className="space-y-3">
                      <h5 className="flex items-center gap-2 text-sm font-extrabold text-gray-800 uppercase tracking-wider">
                        <Leaf size={16} className="text-primary" />
                        Organic Protocol ({activeSeverity})
                      </h5>
                      {selectedDisease.treatments[activeSeverity]?.organic?.length > 0 ? (
                        <div className="grid grid-cols-1 gap-3">
                          {selectedDisease.treatments[activeSeverity].organic.map((item: any, i: number) => (
                            <div key={i} className="p-4 rounded-xl bg-primary/5 border border-primary/10">
                              <h6 className="font-bold text-primary text-sm mb-1">{item.step}. {item.title}</h6>
                              <p className="text-xs text-gray-600 leading-relaxed">{item.description}</p>
                            </div>
                          ))}
                        </div>
                      ) : (
                        <p className="text-xs text-muted italic">No custom organic remedies listed for this severity level.</p>
                      )}
                    </div>

                    {/* Chemical Remedies */}
                    <div className="space-y-3 pt-6 border-t border-gray-50">
                      <h5 className="flex items-center gap-2 text-sm font-extrabold text-gray-800 uppercase tracking-wider">
                        <FlaskConical size={16} className="text-purple-500" />
                        Chemical Protocol ({activeSeverity})
                      </h5>
                      {selectedDisease.treatments[activeSeverity]?.chemical?.safetyMessage && (
                        <p className="text-xs text-purple-700 bg-purple-50 p-2.5 rounded-lg border border-purple-100 italic font-semibold">
                          ⚠️ {selectedDisease.treatments[activeSeverity].chemical.safetyMessage}
                        </p>
                      )}
                      {selectedDisease.treatments[activeSeverity]?.chemical?.products?.length > 0 ? (
                        <div className="space-y-3">
                          {selectedDisease.treatments[activeSeverity].chemical.products.map((prod: any, i: number) => (
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
                        <p className="text-xs text-muted italic">No chemical protective treatments needed at this level.</p>
                      )}
                    </div>
                  </div>
                )}

                {activeTab === 'prevention' && selectedDisease.treatments && (
                  <div className="space-y-6 animate-in">
                    <div className="space-y-4">
                      <h4 className="text-lg font-bold text-gray-900">Preventive Measures ({activeSeverity})</h4>
                      <ul className="space-y-3">
                        {selectedDisease.treatments[activeSeverity]?.preventive?.map((item: string, idx: number) => (
                          <li key={idx} className="flex gap-3 items-center p-3 rounded-xl bg-primary/5 border border-primary/10 text-xs font-bold text-gray-700">
                            <CheckCircle2 size={16} className="text-primary flex-shrink-0" />
                            {item}
                          </li>
                        )) || (
                          <p className="text-xs text-muted italic">General orchard hygiene and crop spacing are recommended.</p>
                        )}
                      </ul>
                    </div>

                    {selectedDisease.recommended_practices && (
                      <div className="space-y-3 pt-6 border-t border-gray-50">
                        <span className="text-[10px] font-extrabold uppercase text-gray-400 tracking-wider">Recommended Agricultural Practices</span>
                        <p className="text-xs text-gray-600 leading-relaxed font-semibold bg-gray-50 p-4 rounded-xl border border-gray-100">
                          {selectedDisease.recommended_practices}
                        </p>
                      </div>
                    )}
                  </div>
                )}
              </div>


              {/* Modal Footer */}
              <div className="p-4 bg-gray-50 border-t border-gray-100 flex justify-end">
                <button 
                  onClick={() => setSelectedDisease(null)}
                  className="btn btn-primary px-8 py-2.5 text-sm"
                >
                  Close Library Sheet
                </button>
              </div>
            </motion.div>
          </div>
        )}
      </AnimatePresence>
    </div>
  );
}
