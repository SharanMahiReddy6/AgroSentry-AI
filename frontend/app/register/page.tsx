'use client';

import { useState } from 'react';
import Link from 'next/link';
import { Leaf, User, Mail, Lock, MapPin, Sprout, ArrowRight, CheckCircle, XCircle } from 'lucide-react';

// Allowed email domains — common trusted providers
const ALLOWED_DOMAINS = [
  'gmail.com', 'yahoo.com', 'outlook.com', 'hotmail.com', 'icloud.com',
  'live.com', 'protonmail.com', 'aol.com', 'agrosentry.com', 'me.com',
  'mac.com', 'ymail.com', 'googlemail.com', 'msn.com', 'proton.me',
];

function getEmailDomain(email: string) {
  return email.split('@')[1]?.toLowerCase() || '';
}

function validateEmail(email: string): string {
  if (!email) return '';
  const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
  if (!emailRegex.test(email)) {
    return `Please enter a valid email address.`;
  }
  const domain = getEmailDomain(email);
  if (!ALLOWED_DOMAINS.includes(domain)) {
    return `Only common email providers are accepted (e.g. @gmail.com, @outlook.com, @yahoo.com)`;
  }
  return '';
}

function validatePassword(password: string): { ok: boolean; checks: { label: string; pass: boolean }[] } {
  const checks = [
    { label: '8+ characters', pass: password.length >= 8 },
    { label: 'Uppercase letter', pass: /[A-Z]/.test(password) },
    { label: 'Number (0-9)', pass: /[0-9]/.test(password) },
  ];
  return { ok: checks.every(c => c.pass), checks };
}

