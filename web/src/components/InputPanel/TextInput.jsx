import React, { useState } from 'react';
import { usePipelineStore } from '../../store/pipelineStore';

export function TextInput({ onRunCustom }) {
  const [activeTab, setActiveTab] = useState('Text');
  const [inputValue, setInputValue] = useState('');
  const isRunning = usePipelineStore(state => state.isRunning);

  const tabs = ['Text', 'URL', 'File Upload'];

  const handleSubmit = (e) => {
    e.preventDefault();
    if (!inputValue.trim() || isRunning) return;
    
    // Shape the signals payload as an array of signal objects to match the backend expectation
    const signals = [{ type: activeTab.toLowerCase(), content: inputValue }];
    if (onRunCustom) onRunCustom(signals);
  };

  return (
    <div>
      <div style={{ background: '#F1F5F9', borderRadius: '10px', padding: '3px', display: 'flex', marginBottom: '16px' }}>
        {tabs.map(tab => (
          <button
            key={tab}
            type="button"
            onClick={() => setActiveTab(tab)}
            style={{
              flex: 1, padding: '8px 12px', fontSize: '13px', transition: 'all 0.2s', border: 'none',
              ...(activeTab === tab 
                ? { background: '#ffffff', borderRadius: '8px', color: '#1E293B', fontWeight: 500, boxShadow: '0 1px 3px rgba(0,0,0,0.08)' } 
                : { color: '#64748B', background: 'transparent' })
            }}
          >
            {tab}
          </button>
        ))}
      </div>
      <form onSubmit={handleSubmit}>
        {activeTab === 'Text' && (
          <textarea
            value={inputValue}
            onChange={(e) => setInputValue(e.target.value)}
            disabled={isRunning}
            placeholder="Describe the market conditions, pricing changes, or other signals..."
            className="w-full h-32 focus:outline-none resize-none disabled:cursor-not-allowed"
            style={{ background: '#F8FAFC', border: '1px solid #E2E8F0', borderRadius: '10px', padding: '12px', fontSize: '13px' }}
            onFocus={(e) => e.target.style.borderColor = '#93C5FD'}
            onBlur={(e) => e.target.style.borderColor = '#E2E8F0'}
          />
        )}
        {activeTab === 'URL' && (
          <input
            type="url"
            value={inputValue}
            onChange={(e) => setInputValue(e.target.value)}
            disabled={isRunning}
            placeholder="https://example.com/report.pdf"
            className="w-full focus:outline-none"
            style={{ background: '#F8FAFC', border: '1px solid #E2E8F0', borderRadius: '10px', padding: '12px', fontSize: '13px' }}
            onFocus={(e) => e.target.style.borderColor = '#93C5FD'}
            onBlur={(e) => e.target.style.borderColor = '#E2E8F0'}
          />
        )}
        {activeTab === 'File Upload' && (
          <div className="w-full h-32 border-2 border-dashed border-gray-300 flex items-center justify-center text-gray-500" style={{ borderRadius: '10px', background: '#F8FAFC' }}>
            <span style={{ fontSize: '13px' }}>Drag and drop a file, or click to browse</span>
          </div>
        )}
        <div className="mt-4 flex justify-end">
          <button
            type="submit"
            disabled={isRunning || (!inputValue.trim() && activeTab !== 'File Upload')}
            style={{ 
              background: isRunning ? '#94A3B8' : '#1D4ED8', 
              color: 'white', 
              borderRadius: '10px', 
              padding: '10px 24px', 
              fontSize: '13px', 
              fontWeight: 500,
              cursor: isRunning ? 'not-allowed' : 'pointer',
              display: 'flex', alignItems: 'center', gap: '8px', border: 'none'
            }}
            className="transition-colors disabled:opacity-50"
          >
            {!isRunning && (
              <svg width="12" height="12" viewBox="0 0 24 24" fill="currentColor"><path d="M5 3l14 9-14 9V3z" /></svg>
            )}
            {isRunning ? 'Pipeline Running...' : 'Analyze Signals'}
          </button>
        </div>
      </form>
    </div>
  );
}
