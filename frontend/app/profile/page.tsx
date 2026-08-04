'use client';

import { useState, useEffect, useRef } from 'react';
import { 
  User, Mail, MapPin, Sprout, Camera, Shield, Save,
  CheckCircle2, Loader2, Lock, Eye, EyeOff,
  Phone, Globe, Trash2, X,
  Sun, Moon, Languages
} from 'lucide-react';
import { cn } from '@/app/utils';
import { motion, AnimatePresence } from 'framer-motion';

type Tab = 'personal' | 'security' | 'preferences';

const INDIA_STATES_CITIES: Record<string, string[]> = {
  'Andhra Pradesh': ['Visakhapatnam','Vijayawada','Guntur','Nellore','Kurnool','Rajahmundry','Tirupati','Kakinada','Kadapa','Anantapur'],
  'Arunachal Pradesh': ['Itanagar','Naharlagun','Pasighat','Tawang','Ziro'],
  'Assam': ['Guwahati','Silchar','Dibrugarh','Jorhat','Nagaon','Tinsukia','Tezpur'],
  'Bihar': ['Patna','Gaya','Bhagalpur','Muzaffarpur','Purnia','Darbhanga','Arrah'],
  'Chhattisgarh': ['Raipur','Bhilai','Bilaspur','Korba','Rajnandgaon','Jagdalpur'],
  'Goa': ['Panaji','Margao','Vasco da Gama','Mapusa','Ponda'],
  'Gujarat': ['Ahmedabad','Surat','Vadodara','Rajkot','Bhavnagar','Jamnagar','Gandhinagar'],
  'Haryana': ['Faridabad','Gurgaon','Panipat','Ambala','Hisar','Rohtak','Karnal'],
  'Himachal Pradesh': ['Shimla','Manali','Dharamshala','Solan','Mandi','Kullu'],
  'Jharkhand': ['Ranchi','Jamshedpur','Dhanbad','Bokaro','Hazaribagh','Giridih'],
  'Karnataka': ['Bengaluru','Mysuru','Hubballi','Mangaluru','Belagavi','Davanagere','Ballari','Vijayapura'],
  'Kerala': ['Thiruvananthapuram','Kochi','Kozhikode','Thrissur','Kollam','Palakkad','Alappuzha','Malappuram'],
  'Madhya Pradesh': ['Bhopal','Indore','Jabalpur','Gwalior','Ujjain','Rewa','Satna'],
  'Maharashtra': ['Mumbai','Pune','Nagpur','Nashik','Aurangabad','Solapur','Amravati','Kolhapur'],
  'Manipur': ['Imphal','Thoubal','Bishnupur','Churachandpur'],
  'Meghalaya': ['Shillong','Tura','Nongstoin','Jowai'],
  'Mizoram': ['Aizawl','Lunglei','Champhai','Serchhip'],
  'Nagaland': ['Kohima','Dimapur','Mokokchung','Wokha'],
  'Odisha': ['Bhubaneswar','Cuttack','Rourkela','Brahmapur','Sambalpur','Puri','Balasore'],
  'Punjab': ['Ludhiana','Amritsar','Jalandhar','Patiala','Bathinda','Mohali','Gurdaspur'],
  'Rajasthan': ['Jaipur','Jodhpur','Udaipur','Kota','Ajmer','Bikaner','Alwar'],
  'Sikkim': ['Gangtok','Namchi','Gyalshing','Mangan'],
  'Tamil Nadu': ['Chennai','Coimbatore','Madurai','Tiruchirappalli','Salem','Tirunelveli','Erode','Vellore','Tiruppur'],
  'Telangana': ['Hyderabad','Warangal','Nizamabad','Karimnagar','Ramagundam','Khammam','Mancherial'],
  'Tripura': ['Agartala','Udaipur','Dharmanagar','Sabroom'],
  'Uttar Pradesh': ['Lucknow','Kanpur','Ghaziabad','Agra','Meerut','Varanasi','Allahabad','Bareilly','Aligarh'],
  'Uttarakhand': ['Dehradun','Haridwar','Roorkee','Haldwani','Rudrapur','Kashipur'],
  'West Bengal': ['Kolkata','Asansol','Siliguri','Durgapur','Bardhaman','Malda','Howrah'],
  'Delhi': ['New Delhi','Dwarka','Rohini','Saket','Janakpuri','Laxmi Nagar'],
  'Jammu & Kashmir': ['Srinagar','Jammu','Anantnag','Baramulla','Sopore'],
  'Ladakh': ['Leh','Kargil'],
  'Puducherry': ['Puducherry','Karaikal','Mahe','Yanam'],
  'Chandigarh': ['Chandigarh'],
  'Andaman & Nicobar Islands': ['Port Blair'],
  'Dadra & Nagar Haveli and Daman & Diu': ['Daman','Diu','Silvassa'],
  'Lakshadweep': ['Kavaratti'],
};

