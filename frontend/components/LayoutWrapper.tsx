'use client';

import { usePathname, useRouter } from 'next/navigation';
import { useState, useEffect, useCallback } from 'react';
import { Sidebar } from '@/components/Sidebar';
import { Header } from '@/components/Header';
import { Loader2 } from 'lucide-react';

export type Notification = {
  id: number;
  title: string;
  message: string;
  is_read: boolean;
  created_at: string;
};

export default function LayoutWrapper({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const router = useRouter();
  const isAuthPage = pathname === '/login' || pathname === '/register' || pathname === '/forgot-password';
  const [isAuthenticated, setIsAuthenticated] = useState<boolean | null>(null);

  // Shared notification state lifted here so Header + Sidebar share it
  const [notifications, setNotifications] = useState<Notification[]>([]);
  const [showNotifDrawer, setShowNotifDrawer] = useState(false);
  const [theme, setTheme] = useState('light');
  const [language, setLanguage] = useState('en');
  const [profilePhoto, setProfilePhoto] = useState<string | null>(null);
  const [isAdmin, setIsAdmin] = useState<boolean | null>(null);

  const fetchNotificationsAndProfile = useCallback(async () => {
    const token = localStorage.getItem('token');
    if (!token || isAuthPage) return;
    try {
      const res = await fetch('http://localhost:8000/api/notifications', {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      if (res.ok) setNotifications(await res.json());

      const profRes = await fetch('http://localhost:8000/api/auth/me', {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      if (profRes.ok) {
        const prof = await profRes.json();
        setTheme(prof.theme || 'light');
        setLanguage(prof.language || 'en');
        setProfilePhoto(prof.profile_photo || null);
        setIsAdmin(prof.is_admin);
      } else {
        if (profRes.status === 401 || profRes.status === 403) {
          localStorage.removeItem('token');
          window.location.href = '/login';
        } else {
          // If some other error, fallback to unauthenticated state or error
          setIsAdmin(false);
        }
      }
    } catch { 
      // If network fails, at least don't spin forever if we can avoid it. But let's leave it spinning if backend is just offline.
    }
  }, [isAuthPage]);

  useEffect(() => {
    const token = localStorage.getItem('token');
    if (!token && !isAuthPage) {
      router.replace('/login');
    } else if (token && isAuthPage) {
      router.replace('/');
    } else {
      setIsAuthenticated(true);
    }
  }, [pathname, isAuthPage, router]);

  useEffect(() => {
    if (isAuthenticated && !isAuthPage) {
      fetchNotificationsAndProfile();
      const interval = setInterval(fetchNotificationsAndProfile, 10000);
      return () => clearInterval(interval);
    }
  }, [isAuthenticated, isAuthPage, fetchNotificationsAndProfile]);

  useEffect(() => {
    if (isAdmin !== null && !isAuthPage) {
      if (isAdmin) {
        // Allow dynamic routes like /scan/123 by checking startswith or split
        const pathBase = '/' + pathname.split('/')[1]; 
        const adminAllowedPaths = ['/admin', '/scan', '/profile'];
        if (!adminAllowedPaths.includes(pathBase)) {
          router.replace('/admin');
        }
      } else {
        if (pathname === '/admin') {
          router.replace('/');
        }
      }
    }
  }, [isAdmin, pathname, isAuthPage, router]);

  // Apply theme to document
  useEffect(() => {
    if (theme === 'dark') {
      document.documentElement.classList.add('dark');
    } else {
      document.documentElement.classList.remove('dark');
    }
  }, [theme]);

  // Handle translation
  useEffect(() => {
    if (language) {
      document.cookie = `googtrans=/en/${language}; path=/;`;
      
      if (language !== 'en' && !document.getElementById('google-translate-script')) {
        // Define the callback before injecting the script
        (window as any).googleTranslateElementInit = () => {
          new (window as any).google.translate.TranslateElement({pageLanguage: 'en', autoDisplay: false}, 'google_translate_element');
        };
        
        // Add the script
        const script = document.createElement('script');
        script.id = 'google-translate-script';
        script.src = '//translate.google.com/translate_a/element.js?cb=googleTranslateElementInit';
        document.body.appendChild(script);
      } else if (language === 'en') {
        // Clear cookie for English
        document.cookie = `googtrans=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;`;
      }
    }
  }, [language]);

  const markAsRead = async (notifId: number) => {
    try {
      const res = await fetch(`http://localhost:8000/api/notifications/${notifId}/read`, {
        method: 'PUT',
        headers: { 'Authorization': `Bearer ${localStorage.getItem('token')}` }
      });
      if (res.ok) setNotifications(prev => prev.map(n => n.id === notifId ? { ...n, is_read: true } : n));
    } catch { /* silent */ }
  };

  const unreadCount = notifications.filter(n => !n.is_read).length;

  if (isAuthenticated === null || (!isAuthPage && isAdmin === null)) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-background">
        <Loader2 className="w-10 h-10 text-primary animate-spin" />
      </div>
    );
  }

  if (isAuthPage) {
    return <main className="w-full min-h-screen bg-background">{children}</main>;
  }

  return (
    <>
      <Sidebar
        notifications={notifications}
        unreadCount={unreadCount}
        showNotifDrawer={showNotifDrawer}
        setShowNotifDrawer={setShowNotifDrawer}
        markAsRead={markAsRead}
        isAdmin={isAdmin}
      />
      <div className="flex-1 ml-64 flex flex-col min-h-screen bg-background">
        <Header
          unreadCount={unreadCount}
          onBellClick={() => setShowNotifDrawer(true)}
          profilePhoto={profilePhoto}
          isAdmin={isAdmin}
        />
        <main className="p-8">
          <div className="max-w-7xl mx-auto">
            <div id="google_translate_element" style={{ position: 'absolute', opacity: 0, zIndex: -1, pointerEvents: 'none' }}></div>
            {children}
          </div>
        </main>
      </div>
    </>
  );
}
