import React from 'react';

const colorMap = {
  green: 'bg-emerald-100 text-emerald-800 border-emerald-200',
  blue: 'bg-blue-100 text-blue-800 border-blue-200',
  purple: 'bg-purple-100 text-purple-800 border-purple-200',
  amber: 'bg-amber-100 text-amber-800 border-amber-200',
  red: 'bg-red-100 text-red-800 border-red-200',
};

export function Badge({ children, color = 'blue', pulse = false, className = '' }) {
  const baseClasses = 'inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-semibold border';
  const colorClasses = colorMap[color] || colorMap.blue;
  const pulseClasses = pulse ? 'animate-pulse shadow-[0_0_8px_rgba(220,38,38,0.5)]' : '';

  return (
    <span className={`${baseClasses} ${colorClasses} ${pulseClasses} ${className}`}>
      {children}
    </span>
  );
}
