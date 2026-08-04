'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { 
  LayoutDashboard, 
  Scan, 
  History, 
  Library, 
  Lightbulb, 
  User, 
  LogOut,
  Leaf,
  Lock,
  Bell,
  X,
  CheckCircle,
  Clock
} from 'lucide-react';
import { cn } from '@/app/utils';
import { motion, AnimatePresence } from 'framer-motion';
import type { Notification } from './LayoutWrapper';

interface SidebarProps {
  notifications: Notification[];
  unreadCount: number;
  showNotifDrawer: boolean;
  setShowNotifDrawer: (open: boolean) => void;
  markAsRead: (id: number) => void;
  isAdmin?: boolean | null;
}

export function Sidebar({ notifications, unreadCount, showNotifDrawer, setShowNotifDrawer, markAsRead, isAdmin }: SidebarProps) {
  const pathname = usePathname();

  const handleLogout = () => {
    localStorage.removeItem('token');
    window.location.href = '/login';
  };

  const baseNavItems = [
    { name: 'Dashboard', href: '/', icon: LayoutDashboard },
    { name: 'Scan Plant', href: '/scan', icon: Scan },
    { name: 'History', href: '/history', icon: History },
    { name: 'Disease Library', href: '/library', icon: Library },
    { name: 'Quick Tips', href: '/tips', icon: Lightbulb },
    { name: 'Profile', href: '/profile', icon: User },
  ];

  const adminNavItems = [
    { name: 'Admin Portal', href: '/admin', icon: Lock },
    { name: 'Scan Plant', href: '/scan', icon: Scan },
    { name: 'Profile', href: '/profile', icon: User },
  ];

  const navItems = isAdmin ? adminNavItems : baseNavItems;

  return (
    <>
      <aside className="fixed left-0 top-0 h-screen w-64 bg-white border-r border-gray-100 flex flex-col z-40">
        <div className="p-6 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 bg-primary rounded-lg flex items-center justify-center text-white shadow-lg shadow-primary/20">
              <Leaf size={24} />
            </div>
            <h1 className="text-xl font-black text-gray-800 tracking-tight">AgroSentry</h1>
          </div>
          
          {/* Real-time Notification Bell */}
          <button 
            onClick={() => setShowNotifDrawer(true)}
            className="relative p-2 text-gray-400 hover:text-primary hover:bg-gray-50 rounded-xl transition-all"
          >
            <Bell size={20} />
            {unreadCount > 0 && (
              <span className="absolute top-1 right-1 w-5 h-5 bg-red-500 text-white text-[10px] font-black rounded-full flex items-center justify-center animate-pulse border-2 border-white">
                {unreadCount}
              </span>
            )}
          </button>
        </div>

        <nav className="flex-1 px-4 mt-4 space-y-1">
          {navItems.map((item) => {
            const isActive = pathname === item.href;
            const Icon = item.icon;
            return (
              <Link
                key={item.href}
                href={item.href}
                className={cn(
                  "flex items-center gap-3 px-4 py-3 rounded-xl text-sm font-bold transition-all duration-200",
                  isActive 
                    ? "bg-primary/10 text-primary shadow-sm" 
                    : "text-gray-500 hover:bg-gray-50 hover:text-gray-900"
                )}
              >
                <Icon size={18} className={isActive ? "text-primary" : "text-gray-400"} />
                {item.name}
              </Link>
            );
          })}
        </nav>

        <div className="p-4 mt-auto border-t border-gray-50">
          <button
            onClick={handleLogout}
            className="flex items-center gap-3 w-full px-4 py-3 text-sm font-bold text-gray-500 hover:bg-red-50 hover:text-red-600 rounded-xl transition-all duration-200"
          >
            <LogOut size={18} />
            Logout
          </button>
        </div>
      </aside>

      {/* Slide-out Broadcast Notifications Drawer */}
      <AnimatePresence>
        {showNotifDrawer && (
          <motion.div 
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 bg-black/40 backdrop-blur-sm z-50 flex justify-end"
          >
            {/* Backdrop click to close */}
            <div className="absolute inset-0 cursor-pointer" onClick={() => setShowNotifDrawer(false)} />
            
            <motion.div 
              initial={{ x: '100%' }}
              animate={{ x: 0 }}
              exit={{ x: '100%' }}
              transition={{ type: 'spring', damping: 25, stiffness: 200 }}
              className="relative w-full max-w-md bg-white h-screen shadow-2xl flex flex-col z-10"
            >
              <div className="p-6 border-b border-gray-100 flex items-center justify-between bg-gray-50">
                <div className="flex items-center gap-2">
                  <Bell className="text-primary" size={22} />
                  <h3 className="font-black text-gray-900 text-lg">Broadcast Feed</h3>
                </div>
                <button 
                  onClick={() => setShowNotifDrawer(false)}
                  className="w-8 h-8 bg-white rounded-xl shadow border border-gray-100 flex items-center justify-center text-gray-500 hover:text-danger transition-colors"
                >
                  <X size={16} />
                </button>
              </div>

              <div className="flex-1 overflow-y-auto p-6 space-y-4">
                {notifications.length === 0 ? (
                  <div className="text-center py-12 space-y-2 text-muted">
                    <Clock size={40} className="mx-auto text-gray-200" />
                    <p className="font-bold text-gray-900">No announcements yet</p>
                    <p className="text-xs">Broadcasts from agronomists will appear here in real-time.</p>
                  </div>
                ) : (
                  notifications.map((n) => (
                    <div 
                      key={n.id} 
                      className={cn(
                        "p-4 rounded-2xl border transition-all duration-300 relative overflow-hidden flex flex-col justify-between min-h-[120px]",
                        n.is_read 
                          ? "bg-white border-gray-100" 
                          : "bg-primary/5 border-primary/10 shadow-sm"
                      )}
                    >
                      {!n.is_read && (
                        <div className="absolute top-0 right-0 w-2.5 h-2.5 bg-red-500 rounded-bl-xl" />
                      )}
                      
                      <div className="space-y-1">
                        <h4 className="font-extrabold text-gray-900 text-sm">{n.title}</h4>
                        <p className="text-xs text-gray-600 leading-relaxed font-medium">{n.message}</p>
                      </div>

                      <div className="pt-4 mt-2 border-t border-gray-50/50 flex justify-between items-center text-[10px] text-muted font-bold">
                        <span>{n.created_at}</span>
                        {!n.is_read && (
                          <button 
                            onClick={() => markAsRead(n.id)}
                            className="flex items-center gap-1 text-primary hover:underline"
                          >
                            <CheckCircle size={12} />
                            Mark as read
                          </button>
                        )}
                      </div>
                    </div>
                  ))
                )}
              </div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </>
  );
}