const STATE_LIST = Object.keys(INDIA_STATES_CITIES).sort();

export default function ProfilePage() {
  const [activeTab, setActiveTab] = useState<Tab>('personal');
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [successMsg, setSuccessMsg] = useState('');
  const [errorMsg, setErrorMsg] = useState('');
  const fileInputRef = useRef<HTMLInputElement>(null);

  const [initialLanguage, setInitialLanguage] = useState('en');

  const [profile, setProfile] = useState<any>({
    full_name: '', email: '', region: '', primary_crop: 'Apple',
    username: '', phone_number: '', location: '',
    profile_photo: null, theme: 'light', language: 'en',
    email_notifications: true, push_notifications: true,
    privacy_share_data: true, two_factor_enabled: false,
    created_at: null
  });

  const [passwords, setPasswords] = useState({ old: '', new: '', confirm: '' });
  const [showOld, setShowOld] = useState(false);
  const [showNew, setShowNew] = useState(false);
  const [pwdSaving, setPwdSaving] = useState(false);

  const token = () => localStorage.getItem('token');

  const showSuccess = (msg: string) => {
    setSuccessMsg(msg); setErrorMsg('');
    setTimeout(() => setSuccessMsg(''), 4000);
  };
  const showError = (msg: string) => {
    setErrorMsg(msg); setSuccessMsg('');
    setTimeout(() => setErrorMsg(''), 5000);
  };

  useEffect(() => {
    const fetchAll = async () => {
      try {
        const res = await fetch('http://localhost:8000/api/auth/me', {
          headers: { 'Authorization': `Bearer ${token()}` }
        });
        if (res.ok) {
          const data = await res.json();
          setProfile(data);
          setInitialLanguage(data.language || 'en');
          // Apply saved theme on load
          if (data.theme === 'dark') {
            document.documentElement.classList.add('dark');
          } else {
            document.documentElement.classList.remove('dark');
          }
        } else if (res.status === 401) window.location.href = '/login';
      } catch (e) {
        console.error(e);
      } finally { setLoading(false); }
    };
    fetchAll();
  }, []);

  // Apply theme immediately when profile.theme changes
  useEffect(() => {
    if (profile.theme === 'dark') {
      document.documentElement.classList.add('dark');
    } else {
      document.documentElement.classList.remove('dark');
    }
  }, [profile.theme]);

  const handleSaveProfile = async () => {
    setSaving(true);
    try {
      const res = await fetch('http://localhost:8000/api/auth/me', {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token()}` },
        body: JSON.stringify({
          full_name: profile.full_name, region: profile.region,
          primary_crop: profile.primary_crop, username: profile.username,
          phone_number: profile.phone_number, location: profile.location,
          theme: profile.theme, language: profile.language,
          email_notifications: profile.email_notifications,
          push_notifications: profile.push_notifications,
          privacy_share_data: profile.privacy_share_data,
          two_factor_enabled: profile.two_factor_enabled
        })
      });
      if (res.ok) {
        const updatedProfile = await res.json();
        setProfile(updatedProfile);
        if (initialLanguage !== updatedProfile.language) {
          window.location.reload();
        } else {
          showSuccess('Profile saved successfully.');
        }
      } else showError('Failed to save. Please try again.');
    } catch { showError('Connection error.'); } finally { setSaving(false); }
  };

  const handlePhotoUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    const fd = new FormData(); fd.append('file', file);
    try {
      const res = await fetch('http://localhost:8000/api/auth/me/photo', {
        method: 'POST',
        headers: { 'Authorization': `Bearer ${token()}` },
        body: fd
      });
      if (res.ok) { setProfile(await res.json()); showSuccess('Photo updated.'); }
    } catch { showError('Photo upload failed.'); }
  };

  const handleRemovePhoto = async () => {
    try {
      const res = await fetch('http://localhost:8000/api/auth/me/photo', {
        method: 'DELETE', headers: { 'Authorization': `Bearer ${token()}` }
      });
      if (res.ok) { setProfile({ ...profile, profile_photo: null }); showSuccess('Photo removed.'); }
    } catch { showError('Failed to remove photo.'); }
  };

  const handleChangePassword = async () => {
    if (passwords.new !== passwords.confirm) return showError('New passwords do not match.');
    if (passwords.new.length < 6) return showError('Password must be at least 6 characters.');
    setPwdSaving(true);
    try {
      const res = await fetch('http://localhost:8000/api/auth/me/password', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token()}` },
        body: JSON.stringify({ old_password: passwords.old, new_password: passwords.new })
      });
      if (res.ok) { showSuccess('Password changed successfully.'); setPasswords({ old: '', new: '', confirm: '' }); }
      else { const d = await res.json(); showError(d.detail || 'Incorrect current password.'); }
    } catch { showError('Connection error.'); } finally { setPwdSaving(false); }
  };

  const getInitials = (name: string) =>
    name ? name.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2) : 'U';

  const tabs: { id: Tab; label: string; icon: any }[] = [
    { id: 'personal', label: 'Personal Info', icon: User },
    { id: 'security', label: 'Security', icon: Shield },
    { id: 'preferences', label: 'Preferences', icon: Globe },
  ];

  const citiesForState = profile.region ? (INDIA_STATES_CITIES[profile.region] || []) : [];

  if (loading) return (
    <div className="min-h-[60vh] flex flex-col items-center justify-center gap-3">
      <Loader2 className="w-10 h-10 text-primary animate-spin" />
      <p className="text-sm font-bold text-gray-500">Loading profile...</p>
    </div>
  );

  return (
    <div className="max-w-5xl mx-auto space-y-8 animate-in">
      <header>
        <h1 className="text-3xl font-bold text-gray-900">Account Settings</h1>
        <p className="text-muted mt-1">Manage your identity, security, and farming preferences.</p>
      </header>

      <AnimatePresence>
        {successMsg && (
          <motion.div initial={{ opacity: 0, y: -10 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0 }}
            className="bg-primary/10 border border-primary/20 p-4 rounded-xl flex items-center gap-3 text-primary">
            <CheckCircle2 size={18} className="flex-shrink-0" />
            <p className="text-sm font-bold">{successMsg}</p>
          </motion.div>
        )}
        {errorMsg && (
          <motion.div initial={{ opacity: 0, y: -10 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0 }}
            className="bg-red-50 border border-red-200 p-4 rounded-xl flex items-center gap-3 text-red-700">
            <X size={18} className="flex-shrink-0" />
            <p className="text-sm font-bold">{errorMsg}</p>
          </motion.div>
        )}
      </AnimatePresence>

      <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
        {/* Left Panel */}
        <div className="md:col-span-1 space-y-5">
          <div className="card text-center p-8 space-y-4">
            <div className="relative inline-block mx-auto">
              {profile.profile_photo ? (
                <img src={`http://localhost:8000${profile.profile_photo}`} alt="avatar"
                  className="w-28 h-28 rounded-3xl object-cover border-4 border-white shadow-xl" />
              ) : (
                <div className="w-28 h-28 rounded-3xl bg-primary/10 flex items-center justify-center text-primary text-3xl font-bold border-4 border-white shadow-xl">
                  {getInitials(profile.full_name)}
                </div>
              )}
              <button onClick={() => fileInputRef.current?.click()}
                className="absolute -bottom-2 -right-2 w-9 h-9 bg-white rounded-xl shadow-lg flex items-center justify-center text-gray-500 hover:text-primary transition-colors border border-gray-100">
                <Camera size={16} />
              </button>
              <input ref={fileInputRef} type="file" className="hidden" accept="image/*" onChange={handlePhotoUpload} />
            </div>
            <div>
              <h3 className="text-lg font-bold text-gray-900">{profile.full_name || 'Your Name'}</h3>
              <p className="text-xs text-primary font-bold uppercase tracking-wider mt-0.5">
                {profile.is_admin ? 'Administrator' : 'Premium Farmer'}
              </p>
            </div>
            {profile.profile_photo && (
              <button onClick={handleRemovePhoto}
                className="text-xs text-red-400 hover:text-red-600 font-semibold flex items-center gap-1 mx-auto">
                <Trash2 size={12} /> Remove photo
              </button>
            )}
            {profile.created_at && (
              <p className="text-[10px] text-gray-400 font-medium">
                Member since {new Date(profile.created_at).toLocaleDateString('en-US', { month: 'long', year: 'numeric' })}
              </p>
            )}
          </div>

          <div className="card p-2 space-y-1">
            {tabs.map(t => {
              const Icon = t.icon;
              return (
                <button key={t.id} onClick={() => setActiveTab(t.id)}
                  className={cn(
                    "w-full flex items-center gap-3 px-4 py-3 text-sm font-bold rounded-xl transition-all duration-200",
                    activeTab === t.id ? "bg-primary/10 text-primary" : "text-gray-500 hover:bg-gray-50 hover:text-gray-900"
                  )}>
                  <Icon size={17} className={activeTab === t.id ? "text-primary" : "text-gray-400"} />
                  {t.label}
                </button>
              );
            })}
          </div>
        </div>

        {/* Right Panel */}
        <div className="md:col-span-3">
          <AnimatePresence mode="wait">
            {/* ── PERSONAL INFO ── */}
            {activeTab === 'personal' && (
              <motion.div key="personal" initial={{ opacity: 0, x: 10 }} animate={{ opacity: 1, x: 0 }} exit={{ opacity: 0, x: -10 }}
                className="card space-y-8">
                <div>
                  <h2 className="text-xl font-bold text-gray-900">Personal Information</h2>
                  <p className="text-sm text-muted mt-1">Update your name, contact details, and farming profile.</p>
                </div>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  {/* Full Name */}
                  <div className="space-y-2">
                    <label className="text-sm font-bold text-gray-700">Full Name</label>
                    <div className="relative">
                      <User className="absolute left-3 top-3 text-gray-400" size={17} />
                      <input className="input pl-10" value={profile.full_name || ''} placeholder="Your full name"
                        onChange={e => setProfile({ ...profile, full_name: e.target.value })} />
                    </div>
                  </div>
                  {/* Username */}
                  <div className="space-y-2">
                    <label className="text-sm font-bold text-gray-700">Username</label>
                    <div className="relative">
                      <User className="absolute left-3 top-3 text-gray-400" size={17} />
                      <input className="input pl-10" value={profile.username || ''} placeholder="@username"
                        onChange={e => setProfile({ ...profile, username: e.target.value })} />
                    </div>
                  </div>
                  {/* Email */}
                  <div className="space-y-2">
                    <label className="text-sm font-bold text-gray-700">Email Address</label>
                    <div className="relative">
                      <Mail className="absolute left-3 top-3 text-gray-400" size={17} />
                      <input className="input pl-10 bg-gray-50 cursor-not-allowed" value={profile.email || ''} readOnly />
                    </div>
                  </div>
                  {/* Phone */}
                  <div className="space-y-2">
                    <label className="text-sm font-bold text-gray-700">Phone Number</label>
                    <div className="relative">
                      <Phone className="absolute left-3 top-3 text-gray-400" size={17} />
                      <input className="input pl-10" value={profile.phone_number || ''} placeholder="+91 98765 43210"
                        onChange={e => setProfile({ ...profile, phone_number: e.target.value })} />
                    </div>
                  </div>
                  {/* Farming Region – Indian States */}
                  <div className="space-y-2">
                    <label className="text-sm font-bold text-gray-700">Farming Region (State)</label>
                    <div className="relative">
                      <MapPin className="absolute left-3 top-3 text-gray-400" size={17} />
                      <select
                        className="input pl-10 appearance-none bg-white"
                        value={profile.region || ''}
                        onChange={e => setProfile({ ...profile, region: e.target.value, location: '' })}>
                        <option value="">Select State</option>
                        {STATE_LIST.map(s => <option key={s} value={s}>{s}</option>)}
                      </select>
                    </div>
                  </div>
                  {/* Location / City – based on selected state */}
                  <div className="space-y-2">
                    <label className="text-sm font-bold text-gray-700">Location / City</label>
                    <div className="relative">
                      <MapPin className="absolute left-3 top-3 text-gray-400" size={17} />
                      <select
                        className="input pl-10 appearance-none bg-white"
                        value={profile.location || ''}
                        disabled={!profile.region}
                        onChange={e => setProfile({ ...profile, location: e.target.value })}>
                        <option value="">{profile.region ? 'Select City' : 'Select state first'}</option>
                        {citiesForState.map(c => <option key={c} value={c}>{c}</option>)}
                      </select>
                    </div>
                  </div>
                  {/* Primary Crop */}
                  <div className="space-y-2 md:col-span-2">
                    <label className="text-sm font-bold text-gray-700">Primary Crop</label>
                    <div className="relative">
                      <Sprout className="absolute left-3 top-3 text-gray-400" size={17} />
                      <select className="input pl-10 appearance-none bg-white" value={profile.primary_crop || 'Apple'}
                        onChange={e => setProfile({ ...profile, primary_crop: e.target.value })}>
                        {['Apple','Blueberry','Cherry','Corn','Grape','Orange','Peach','Pepper','Potato'].map(c =>
                          <option key={c} value={c}>{c}</option>
                        )}
                      </select>
                    </div>
                  </div>
                </div>
                <div className="pt-6 border-t border-gray-50 flex justify-end">
                  <button onClick={handleSaveProfile} disabled={saving}
                    className="btn btn-primary px-10 py-3 flex items-center gap-2 disabled:opacity-60">
                    {saving ? <><Loader2 size={16} className="animate-spin" /> Saving...</> : <><Save size={16} /> Save Changes</>}
                  </button>
                </div>
              </motion.div>
            )}

            {/* ── SECURITY ── */}
            {activeTab === 'security' && (
              <motion.div key="security" initial={{ opacity: 0, x: 10 }} animate={{ opacity: 1, x: 0 }} exit={{ opacity: 0, x: -10 }}
                className="space-y-6">
                <div className="card space-y-6">
                  <div>
                    <h2 className="text-xl font-bold text-gray-900">Change Password</h2>
                    <p className="text-sm text-muted mt-1">Use a strong, unique password to protect your account.</p>
                  </div>
                  <div className="space-y-4">
                    {[
                      { label: 'Current Password', key: 'old', show: showOld, toggle: () => setShowOld(!showOld) },
                      { label: 'New Password', key: 'new', show: showNew, toggle: () => setShowNew(!showNew) },
                      { label: 'Confirm New Password', key: 'confirm', show: showNew, toggle: () => setShowNew(!showNew) },
                    ].map(f => (
                      <div key={f.key} className="space-y-2">
                        <label className="text-sm font-bold text-gray-700">{f.label}</label>
                        <div className="relative">
                          <Lock className="absolute left-3 top-3 text-gray-400" size={17} />
                          <input type={f.show ? 'text' : 'password'}
                            className="input pl-10 pr-12"
                            value={(passwords as any)[f.key]}
                            placeholder="••••••••"
                            onChange={e => setPasswords({ ...passwords, [f.key]: e.target.value })}
                          />
                          <button onClick={f.toggle} className="absolute right-3 top-3 text-gray-400 hover:text-gray-600">
                            {f.show ? <EyeOff size={17} /> : <Eye size={17} />}
                          </button>
                        </div>
                      </div>
                    ))}
                  </div>
                  <button onClick={handleChangePassword} disabled={pwdSaving || !passwords.old || !passwords.new}
                    className="btn btn-primary px-8 py-2.5 flex items-center gap-2 disabled:opacity-60">
                    {pwdSaving ? <><Loader2 size={15} className="animate-spin" /> Updating...</> : <><Shield size={15} /> Update Password</>}
                  </button>
                </div>
              </motion.div>
            )}

            {/* ── PREFERENCES ── */}
            {activeTab === 'preferences' && (
              <motion.div key="preferences" initial={{ opacity: 0, x: 10 }} animate={{ opacity: 1, x: 0 }} exit={{ opacity: 0, x: -10 }}
                className="card space-y-8">
                <div>
                  <h2 className="text-xl font-bold text-gray-900">App Preferences</h2>
                  <p className="text-sm text-muted mt-1">Choose your display theme and language settings.</p>
                </div>

                {/* Theme Selector */}
                <div className="space-y-3">
                  <label className="text-sm font-extrabold text-gray-700 uppercase tracking-wider">Interface Theme</label>
                  <div className="grid grid-cols-2 gap-4">
                    {[
                      { val: 'light', label: 'Light Mode', icon: Sun, desc: 'Clean white interface, best for daytime.' },
                      { val: 'dark', label: 'Dark Mode', icon: Moon, desc: 'Dark green palette, easier on the eyes at night.' },
                    ].map(t => {
                      const Icon = t.icon;
                      return (
                        <button key={t.val} onClick={() => setProfile({ ...profile, theme: t.val })}
                          className={cn("p-5 rounded-2xl border-2 text-left transition-all space-y-2",
                            profile.theme === t.val ? "border-primary bg-primary/5" : "border-gray-100 hover:border-gray-200")}>
                          <div className={cn("w-10 h-10 rounded-xl flex items-center justify-center",
                            profile.theme === t.val ? "bg-primary text-white" : "bg-gray-100 text-gray-500")}>
                            <Icon size={20} />
                          </div>
                          <p className="font-bold text-sm text-gray-900">{t.label}</p>
                          <p className="text-xs text-muted">{t.desc}</p>
                        </button>
                      );
                    })}
                  </div>
                </div>

                {/* Language Selector */}
                <div className="space-y-3">
                  <label className="text-sm font-extrabold text-gray-700 uppercase tracking-wider">Language</label>
                  <div className="relative">
                    <Languages className="absolute left-3 top-3 text-gray-400" size={17} />
                    <select className="input pl-10 appearance-none bg-white" value={profile.language}
                      onChange={e => setProfile({ ...profile, language: e.target.value })}>
                      <option value="en">English (Default)</option>
                      <option value="te">తెలుగు (Telugu)</option>
                      <option value="hi">हिन्दी (Hindi)</option>
                    </select>
                  </div>
                </div>

                <div className="pt-6 border-t border-gray-50 flex justify-end">
                  <button onClick={handleSaveProfile} disabled={saving}
                    className="btn btn-primary px-10 py-3 flex items-center gap-2 disabled:opacity-60">
                    {saving ? <><Loader2 size={16} className="animate-spin" /> Saving...</> : <><Save size={16} /> Save Preferences</>}
                  </button>
                </div>
              </motion.div>
            )}
          </AnimatePresence>
        </div>
      </div>
    </div>
  );
}
