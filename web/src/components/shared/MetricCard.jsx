import React, { useEffect, useState } from 'react';
import { motion, useMotionValue, useTransform, animate } from 'framer-motion';

const iconColorMap = {
  green: 'text-emerald-600 bg-emerald-100',
  blue: 'text-blue-600 bg-blue-100',
  purple: 'text-purple-600 bg-purple-100',
  amber: 'text-amber-600 bg-amber-100',
};

export function MetricCard({ label, value, icon, color = 'blue' }) {
  const [displayValue, setDisplayValue] = useState(value);
  
  // Attempt to parse a numeric value out of the string if it contains one
  // e.g. "1,234 users" -> 1234, "$500" -> 500
  const count = useMotionValue(0);
  
  useEffect(() => {
    // Extract numbers, ignoring commas
    const numericMatch = String(value).replace(/,/g, '').match(/[\d.]+/);
    if (numericMatch) {
      const targetNumber = parseFloat(numericMatch[0]);
      
      const controls = animate(count, targetNumber, {
        duration: 1.5,
        ease: "easeOut",
        onUpdate: (latest) => {
          // Re-format the animated number back into the original string
          const formattedNumber = Math.floor(latest).toLocaleString();
          const newValue = String(value).replace(/[\d.,]+/, formattedNumber);
          setDisplayValue(newValue);
        }
      });
      
      return controls.stop;
    } else {
      setDisplayValue(value);
    }
  }, [value, count]);

  const colorClasses = iconColorMap[color] || iconColorMap.blue;

  return (
    <motion.div 
      initial={{ opacity: 0, y: 10 }}
      animate={{ opacity: 1, y: 0 }}
      className="bg-white rounded-xl shadow-sm border border-gray-100 p-5 flex items-center space-x-4"
    >
      <div className={`flex-shrink-0 w-12 h-12 flex items-center justify-center rounded-lg ${colorClasses} text-2xl`}>
        {icon}
      </div>
      <div>
        <p className="text-sm font-medium text-gray-500">{label}</p>
        <p className="text-2xl font-bold text-gray-900 mt-1">{displayValue}</p>
      </div>
    </motion.div>
  );
}
