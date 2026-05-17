import React from 'react';

export function AgentIcon({ icon, status }) {
  // Status can be 'pending', 'running', 'done'
  let bgClasses = 'bg-gray-100 text-gray-400';
  let borderClasses = 'border-gray-200';
  let ringClasses = '';

  if (status === 'running') {
    bgClasses = 'bg-blue-100 text-blue-600';
    borderClasses = 'border-blue-300';
    ringClasses = 'ring-4 ring-blue-100 animate-pulse';
  } else if (status === 'done') {
    bgClasses = 'bg-green-100 text-green-600';
    borderClasses = 'border-green-300';
  }

  return (
    <div className={`relative flex items-center justify-center w-12 h-12 rounded-full border-2 ${bgClasses} ${borderClasses} ${ringClasses} transition-all duration-300 z-10 bg-white`}>
      <span className="text-xl" role="img" aria-label="agent icon">{icon}</span>
      
      {status === 'done' && (
        <div className="absolute -bottom-1 -right-1 w-5 h-5 bg-green-500 rounded-full border-2 border-white flex items-center justify-center shadow-sm">
          <svg className="w-3 h-3 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M5 13l4 4L19 7" />
          </svg>
        </div>
      )}
    </div>
  );
}
