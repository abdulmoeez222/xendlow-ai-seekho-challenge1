import React, { useState } from 'react';

export function Login({ onLogin }) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');

  const handleSubmit = (e) => {
    e.preventDefault();
    if (email === 'admin@insightai.com' && password === 'admin123') {
      onLogin();
    } else {
      setError('Invalid credentials');
    }
  };

  return (
    <div className="min-h-screen bg-[#0F172A] flex items-center justify-center p-4">
      <div className="w-full max-w-md bg-slate-800/50 p-8 rounded-3xl border border-slate-700/50 shadow-2xl backdrop-blur-xl relative overflow-hidden">
        {/* Decorative elements */}
        <div className="absolute top-0 right-0 -mr-16 -mt-16 w-40 h-40 bg-blue-500/20 rounded-full blur-3xl"></div>
        <div className="absolute bottom-0 left-0 -ml-16 -mb-16 w-40 h-40 bg-purple-500/20 rounded-full blur-3xl"></div>
        
        <div className="relative z-10">
          <div className="w-16 h-16 bg-blue-600/20 rounded-2xl flex items-center justify-center text-blue-500 mb-6 mx-auto border border-blue-500/30">
            <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/>
            </svg>
          </div>
          
          <h2 className="text-2xl font-bold text-white text-center mb-2">Insight Engine Console</h2>
          <p className="text-slate-400 text-center mb-4 text-sm">Enter administrator credentials to access</p>
          
          <div className="bg-blue-900/30 border border-blue-500/30 rounded-xl p-3 mb-6 text-center text-blue-300 text-sm">
            <span className="font-semibold block mb-1">Testing Credentials:</span>
            admin@insightai.com / admin123
          </div>
          
          <form onSubmit={handleSubmit} className="space-y-5">
            <div>
              <label className="block text-sm font-medium text-slate-300 mb-1">Email</label>
              <input 
                type="email" 
                required
                value={email}
                onChange={e => setEmail(e.target.value)}
                className="w-full bg-slate-900/50 text-white border border-slate-700 rounded-xl px-4 py-3 focus:outline-none focus:border-blue-500 focus:ring-1 focus:ring-blue-500/50 transition-all placeholder-slate-600"
                placeholder="admin@insightai.com"
              />
            </div>
            
            <div>
              <label className="block text-sm font-medium text-slate-300 mb-1">Password</label>
              <input 
                type="password" 
                required
                value={password}
                onChange={e => setPassword(e.target.value)}
                className="w-full bg-slate-900/50 text-white border border-slate-700 rounded-xl px-4 py-3 focus:outline-none focus:border-blue-500 focus:ring-1 focus:ring-blue-500/50 transition-all placeholder-slate-600"
                placeholder="••••••••"
              />
            </div>

            {error && <p className="text-red-400 text-sm text-center font-medium animate-pulse">{error}</p>}
            
            <button 
              type="submit" 
              className="w-full bg-blue-600 hover:bg-blue-500 text-white font-bold py-3.5 px-4 rounded-xl shadow-lg shadow-blue-900/20 transition-all mt-4 hover:shadow-blue-900/40"
            >
              Secure Access
            </button>
          </form>
        </div>
      </div>
    </div>
  );
}
