'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import { 
  Sprout, 
  ArrowRight, 
  Clock, 
  AlertCircle, 
  CheckCircle2,
  BookOpen,
  ChevronRight
} from 'lucide-react';
import { cn } from '@/app/utils';

export default function Dashboard() {
  const [stats, setStats] = useState({ total: 0, healthy: 0, issues: 0 });
  const [recentScans, setRecentScans] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const response = await fetch('http://localhost:8000/api/scans/history', {
          headers: {
            'Authorization': `Bearer ${localStorage.getItem('token')}`
          }
        });
        if (response.ok) {
          const data = await response.json();
          setRecentScans(data.slice(0, 4));
          
          const total = data.length;
          const healthy = data.filter((s: any) => s.prediction.toLowerCase().includes('healthy')).length;
          setStats({
            total,
            healthy,
            issues: total - healthy
          });
        }
      } catch (error) {
        console.error('Failed to fetch stats', error);
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, []);

  return (
    <div className="space-y-8 animate-in">
      {/* Welcome Banner */}
      <div className="relative overflow-hidden bg-primary rounded-2xl p-8 text-white shadow-xl shadow-primary/20">
        <div className="relative z-10 flex flex-col md:flex-row justify-between items-center gap-6">
          <div className="space-y-2">
            <h1 className="text-3xl font-bold">Good morning, Mahi!</h1>
            <p className="text-primary-light opacity-90 max-w-md">
              Your crops are looking good today. We've analyzed {stats.total} scans so far this season.
            </p>
            <div className="pt-4">
              <Link href="/scan" className="btn bg-white text-primary hover:bg-gray-50 px-8 py-3 rounded-xl inline-flex items-center gap-2 group">
                Start New Scan
                <ArrowRight size={18} className="group-hover:translate-x-1 transition-transform" />
              </Link>
            </div>
          </div>
          <div className="hidden md:block">
            <div className="w-48 h-48 bg-white/10 rounded-full flex items-center justify-center backdrop-blur-md">
              <Sprout size={80} className="text-white" />
            </div>
          </div>
        </div>
        {/* Decorative Circles */}
        <div className="absolute -right-10 -bottom-10 w-64 h-64 bg-white/5 rounded-full" />
        <div className="absolute right-20 -top-10 w-32 h-32 bg-white/10 rounded-full" />
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        {[
          { label: 'Total Scans', value: stats.total, icon: Clock, color: 'text-blue-600', bg: 'bg-blue-50' },
          { label: 'Healthy Crops', value: stats.healthy, icon: CheckCircle2, color: 'text-primary', bg: 'bg-primary-light' },
          { label: 'Issues Detected', value: stats.issues, icon: AlertCircle, color: 'text-danger', bg: 'bg-red-50' },
        ].map((stat, i) => (
          <div key={i} className="card flex items-center gap-4">
            <div className={cn("p-4 rounded-xl", stat.bg)}>
              <stat.icon size={24} className={stat.color} />
            </div>
            <div>
              <p className="text-sm text-muted font-medium">{stat.label}</p>
              <h3 className="text-2xl font-bold text-gray-900">{stat.value}</h3>
            </div>
          </div>
        ))}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* Recent Scans */}
        <div className="lg:col-span-2 space-y-4">
          <div className="flex justify-between items-center">
            <h2 className="text-xl font-bold text-gray-900">Recent Scans</h2>
            <Link href="/history" className="text-primary text-sm font-semibold hover:underline">View All History</Link>
          </div>
          
          <div className="space-y-3">
            {loading ? (
              Array(3).fill(0).map((_, i) => (
                <div key={i} className="card animate-pulse h-24 bg-gray-50 border-none" />
              ))
            ) : recentScans.length === 0 ? (
              <div className="card text-center py-12 text-muted">
                <div className="mb-4 inline-flex items-center justify-center w-12 h-12 bg-gray-50 rounded-full">
                  <Clock size={20} />
                </div>
                <p>No recent scans found.</p>
                <Link href="/scan" className="text-primary font-semibold hover:underline mt-2 inline-block text-sm">Create your first scan</Link>
              </div>
            ) : (
              recentScans.map((scan) => (
                <div key={scan.id} className="card flex items-center justify-between p-4 group">
                  <div className="flex items-center gap-4">
                    <div className="w-16 h-16 rounded-xl overflow-hidden bg-gray-100 flex-shrink-0">
                      <img 
                        src={`http://localhost:8000${scan.image_url}`} 
                        alt="scan" 
                        className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500"
                        onError={(e: any) => e.target.src = 'https://via.placeholder.com/64?text=🌿'}
                      />
                    </div>
                    <div>
                      <h4 className="font-bold text-gray-900">{scan.prediction}</h4>
                      <div className="flex items-center gap-3 mt-1">
                        <span className="text-xs text-muted font-medium">{scan.crop_type}</span>
                        <span className="w-1 h-1 bg-gray-300 rounded-full" />
                        <span className="text-xs text-muted">{new Date(scan.created_at).toLocaleDateString()}</span>
                      </div>
                    </div>
                  </div>
                  <div className="flex items-center gap-4">
                    <span className={cn(
                      "badge",
                      scan.severity === 'High' ? "bg-red-100 text-red-600" : "bg-green-100 text-primary"
                    )}>
                      {scan.severity}
                    </span>
                    <ChevronRight size={20} className="text-gray-300 group-hover:text-primary transition-colors" />
                  </div>
                </div>
              ))
            )}
          </div>
        </div>

        {/* Quick Tips */}
        <div className="space-y-4">
          <h2 className="text-xl font-bold text-gray-900">Expert Tips</h2>
          <div className="space-y-4">
            {[
              { title: 'Optimizing Drip Irrigation', desc: 'Save 30% more water by timing your irrigation...', category: 'Watering' },
              { title: 'Organic Pest Control', desc: 'Using neem oil can prevent 90% of early blights...', category: 'Protection' },
              { title: 'Soil PH Management', desc: 'The ideal PH for tomato crops is between 6.0 and 6.8...', category: 'Soil' }
            ].map((tip, i) => (
              <div key={i} className="card p-5 space-y-3 cursor-pointer border-none shadow-sm hover:shadow-md">
                <span className="inline-block px-2 py-1 bg-gray-50 text-gray-600 text-[10px] font-bold uppercase rounded-md tracking-wider">
                  {tip.category}
                </span>
                <h4 className="font-bold text-gray-900 leading-tight">{tip.title}</h4>
                <p className="text-sm text-muted leading-relaxed line-clamp-2">{tip.desc}</p>
                <Link href="/tips" className="flex items-center text-primary text-xs font-bold gap-1 mt-2">
                  Read Full Tip <ArrowRight size={12} />
                </Link>
              </div>
            ))}
            <Link href="/library" className="flex items-center justify-center gap-2 p-4 w-full text-sm font-bold text-primary bg-primary/5 rounded-xl hover:bg-primary/10 transition-colors">
              <BookOpen size={16} />
              Browse Disease Library
            </Link>
          </div>
        </div>
      </div>
    </div>
  );
}
