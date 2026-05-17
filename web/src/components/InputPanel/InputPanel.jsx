import React from 'react';
import { ScenarioButtons } from './ScenarioButtons';
import { TextInput } from './TextInput';

export function InputPanel({ onRunScenario, onRunCustom }) {
  return (
    <section className="max-w-4xl mx-auto w-full mb-10">
      <div className="bg-[#ffffff] rounded-[16px] border border-[#E2E8F0] p-[24px]">
        <div className="mb-6">
          <p className="text-[#64748B] text-sm">Ingest market signals to generate and execute an autonomous action plan.</p>
        </div>
        
        <ScenarioButtons onRunScenario={onRunScenario} />
        
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px', margin: '16px 0' }}>
          <div style={{ flex: 1, height: '1px', background: '#E2E8F0' }}></div>
          <span style={{ fontSize: '11px', color: '#94A3B8', fontWeight: 500, letterSpacing: '0.06em' }}>or ingest custom signals</span>
          <div style={{ flex: 1, height: '1px', background: '#E2E8F0' }}></div>
        </div>
        
        <TextInput onRunCustom={onRunCustom} />
      </div>
    </section>
  );
}
