import React from 'react';

export function Skeleton({ className = '', variant = 'rectangular' }) {
  const baseClasses = 'animate-pulse bg-gray-200';
  const variantClasses = variant === 'circular' ? 'rounded-full' : 'rounded-md';
  
  return (
    <div className={`${baseClasses} ${variantClasses} ${className}`} aria-hidden="true" />
  );
}
