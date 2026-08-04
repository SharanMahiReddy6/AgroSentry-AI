'use client';

import { useState, useEffect, useRef } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { Leaf, Mail, Lock, ArrowRight, ArrowLeft, ShieldCheck, RotateCcw, CheckCircle } from 'lucide-react';

type Step = 'email' | 'code' | 'password' | 'success';

export default function ForgotPasswordPage() {
  const router = useRouter();
  const [step, setStep] = useState<Step>('email');
  const [email, setEmail] = useState('');
  const [code, setCode] = useState(['', '', '', '', '', '']);
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [countdown, setCountdown] = useState(600); // 10 min in seconds
  const [canResend, setCanResend] = useState(false);
  const codeRefs = useRef<(HTMLInputElement | null)[]>([]);

  // Countdown timer for OTP expiry
  useEffect(() => {
    if (step !== 'code') return;
    setCountdown(600);
    setCanResend(false);
    const timer = setInterval(() => {
      setCountdown(prev => {
        if (prev <= 1) {
          clearInterval(timer);
          setCanResend(true);
          return 0;
        }
        return prev - 1;
      });
    }, 1000);
    return () => clearInterval(timer);
  }, [step]);

  const formatTime = (s: number) => `${Math.floor(s / 60).toString().padStart(2, '0')}:${(s % 60).toString().padStart(2, '0')}`;

  // Step 1: Send OTP
  const handleSendCode = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
      const res = await fetch('http://localhost:8000/api/auth/forgot-password', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email }),
      });
      const data = await res.json();
      if (res.ok) {
        setStep('code');
      } else {
        setError(data.detail || 'Failed to send code.');
      }
    } catch {
      setError('Cannot connect to server. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  // Step 2: Verify OTP
  const handleVerifyCode = async (e: React.FormEvent) => {
    e.preventDefault();
    const fullCode = code.join('');
    if (fullCode.length !== 6) { setError('Please enter the full 6-digit code.'); return; }
    setError('');
    setLoading(true);
    try {
      const res = await fetch('http://localhost:8000/api/auth/verify-reset-code', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, code: fullCode }),
      });
      const data = await res.json();
      if (res.ok) {
        setStep('password');
      } else {
        setError(data.detail || 'Invalid or expired code.');
      }
    } catch {
      setError('Cannot connect to server. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  // Step 3: Reset Password
  const handleResetPassword = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    if (newPassword.length < 8) { setError('Password must be at least 8 characters.'); return; }
    if (!/[A-Z]/.test(newPassword)) { setError('Password must contain at least one uppercase letter.'); return; }
    if (!/[0-9]/.test(newPassword)) { setError('Password must contain at least one number.'); return; }
    if (newPassword !== confirmPassword) { setError('Passwords do not match.'); return; }

    setLoading(true);
    try {
      const res = await fetch('http://localhost:8000/api/auth/reset-password', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, code: code.join(''), new_password: newPassword }),
      });
      const data = await res.json();
      if (res.ok) {
        setStep('success');
      } else {
        setError(data.detail || 'Failed to reset password.');
      }
    } catch {
      setError('Cannot connect to server. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  // OTP input handling
  const handleCodeInput = (i: number, val: string) => {
    if (!/^\d*$/.test(val)) return;
    const newCode = [...code];
    newCode[i] = val.slice(-1);
    setCode(newCode);
    if (val && i < 5) codeRefs.current[i + 1]?.focus();
  };

  const handleCodeKeyDown = (i: number, e: React.KeyboardEvent) => {
    if (e.key === 'Backspace' && !code[i] && i > 0) {
      codeRefs.current[i - 1]?.focus();
    }
  };

  const handleResend = async () => {
    setCode(['', '', '', '', '', '']);
    setError('');
    setLoading(true);
    try {
      await fetch('http://localhost:8000/api/auth/forgot-password', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email }),
      });
      setStep('code'); // Trigger useEffect to restart countdown
    } finally {
      setLoading(false);
    }
  };

  const stepLabel = { email: 1, code: 2, password: 3, success: 4 };

  return (
    <div className="min-h-screen flex items-center justify-center p-4">
      <div className="w-full max-w-md animate-in">
        {/* Header */}
        <div className="text-center mb-8">
          <div className="inline-flex items-center justify-center w-16 h-16 bg-primary rounded-2xl text-white shadow-xl shadow-primary/20 mb-4">
            <Leaf size={32} />
          </div>
          <h1 className="text-3xl font-bold text-gray-900">Reset Password</h1>
          <p className="text-gray-500 mt-2">Follow the steps to regain access</p>
        </div>

        {/* Progress Steps */}
        {step !== 'success' && (
          <div className="flex items-center justify-center mb-8 gap-2">
            {(['email', 'code', 'password'] as const).map((s, idx) => (
              <div key={s} className="flex items-center">
                <div className={`w-8 h-8 rounded-full flex items-center justify-center text-sm font-bold transition-all ${
                  stepLabel[step] > idx + 1 ? 'bg-primary text-white' :
                  stepLabel[step] === idx + 1 ? 'bg-primary text-white ring-4 ring-primary/20' :
                  'bg-gray-100 text-gray-400'
                }`}>
                  {stepLabel[step] > idx + 1 ? '✓' : idx + 1}
                </div>
                {idx < 2 && <div className={`w-12 h-0.5 mx-1 transition-all ${stepLabel[step] > idx + 1 ? 'bg-primary' : 'bg-gray-100'}`} />}
              </div>
            ))}
          </div>
        )}

        <div className="card shadow-xl border-none">
          {/* Step 1: Email */}
          {step === 'email' && (
            <form onSubmit={handleSendCode} className="space-y-5" autoComplete="off">
              <div>
                <h2 className="text-lg font-bold text-gray-900 mb-1">Enter your email</h2>
                <p className="text-sm text-gray-500">We'll send a 6-digit code to your registered email address.</p>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1.5">Email Address</label>
                <div className="relative">
                  <Mail className="absolute left-3 top-3.5 text-gray-400" size={18} />
                  <input
                    type="email"
                    autoComplete="off"
                    className="input pl-10"
                    placeholder="name@gmail.com"
                    value={email}
                    onChange={e => setEmail(e.target.value)}
                    required
                  />
                </div>
              </div>
              {error && <p className="text-sm text-red-600 bg-red-50 p-3 rounded-lg">{error}</p>}
              <button type="submit" disabled={loading} className="btn btn-primary w-full py-4 text-lg group">
                {loading ? 'Sending...' : 'Send Reset Code'}
                {!loading && <ArrowRight className="ml-2 group-hover:translate-x-1 transition-transform" size={20} />}
              </button>
              <div className="text-center pt-2">
                <Link href="/login" className="text-sm text-gray-500 hover:text-primary flex items-center justify-center gap-1">
                  <ArrowLeft size={14} /> Back to Sign In
                </Link>
              </div>
            </form>
          )}

          {/* Step 2: OTP Code */}
          {step === 'code' && (
            <form onSubmit={handleVerifyCode} className="space-y-5">
              <div>
                <h2 className="text-lg font-bold text-gray-900 mb-1">Enter the 6-digit code</h2>
                <p className="text-sm text-gray-500">We sent it to <span className="font-semibold text-gray-700">{email}</span></p>
              </div>
              <div className="flex gap-2 justify-center">
                {code.map((digit, i) => (
                  <input
                    key={i}
                    ref={el => { codeRefs.current[i] = el; }}
                    type="text"
                    inputMode="numeric"
                    maxLength={1}
                    value={digit}
                    onChange={e => handleCodeInput(i, e.target.value)}
                    onKeyDown={e => handleCodeKeyDown(i, e)}
                    className="w-12 h-14 text-center text-2xl font-bold border-2 border-gray-200 rounded-xl focus:border-primary focus:ring-2 focus:ring-primary/20 outline-none transition-all"
                  />
                ))}
              </div>
              <div className="text-center">
                {countdown > 0 ? (
                  <p className="text-sm text-gray-500">
                    Code expires in <span className="font-bold text-primary tabular-nums">{formatTime(countdown)}</span>
                  </p>
                ) : (
                  <p className="text-sm text-red-500 font-semibold">Code expired.</p>
                )}
              </div>
              {error && <p className="text-sm text-red-600 bg-red-50 p-3 rounded-lg">{error}</p>}
              <button type="submit" disabled={loading} className="btn btn-primary w-full py-4 text-lg group">
                {loading ? 'Verifying...' : 'Verify Code'}
                {!loading && <ShieldCheck className="ml-2" size={20} />}
              </button>
              {canResend && (
                <button type="button" onClick={handleResend} className="w-full flex items-center justify-center gap-2 text-sm text-primary font-semibold hover:underline">
                  <RotateCcw size={14} /> Resend Code
                </button>
              )}
              <div className="text-center pt-2">
                <button type="button" onClick={() => setStep('email')} className="text-sm text-gray-500 hover:text-primary flex items-center justify-center gap-1 mx-auto">
                  <ArrowLeft size={14} /> Change email
                </button>
              </div>
            </form>
          )}

          {/* Step 3: New Password */}
          {step === 'password' && (
            <form onSubmit={handleResetPassword} className="space-y-5" autoComplete="off">
              <div>
                <h2 className="text-lg font-bold text-gray-900 mb-1">Set new password</h2>
                <p className="text-sm text-gray-500">Must be 8+ chars, include an uppercase letter and a number.</p>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1.5">New Password</label>
                <div className="relative">
                  <Lock className="absolute left-3 top-3.5 text-gray-400" size={18} />
                  <input
                    type="password"
                    autoComplete="new-password"
                    className="input pl-10"
                    placeholder="••••••••"
                    value={newPassword}
                    onChange={e => setNewPassword(e.target.value)}
                    required
                  />
                </div>
                {/* Live strength indicators */}
                <div className="mt-2 flex gap-2 text-xs">
                  <span className={`px-2 py-0.5 rounded-full font-semibold ${newPassword.length >= 8 ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-400'}`}>8+ chars</span>
                  <span className={`px-2 py-0.5 rounded-full font-semibold ${/[A-Z]/.test(newPassword) ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-400'}`}>Uppercase</span>
                  <span className={`px-2 py-0.5 rounded-full font-semibold ${/[0-9]/.test(newPassword) ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-400'}`}>Number</span>
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1.5">Confirm Password</label>
                <div className="relative">
                  <Lock className="absolute left-3 top-3.5 text-gray-400" size={18} />
                  <input
                    type="password"
                    autoComplete="new-password"
                    className="input pl-10"
                    placeholder="••••••••"
                    value={confirmPassword}
                    onChange={e => setConfirmPassword(e.target.value)}
                    required
                  />
                </div>
                {confirmPassword && (
                  <p className={`text-xs mt-1.5 font-semibold ${newPassword === confirmPassword ? 'text-green-600' : 'text-red-500'}`}>
                    {newPassword === confirmPassword ? '✓ Passwords match' : '✗ Passwords do not match'}
                  </p>
                )}
              </div>
              {error && <p className="text-sm text-red-600 bg-red-50 p-3 rounded-lg">{error}</p>}
              <button type="submit" disabled={loading} className="btn btn-primary w-full py-4 text-lg group">
                {loading ? 'Resetting...' : 'Reset Password'}
                {!loading && <ArrowRight className="ml-2 group-hover:translate-x-1 transition-transform" size={20} />}
              </button>
            </form>
          )}

          {/* Step 4: Success */}
          {step === 'success' && (
            <div className="text-center space-y-5 py-4">
              <div className="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto">
                <CheckCircle size={36} className="text-green-600" />
              </div>
              <div>
                <h2 className="text-xl font-bold text-gray-900">Password Reset!</h2>
                <p className="text-sm text-gray-500 mt-2">Your password has been updated successfully. You can now sign in with your new password.</p>
              </div>
              <button onClick={() => router.push('/login')} className="btn btn-primary w-full py-4 text-lg group">
                Go to Sign In
                <ArrowRight className="ml-2 group-hover:translate-x-1 transition-transform" size={20} />
              </button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