export default function RegisterPage() {
  const [formData, setFormData] = useState({
    full_name: '',
    email: '',
    password: '',
    region: '',
    primary_crop: 'tomato',
  });
  const [loading, setLoading] = useState(false);
  const [emailError, setEmailError] = useState('');
  const [formError, setFormError] = useState('');

  const passwordValidation = validatePassword(formData.password);

  const handleChange = (field: string, value: string) => {
    setFormData(prev => ({ ...prev, [field]: value }));
    if (field === 'email') {
      setEmailError(validateEmail(value));
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setFormError('');

    // Re-validate before submit
    const emailErr = validateEmail(formData.email);
    if (emailErr) { setEmailError(emailErr); return; }
    if (!passwordValidation.ok) { setFormError('Please meet all password requirements.'); return; }
    if (formData.full_name.trim().length < 2) { setFormError('Please enter your full name.'); return; }
    if (formData.region.trim().length < 2) { setFormError('Please enter your region.'); return; }

    setLoading(true);
    try {
      const response = await fetch('http://localhost:8000/api/auth/register', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          full_name: formData.full_name,
          email: formData.email,
          password: formData.password,
          region: formData.region,
          primary_crop: formData.primary_crop,
        }),
      });

      if (response.ok) {
        alert('Account created successfully! Please sign in.');
        window.location.href = '/login';
      } else {
        const error = await response.json();
        setFormError(error.detail || 'Registration failed. Please try again.');
        setLoading(false);
      }
    } catch {
      setFormError('Cannot connect to server. Make sure the backend is running.');
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center p-4">
      <div className="w-full max-w-lg animate-in">
        <div className="text-center mb-8">
          <div className="inline-flex items-center justify-center w-16 h-16 bg-primary rounded-2xl text-white shadow-xl shadow-primary/20 mb-4">
            <Leaf size={32} />
          </div>
          <h1 className="text-3xl font-bold text-gray-900">Join AgroSentry</h1>
          <p className="text-gray-500 mt-2">Start monitoring your crop health with AI</p>
        </div>

        <div className="card shadow-xl border-none">
          {/* autoComplete="off" prevents browser from pre-filling saved data */}
          <form onSubmit={handleSubmit} autoComplete="off" className="grid grid-cols-1 md:grid-cols-2 gap-5">
            {/* Full Name */}
            <div className="md:col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-1.5">Full Name</label>
              <div className="relative">
                <User className="absolute left-3 top-3.5 text-gray-400" size={18} />
                <input
                  autoComplete="new-password"
                  className="input pl-10"
                  placeholder="John Doe"
                  value={formData.full_name}
                  onChange={e => handleChange('full_name', e.target.value)}
                  required
                />
              </div>
            </div>

            {/* Email */}
            <div className="md:col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-1.5">Email Address</label>
              <div className="relative">
                <Mail className="absolute left-3 top-3.5 text-gray-400" size={18} />
                <input
                  type="email"
                  autoComplete="new-password"
                  className={`input pl-10 ${emailError ? 'border-red-400 focus:ring-red-200' : ''}`}
                  placeholder="name@gmail.com"
                  value={formData.email}
                  onChange={e => handleChange('email', e.target.value)}
                  required
                />
              </div>
              {emailError && (
                <p className="text-xs text-red-600 mt-1.5 flex items-center gap-1">
                  <XCircle size={12} /> {emailError}
                </p>
              )}
              {!emailError && formData.email && formData.email.includes('@') && (
                <p className="text-xs text-green-600 mt-1.5 flex items-center gap-1">
                  <CheckCircle size={12} /> Valid email domain accepted
                </p>
              )}
            </div>

            {/* Region */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1.5">Region</label>
              <div className="relative">
                <MapPin className="absolute left-3 top-3.5 text-gray-400" size={18} />
                <input
                  autoComplete="new-password"
                  className="input pl-10"
                  placeholder="e.g. California"
                  value={formData.region}
                  onChange={e => handleChange('region', e.target.value)}
                  required
                />
              </div>
            </div>

            {/* Primary Crop */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1.5">Primary Crop</label>
              <div className="relative">
                <Sprout className="absolute left-3 top-3.5 text-gray-400" size={18} />
                <select
                  className="input pl-10 appearance-none bg-white"
                  value={formData.primary_crop}
                  onChange={e => handleChange('primary_crop', e.target.value)}
                >
                  <option value="tomato">Tomato</option>
                  <option value="potato">Potato</option>
                  <option value="corn">Corn</option>
                  <option value="grape">Grape</option>
                  <option value="apple">Apple</option>
                  <option value="orange">Orange</option>
                  <option value="peach">Peach</option>
                  <option value="pepper">Pepper</option>
                </select>
              </div>
            </div>

            {/* Password */}
            <div className="md:col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-1.5">Password</label>
              <div className="relative">
                <Lock className="absolute left-3 top-3.5 text-gray-400" size={18} />
                <input
                  type="password"
                  autoComplete="new-password"
                  className="input pl-10"
                  placeholder="••••••••"
                  value={formData.password}
                  onChange={e => handleChange('password', e.target.value)}
                  required
                />
              </div>
              {/* Live password strength indicators */}
              {formData.password.length > 0 && (
                <div className="mt-2 flex gap-2 flex-wrap">
                  {passwordValidation.checks.map(check => (
                    <span
                      key={check.label}
                      className={`flex items-center gap-1 text-xs px-2 py-0.5 rounded-full font-semibold transition-all ${
                        check.pass ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-400'
                      }`}
                    >
                      {check.pass ? <CheckCircle size={10} /> : <XCircle size={10} />}
                      {check.label}
                    </span>
                  ))}
                </div>
              )}
            </div>

            {/* Form Error */}
            {formError && (
              <div className="md:col-span-2 text-sm text-red-600 bg-red-50 p-3 rounded-lg flex items-center gap-2">
                <XCircle size={16} /> {formError}
              </div>
            )}

            <button
              type="submit"
              className="md:col-span-2 btn btn-primary py-4 text-lg mt-2 group"
              disabled={loading || !!emailError || !passwordValidation.ok}
            >
              {loading ? 'Creating Account...' : 'Get Started'}
              {!loading && <ArrowRight className="ml-2 group-hover:translate-x-1 transition-transform" size={20} />}
            </button>
          </form>

          <div className="mt-8 text-center border-t border-gray-50 pt-6">
            <p className="text-sm text-gray-600">
              Already have an account?{' '}
              <Link href="/login" className="text-primary font-bold hover:underline">
                Sign in instead
              </Link>
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
