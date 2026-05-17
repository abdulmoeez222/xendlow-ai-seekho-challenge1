import React from 'react';
import { usePipelineStore } from '../../store/pipelineStore';

const DEMO_SCENARIOS = [
  { id: 1, label: "Regional Sales Drop + Fuel Shock", color: "bg-[#1D4ED8]", num: "01" },
  { id: 2, label: "Competitor Price Drop + Stock Surplus", color: "bg-[#6D28D9]", num: "02" },
  { id: 3, label: "Forex Shock + Import Dependency", color: "bg-[#B91C1C]", num: "03" }
];

export function ScenarioButtons({ onRunScenario }) {
  const isRunning = usePipelineStore(state => state.isRunning);

  return (
    <div className="mb-6">
      <h3 style={{ fontSize: '11px', fontWeight: 500, color: '#94A3B8', letterSpacing: '0.08em', textTransform: 'uppercase', marginBottom: '12px' }}>
        QUICK RUN DEMO SCENARIOS
      </h3>
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
        {DEMO_SCENARIOS.map(scenario => (
          <button
            key={scenario.id}
            disabled={isRunning}
            onClick={() => onRunScenario && onRunScenario(scenario.id)}
            className={`${scenario.color} hover:opacity-90 disabled:opacity-50 disabled:cursor-not-allowed text-white flex flex-col items-center justify-center text-center`}
            style={{ borderRadius: '12px', padding: '14px 16px' }}
          >
            <span style={{ fontWeight: 500, fontSize: '13px', lineHeight: '1.2' }}>{scenario.label}</span>
            <span style={{ fontSize: '10px', color: 'rgba(255,255,255,0.45)', marginTop: '4px' }}>Scenario {scenario.num}</span>
          </button>
        ))}
      </div>
    </div>
  );
}
