'use client';

import { useState, useRef, useEffect } from 'react';
import { Bell, Search, User, LogOut, ChevronDown } from 'lucide-react';
import { cn } from '@/app/utils';
import { useRouter } from 'next/navigation';

interface HeaderProps {
  unreadCount: number;
  onBellClick: () => void;
  profilePhoto?: string | null;
  isAdmin?: boolean | null;
}

export function Header({ unreadCount, onBellClick, profilePhoto, isAdmin }: HeaderProps) {
  const router = useRouter();
  const [menuOpen, setMenuOpen] = useState(false);
  const menuRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (menuRef.current && !menuRef.current.contains(event.target as Node)) {
        setMenuOpen(false);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const handleLogout = () => {
    localStorage.removeItem('token');
    window.location.href = '/login';
  };

  return (
    <header className="h-20 flex items-center justify-between px-8 bg-white/80 backdrop-blur-md border-b border-gray-100 sticky top-0 z-40">
      <div className="relative w-96 hidden md:block">
        <Search className="absolute left-3 top-3 text-gray-400" size={18} />
        <input
          type="text"
          placeholder="Search for diseases, crops or tips..."
          className="w-full bg-gray-50 border-none rounded-xl px-10 py-2.5 text-sm focus:ring-2 focus:ring-primary/10 transition-all"
        />
      </div>

      <div className="flex items-center gap-4">
        {/* Unified Bell — triggers the shared Sidebar drawer */}
        <button
          id="header-bell-btn"
          onClick={onBellClick}
          className="p-2.5 rounded-xl hover:bg-gray-100 text-gray-500 relative transition-colors"
          aria-label="Open notifications"
        >
          <Bell size={20} />
          {unreadCount > 0 && (
            <span className="absolute top-1.5 right-1.5 w-5 h-5 bg-red-500 text-white text-[10px] font-black rounded-full flex items-center justify-center animate-pulse border-2 border-white">
              {unreadCount > 9 ? '9+' : unreadCount}
            </span>
          )}
        </button>

        <div className="h-8 w-[1px] bg-gray-100 mx-2" />

        {/* Avatar Dropdown */}
        <div className="relative" ref={menuRef}>
          <button
            onClick={() => setMenuOpen(!menuOpen)}
            className="flex items-center gap-3 pl-2 group cursor-pointer"
          >
            <div className="text-right hidden sm:block">
              <p className="text-sm font-bold text-gray-900 leading-tight">My Profile</p>
              <p className="text-[10px] font-bold text-primary uppercase tracking-wider">
                {isAdmin ? 'Admin' : 'Premium Plan'}
              </p>
            </div>
            <div className="w-10 h-10 rounded-xl bg-primary/10 flex items-center justify-center text-primary font-bold shadow-inner group-hover:ring-2 group-hover:ring-primary/20 overflow-hidden transition-all">
              {profilePhoto ? (
                <img src={`http://localhost:8000${profilePhoto}`} alt="Profile" className="w-full h-full object-cover" />
              ) : (
                <span className="text-sm">👤</span>
              )}
            </div>
            <ChevronDown size={14} className={`text-gray-400 transition-transform ${menuOpen ? 'rotate-180' : ''}`} />
          </button>

          {/* Dropdown Menu */}
          {menuOpen && (
            <div className="absolute right-0 mt-3 w-48 bg-white border border-gray-100 rounded-xl shadow-lg py-2 z-50 animate-in slide-in-from-top-2">
              <button
                onClick={() => {
                  setMenuOpen(false);
                  router.push('/profile');
                }}
                className="w-full text-left px-4 py-2 text-sm font-bold text-gray-700 hover:bg-gray-50 hover:text-primary flex items-center gap-2 transition-colors"
              >
                <User size={16} />
                My Profile
              </button>
              <button
                onClick={handleLogout}
                className="w-full text-left px-4 py-2 text-sm font-bold text-gray-700 hover:bg-red-50 hover:text-red-600 flex items-center gap-2 transition-colors mt-1"
              >
                <LogOut size={16} />
                Logout
              </button>
            </div>
          )}
        </div>
      </div>
    </header>
  );
}
