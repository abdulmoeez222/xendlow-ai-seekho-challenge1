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
    <div className="min-h-screen bg-[#0A0A0A] flex items-center justify-center p-4">
      <div className="w-full max-w-md bg-[#111111] p-8 rounded-2xl border border-[#222222] shadow-xl relative overflow-hidden">
        <div className="relative z-10">
          <div className="w-12 h-12 bg-white rounded-xl flex items-center justify-center text-[#0A0A0A] mb-6 mx-auto">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
              <polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/>
            </svg>
          </div>
          
          <h2 className="text-xl font-semibold text-white text-center mb-1 tracking-tight">Insight AI</h2>
          <p className="text-[#8C8C8C] text-center mb-6 text-sm">Autonomous Operations Console</p>
          
          <div className="bg-[#161616] border border-[#222222] rounded-xl p-3.5 mb-6 text-center text-sm">
            <span className="text-[#8C8C8C] block mb-1 font-medium text-xs tracking-wider uppercase">Testing Credentials</span>
            <code className="text-[#555555] font-mono text-xs">admin@insightai.com / admin123</code>
          </div>
          
          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="block text-xs font-semibold text-[#8C8C8C] uppercase tracking-wider mb-1.5">Email Address</label>
              <input 
                type="email" 
                required
                value={email}
                onChange={e => setEmail(e.target.value)}
                className="w-full bg-[#161616] text-white border border-[#222222] rounded-xl px-4 py-3 text-sm focus:outline-none focus:border-[#444444] transition-all placeholder-[#555555]"
                placeholder="admin@insightai.com"
              />
            </div>
            
            <div>
              <label className="block text-xs font-semibold text-[#8C8C8C] uppercase tracking-wider mb-1.5">Password</label>
              <input 
                type="password" 
                required
                value={password}
                onChange={e => setPassword(e.target.value)}
                className="w-full bg-[#161616] text-white border border-[#222222] rounded-xl px-4 py-3 text-sm focus:outline-none focus:border-[#444444] transition-all placeholder-[#555555]"
                placeholder="••••••••"
              />
            </div>

            {error && <p className="text-[#FF9999] text-xs text-center font-medium pt-1">{error}</p>}
            
            <button 
              type="submit" 
              className="w-full bg-white hover:bg-neutral-200 text-[#0A0A0A] font-semibold py-3 px-4 rounded-xl transition-all mt-6 text-sm"
            >
              Sign In
            </button>
          </form>
        </div>
      </div>
    </div>
  );
}
