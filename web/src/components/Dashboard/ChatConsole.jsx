import React, { useRef, useEffect } from 'react';
import { usePipelineStore } from '../../store/pipelineStore';

export function ChatConsole({ runScenario, runCustom, approvePlan, rejectPlan }) {
  const inputRef = useRef(null);
  const endRef = useRef(null);
  
  const isRunning = usePipelineStore(state => state.isRunning);
  const currentStep = usePipelineStore(state => state.currentStep);
  const completedSteps = usePipelineStore(state => state.completedSteps);
  const actionPlan = usePipelineStore(state => state.actionPlan);
  const executionLog = usePipelineStore(state => state.executionLog);
  const finalReport = usePipelineStore(state => state.finalReport);
  
  const handleSubmit = (e) => {
    e.preventDefault();
    if (!inputRef.current.value.trim()) return;
    runCustom(inputRef.current.value);
    inputRef.current.value = '';
  };

  useEffect(() => {
    endRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [currentStep, completedSteps, actionPlan, executionLog, finalReport]);

  const renderScenarioCards = () => (
    <div className="grid gap-4 w-full max-w-2xl mt-8">
      <div 
        onClick={() => runScenario(1)}
        className="p-4 rounded-xl bg-slate-800/50 border border-slate-700 hover:border-blue-500 hover:bg-slate-800 cursor-pointer transition-all flex items-start gap-4"
      >
        <div className="w-10 h-10 rounded-full bg-blue-500/20 text-blue-500 flex items-center justify-center shrink-0">1</div>
        <div>
          <h3 className="text-white font-semibold">Regional Sales Drop + Fuel Shock</h3>
          <p className="text-slate-400 text-sm mt-1">Three compounding signals hit Lahore distribution simultaneously</p>
        </div>
      </div>
      <div 
        onClick={() => runScenario(2)}
        className="p-4 rounded-xl bg-slate-800/50 border border-slate-700 hover:border-purple-500 hover:bg-slate-800 cursor-pointer transition-all flex items-start gap-4"
      >
        <div className="w-10 h-10 rounded-full bg-purple-500/20 text-purple-500 flex items-center justify-center shrink-0">2</div>
        <div>
          <h3 className="text-white font-semibold">Competitor Price Drop + Inventory Surplus</h3>
          <p className="text-slate-400 text-sm mt-1">Market pressure plus overstock creates margin and capacity crisis</p>
        </div>
      </div>
      <div 
        onClick={() => runScenario(3)}
        className="p-4 rounded-xl bg-slate-800/50 border border-slate-700 hover:border-red-500 hover:bg-slate-800 cursor-pointer transition-all flex items-start gap-4"
      >
        <div className="w-10 h-10 rounded-full bg-red-500/20 text-red-500 flex items-center justify-center shrink-0">3</div>
        <div>
          <h3 className="text-white font-semibold">Rupee Devaluation + Import Pipeline Exposure</h3>
          <p className="text-slate-400 text-sm mt-1">Currency shock hits dollar-denominated inventory pipeline</p>
        </div>
      </div>
    </div>
  );

  return (
    <div className="flex flex-col h-screen bg-[#0F172A] relative">
      <header className="px-6 py-4 border-b border-slate-800 flex justify-between items-center bg-[#0F172A]/90 backdrop-blur z-10 sticky top-0">
        <h1 className="text-xl font-bold text-white">Chat Console</h1>
        <div className="flex items-center gap-4">
          <div className="bg-slate-800 px-3 py-1.5 rounded-full border border-slate-700 flex items-center gap-2">
            <svg className="w-4 h-4 text-amber-500" fill="currentColor" viewBox="0 0 20 20">
              <path d="M17.293 13.293A8 8 0 016.707 2.707a8.001 8.001 0 1010.586 10.586z"></path>
            </svg>
            <span className="text-amber-500 font-bold text-sm">15</span>
          </div>
          <button onClick={() => window.location.reload()} className="text-slate-400 hover:text-white">
            <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
            </svg>
          </button>
        </div>
      </header>
      
      <div className="flex-1 overflow-y-auto p-6 space-y-6">
        {!isRunning && completedSteps.length === 0 ? (
          <div className="max-w-3xl mx-auto flex flex-col items-center justify-center mt-12">
            <div className="w-16 h-16 bg-blue-600/20 rounded-2xl flex items-center justify-center text-blue-500 mb-6 border border-blue-500/30">
              <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/>
              </svg>
            </div>
            <h2 className="text-2xl font-bold text-white mb-2">Insight AI Agent</h2>
            <p className="text-slate-400 text-center">Select a market shock scenario to execute the autonomous operations engine.</p>
            {renderScenarioCards()}
          </div>
        ) : (
          <div className="max-w-3xl mx-auto space-y-6">
            <div className="flex justify-end">
              <div className="bg-blue-600 text-white px-5 py-3 rounded-2xl rounded-tr-sm max-w-lg shadow-sm">
                Analyze and formulate action for active scenario
              </div>
            </div>
            
            <div className="flex gap-4">
              <div className="w-8 h-8 rounded-full bg-blue-600/20 text-blue-500 flex items-center justify-center shrink-0 border border-blue-500/30">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/>
                </svg>
              </div>
              <div className="flex-1 bg-slate-800/50 border border-slate-700/50 p-5 rounded-2xl rounded-tl-sm shadow-sm space-y-4">
                <div className="flex items-center gap-2 mb-2">
                  <svg className="w-4 h-4 text-blue-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 6V4m0 2a2 2 0 100 4m0-4a2 2 0 110 4m-6 8a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4m6 6v10m6-2a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4" />
                  </svg>
                  <span className="text-white font-semibold">Agent Pipeline Status</span>
                </div>
                
                <div className="space-y-3">
                  <div className="flex items-center gap-3">
                    {completedSteps.includes(0) ? <div className="w-2 h-2 rounded-full bg-green-500" /> : <div className="w-2 h-2 rounded-full bg-blue-500 animate-pulse" />}
                    <span className="text-slate-400 text-sm font-bold w-20">[Ingestor]</span>
                    <span className={`text-sm ${completedSteps.includes(0) ? 'text-green-400' : 'text-blue-400'}`}>
                      {completedSteps.includes(0) ? 'Normalizing CSV Order Logs... Completed' : 'Running...'}
                    </span>
                  </div>
                  
                  {(completedSteps.includes(0) || currentStep === 1) && (
                    <div className="flex items-center gap-3">
                      {completedSteps.includes(1) ? <div className="w-2 h-2 rounded-full bg-green-500" /> : <div className="w-2 h-2 rounded-full bg-blue-500 animate-pulse" />}
                      <span className="text-slate-400 text-sm font-bold w-20">[Analyst]</span>
                      <span className={`text-sm ${completedSteps.includes(1) ? 'text-green-400' : 'text-blue-400'}`}>
                        {completedSteps.includes(1) ? 'Compounding Causal Chain... Completed' : 'Running...'}
                      </span>
                    </div>
                  )}

                  {(completedSteps.includes(1) || currentStep === 2) && (
                    <div className="flex items-center gap-3">
                      {completedSteps.includes(2) ? <div className="w-2 h-2 rounded-full bg-green-500" /> : <div className="w-2 h-2 rounded-full bg-blue-500 animate-pulse" />}
                      <span className="text-slate-400 text-sm font-bold w-20">[Planner]</span>
                      <span className={`text-sm ${completedSteps.includes(2) ? 'text-green-400' : 'text-blue-400'}`}>
                        {completedSteps.includes(2) ? 'Calculating Optimal Strategy... Completed' : 'Running...'}
                      </span>
                    </div>
                  )}

                  {(completedSteps.includes(2) || currentStep === 3) && (
                    <div className="flex items-center gap-3">
                      {completedSteps.includes(3) ? <div className="w-2 h-2 rounded-full bg-green-500" /> : <div className="w-2 h-2 rounded-full bg-blue-500 animate-pulse" />}
                      <span className="text-slate-400 text-sm font-bold w-20">[Executor]</span>
                      <span className={`text-sm ${completedSteps.includes(3) ? 'text-green-400' : 'text-slate-500'}`}>
                        {completedSteps.includes(3) ? 'Applying database mutations... Completed' : (currentStep === 3 ? 'Running...' : 'Waiting for approval...')}
                      </span>
                    </div>
                  )}

                  {(completedSteps.includes(3) || currentStep === 4) && (
                    <div className="flex items-center gap-3">
                      {completedSteps.includes(4) ? <div className="w-2 h-2 rounded-full bg-green-500" /> : <div className="w-2 h-2 rounded-full bg-blue-500 animate-pulse" />}
                      <span className="text-slate-400 text-sm font-bold w-20">[Reporter]</span>
                      <span className={`text-sm ${completedSteps.includes(4) ? 'text-green-400' : 'text-slate-500'}`}>
                        {completedSteps.includes(4) ? 'Generating impact report... Completed' : (currentStep === 4 ? 'Running...' : 'Waiting...')}
                      </span>
                    </div>
                  )}
                </div>
              </div>
            </div>

            {actionPlan && !executionLog && (
              <div className="flex gap-4 animate-in slide-in-from-bottom-4 fade-in duration-500">
                <div className="w-8 shrink-0" />
                <div className="flex-1 bg-slate-800/50 border border-slate-700/50 p-5 rounded-2xl shadow-sm">
                  <div className="text-xs font-bold text-slate-400 tracking-wider mb-2">PROPOSED STRATEGY</div>
                  <h3 className="text-white font-semibold text-lg mb-4">{actionPlan.selected_action}</h3>
                  
                  <div className="bg-slate-900/80 rounded-xl p-3 flex items-center gap-3 mb-4">
                    <span className="text-slate-400 text-sm">Before:</span>
                    <span className="text-red-400 font-medium text-sm flex-1 truncate">
                      {actionPlan.action_type === 'campaign' ? 'Active - PKR 22K/day spend' : 'Old Value'}
                    </span>
                    <svg className="w-4 h-4 text-slate-500 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M14 5l7 7m0 0l-7 7m7-7H3" />
                    </svg>
                    <span className="text-slate-400 text-sm">After:</span>
                    <span className="text-green-400 font-medium text-sm flex-1 truncate">
                      {actionPlan.action_type === 'campaign' ? 'Paused - Reallocated' : 'New Value'}
                    </span>
                  </div>

                  <div className="text-sm font-semibold text-slate-300 mb-1">Agent Reasoning Citation:</div>
                  <p className="text-slate-400 text-sm leading-relaxed mb-4">{actionPlan.reasoning}</p>

                  <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-lg bg-emerald-500/10 border border-emerald-500/20 text-emerald-400 text-xs font-bold mb-6">
                    <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                    Strategy ready for execution
                  </div>

                  {currentStep === 3 ? (
                    <div className="flex gap-4">
                      <button 
                        onClick={() => rejectPlan(actionPlan.id)}
                        className="flex-1 py-3 px-4 rounded-xl border border-red-500/30 text-red-400 font-semibold hover:bg-red-500/10 transition-colors"
                      >
                        Reject (Abandon)
                      </button>
                      <button 
                        onClick={() => approvePlan(actionPlan.id)}
                        className="flex-1 py-3 px-4 rounded-xl bg-green-600 hover:bg-green-500 text-white font-semibold shadow-lg shadow-green-900/20 transition-colors"
                      >
                        Accept (Execute)
                      </button>
                    </div>
                  ) : null}
                </div>
              </div>
            )}

            {finalReport && (
              <div className="flex gap-4 animate-in slide-in-from-bottom-4 fade-in duration-500">
                <div className="w-8 shrink-0" />
                <div className="flex-1 bg-slate-800/50 border border-slate-700/50 p-5 rounded-2xl shadow-sm">
                  <div className="flex items-center gap-2 mb-4 pb-4 border-b border-slate-700/50">
                    <svg className="w-5 h-5 text-green-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                    <span className="text-white font-semibold">Plan accepted and executed</span>
                  </div>
                  <h3 className="text-green-400 font-bold text-lg mb-2">{finalReport.projected_revenue_recovery || "Execution Complete"}</h3>
                  <p className="text-slate-300 text-sm leading-relaxed">{finalReport.summary_report}</p>
                </div>
              </div>
            )}
            
            <div ref={endRef} className="h-4" />
          </div>
        )}
      </div>

      <div className="p-4 bg-[#0B0F19] border-t border-slate-800">
        <div className="max-w-4xl mx-auto flex items-center gap-3">
          <button className="p-2 text-slate-400 hover:text-white transition-colors">
            <svg className="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15.172 7l-6.586 6.586a2 2 0 102.828 2.828l6.414-6.586a4 4 0 00-5.656-5.656l-6.415 6.585a6 6 0 108.486 8.486L20.5 13" />
            </svg>
          </button>
          <button className="p-2 text-slate-400 hover:text-white transition-colors">
            <svg className="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 11a7 7 0 01-7 7m0 0a7 7 0 01-7-7m7 7v4m0 0H8m4 0h4m-4-8a3 3 0 01-3-3V5a3 3 0 116 0v6a3 3 0 01-3 3z" />
            </svg>
          </button>
          <form onSubmit={handleSubmit} className="flex-1">
            <div className="relative">
              <input 
                ref={inputRef}
                type="text" 
                placeholder={isRunning ? "Type an instruction..." : "Type a signal or instruction..."}
                className="w-full bg-slate-800 text-white placeholder-slate-500 rounded-full py-3 px-6 pr-12 outline-none focus:ring-2 focus:ring-blue-500/50 transition-all border border-slate-700/50"
              />
              <button 
                type="submit"
                className="absolute right-2 top-1/2 -translate-y-1/2 p-2 text-blue-500 hover:text-blue-400 transition-colors"
              >
                <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8" />
                </svg>
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
}
