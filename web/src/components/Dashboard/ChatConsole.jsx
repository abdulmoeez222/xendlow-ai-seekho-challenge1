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
  const pipelineStatus = usePipelineStore(state => state.status); // 'idle', 'running', 'pending_approval', 'executing', 'completed', 'failed'
  
  const handleSubmit = (e) => {
    e.preventDefault();
    if (!inputRef.current.value.trim()) return;
    runCustom(inputRef.current.value);
    inputRef.current.value = '';
  };

  useEffect(() => {
    if (endRef.current?.scrollIntoView) {
      endRef.current.scrollIntoView({ behavior: 'smooth' });
    }
  }, [currentStep, completedSteps, actionPlan, executionLog, finalReport]);

  const renderScenarioCards = () => (
    <div className="grid gap-3 w-full max-w-2xl mt-8">
      <div 
        onClick={() => runScenario(1)}
        className="p-4 rounded-xl bg-[#111111] border border-[#222222] hover:border-[#444444] hover:bg-[#161616] cursor-pointer transition-all flex items-start gap-4"
      >
        <div className="w-8 h-8 rounded-lg bg-[#1A1A1A] text-white flex items-center justify-center shrink-0 text-sm font-semibold border border-[#222222]">01</div>
        <div>
          <h3 className="text-white font-medium text-sm">Regional Sales Drop + Fuel Shock</h3>
          <p className="text-[#8C8C8C] text-xs mt-1 leading-normal">Three compounding signals hit Lahore distribution simultaneously</p>
        </div>
      </div>
      <div 
        onClick={() => runScenario(2)}
        className="p-4 rounded-xl bg-[#111111] border border-[#222222] hover:border-[#444444] hover:bg-[#161616] cursor-pointer transition-all flex items-start gap-4"
      >
        <div className="w-8 h-8 rounded-lg bg-[#1A1A1A] text-white flex items-center justify-center shrink-0 text-sm font-semibold border border-[#222222]">02</div>
        <div>
          <h3 className="text-white font-medium text-sm">Competitor Price Drop + Inventory Surplus</h3>
          <p className="text-[#8C8C8C] text-xs mt-1 leading-normal">Market pressure plus overstock creates margin and capacity crisis</p>
        </div>
      </div>
      <div 
        onClick={() => runScenario(3)}
        className="p-4 rounded-xl bg-[#111111] border border-[#222222] hover:border-[#444444] hover:bg-[#161616] cursor-pointer transition-all flex items-start gap-4"
      >
        <div className="w-8 h-8 rounded-lg bg-[#1A1A1A] text-white flex items-center justify-center shrink-0 text-sm font-semibold border border-[#222222]">03</div>
        <div>
          <h3 className="text-white font-medium text-sm">Rupee Devaluation + Import Pipeline Exposure</h3>
          <p className="text-[#8C8C8C] text-xs mt-1 leading-normal">Currency shock hits dollar-denominated inventory pipeline</p>
        </div>
      </div>
    </div>
  );

  return (
    <div className="flex flex-col h-screen bg-[#0A0A0A] relative text-white">
      <header className="px-6 py-4 border-b border-[#1F1F1F] flex justify-between items-center bg-[#0A0A0A]/95 backdrop-blur z-10 sticky top-0">
        <h1 className="text-sm font-semibold text-white tracking-tight">Chat Console</h1>
        <div className="flex items-center gap-3">
          <div className="bg-[#111111] px-2.5 py-1 rounded-full border border-[#222222] flex items-center gap-1.5">
            <svg className="w-3.5 h-3.5 text-white" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24">
              <polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/>
            </svg>
            <span className="text-white font-bold text-xs">15 tokens</span>
          </div>
          <button onClick={() => window.location.reload()} className="text-[#8C8C8C] hover:text-white p-1 transition-colors">
            <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
            </svg>
          </button>
        </div>
      </header>
      
      <div className="flex-1 overflow-y-auto p-6 space-y-6">
        {!isRunning && completedSteps.length === 0 ? (
          <div className="max-w-3xl mx-auto flex flex-col items-center justify-center mt-16">
            <div className="w-12 h-12 bg-white rounded-xl flex items-center justify-center text-[#0A0A0A] mb-6">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/>
              </svg>
            </div>
            <h2 className="text-lg font-semibold text-white mb-1 tracking-tight">Autonomous Operations Engine</h2>
            <p className="text-[#8C8C8C] text-sm text-center">Select a scenario or describe a signal to activate the 5-agent pipeline.</p>
            {renderScenarioCards()}
          </div>
        ) : (
          <div className="max-w-3xl mx-auto space-y-6">
            <div className="flex justify-end">
              <div className="bg-[#111111] border border-[#222222] text-white px-4 py-2.5 rounded-2xl rounded-tr-sm max-w-lg shadow-sm text-sm">
                Analyze and formulate action for active scenario
              </div>
            </div>
            
            <div className="flex gap-4">
              <div className="w-7 h-7 rounded-full bg-white text-[#0A0A0A] flex items-center justify-center shrink-0">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
                  <polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/>
                </svg>
              </div>
              <div className="flex-1 bg-[#111111] border border-[#222222] p-5 rounded-2xl rounded-tl-sm shadow-sm space-y-4">
                <div className="flex items-center gap-2 mb-2 pb-2 border-b border-[#1A1A1A]">
                  <span className="text-white font-semibold text-xs uppercase tracking-wider">Agent Pipeline Status</span>
                </div>
                
                <div className="space-y-3">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-3">
                      <span className="text-[#8C8C8C] text-xs font-semibold w-16">[Ingestor]</span>
                      <span className="text-xs text-white">Normalizing CSV Order Logs</span>
                    </div>
                    {completedSteps.includes(0) ? (
                      <span className="text-xs text-[#8C8C8C]">Complete</span>
                    ) : (
                      <span className="text-xs text-white animate-pulse">Processing...</span>
                    )}
                  </div>
                  <div className="h-[1px] bg-[#161616]" />
                  
                  {(completedSteps.includes(0) || currentStep === 1) && (
                    <>
                      <div className="flex items-center justify-between">
                        <div className="flex items-center gap-3">
                          <span className="text-[#8C8C8C] text-xs font-semibold w-16">[Analyst]</span>
                          <span className="text-xs text-white">Compounding Causal Chain</span>
                        </div>
                        {completedSteps.includes(1) ? (
                          <span className="text-xs text-[#8C8C8C]">Complete</span>
                        ) : (
                          <span className="text-xs text-white animate-pulse">Processing...</span>
                        )}
                      </div>
                      <div className="h-[1px] bg-[#161616]" />
                    </>
                  )}

                  {(completedSteps.includes(1) || currentStep === 2) && (
                    <>
                      <div className="flex items-center justify-between">
                        <div className="flex items-center gap-3">
                          <span className="text-[#8C8C8C] text-xs font-semibold w-16">[Planner]</span>
                          <span className="text-xs text-white">Calculating Optimal Strategy</span>
                        </div>
                        {completedSteps.includes(2) ? (
                          <span className="text-xs text-[#8C8C8C]">Complete</span>
                        ) : (
                          <span className="text-xs text-white animate-pulse">Processing...</span>
                        )}
                      </div>
                      <div className="h-[1px] bg-[#161616]" />
                    </>
                  )}

                  {(completedSteps.includes(2) || currentStep === 3) && (
                    <>
                      <div className="flex items-center justify-between">
                        <div className="flex items-center gap-3">
                          <span className="text-[#8C8C8C] text-xs font-semibold w-16">[Executor]</span>
                          <span className="text-xs text-white">Applying database mutations</span>
                        </div>
                        {completedSteps.includes(3) ? (
                          <span className="text-xs text-[#8C8C8C]">Complete</span>
                        ) : currentStep === 3 ? (
                          <span className="text-xs text-white animate-pulse">Processing...</span>
                        ) : (
                          <span className="text-xs text-[#555555]">Waiting for approval</span>
                        )}
                      </div>
                      <div className="h-[1px] bg-[#161616]" />
                    </>
                  )}

                  {(completedSteps.includes(3) || currentStep === 4) && (
                    <div className="flex items-center justify-between">
                      <div className="flex items-center gap-3">
                        <span className="text-[#8C8C8C] text-xs font-semibold w-16">[Reporter]</span>
                        <span className="text-xs text-white">Generating impact report</span>
                      </div>
                      {completedSteps.includes(4) ? (
                        <span className="text-xs text-[#8C8C8C]">Complete</span>
                      ) : currentStep === 4 ? (
                        <span className="text-xs text-white animate-pulse">Processing...</span>
                      ) : (
                        <span className="text-xs text-[#555555]">Waiting</span>
                      )}
                    </div>
                  )}
                </div>
              </div>
            </div>
 
            {actionPlan && !executionLog && (
              <div className="flex gap-4">
                <div className="w-7 shrink-0" />
                <div className="flex-1 bg-[#111111] border border-[#222222] p-5 rounded-2xl shadow-sm space-y-4">
                  <div>
                    <div className="text-[10px] font-bold text-[#8C8C8C] tracking-wider uppercase mb-1">PROPOSED STRATEGY</div>
                    <h3 className="text-white font-semibold text-base tracking-tight">{actionPlan.selected_action}</h3>
                  </div>
                  
                  <div className="bg-[#0A0A0A] border border-[#1A1A1A] rounded-xl p-3 flex items-center gap-3">
                    <span className="text-[#555555] text-xs font-medium">Before:</span>
                    <span className="text-[#8C8C8C] text-xs font-medium flex-1 truncate">
                      {actionPlan.action_type === 'campaign' ? 'Active · PKR 22K/day spend · ROAS 1.8x' : 'Old Value'}
                    </span>
                    <svg className="w-3.5 h-3.5 text-[#555555] shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M14 5l7 7m0 0l-7 7m7-7H3" />
                    </svg>
                    <span className="text-[#555555] text-xs font-medium">After:</span>
                    <span className="text-white text-xs font-medium flex-1 truncate">
                      {actionPlan.action_type === 'campaign' ? 'Paused · Reallocate to seasonal' : 'New Value'}
                    </span>
                  </div>

                  <div className="space-y-1">
                    <div className="text-xs font-semibold text-[#8C8C8C]">Reasoning Citations</div>
                    <p className="text-[#8C8C8C] text-xs leading-relaxed">{actionPlan.reasoning}</p>
                  </div>

                  {currentStep === 3 ? (
                    <div className="flex gap-3 pt-2">
                      <button 
                        onClick={() => rejectPlan(actionPlan.id)}
                        className="flex-1 py-2.5 px-4 rounded-xl border border-[#222222] text-[#8C8C8C] text-xs font-semibold hover:bg-[#161616] hover:text-white transition-all"
                      >
                        Reject
                      </button>
                      <button 
                        onClick={() => approvePlan(actionPlan.id)}
                        className="flex-1 py-2.5 px-4 rounded-xl bg-white text-[#0A0A0A] text-xs font-semibold hover:bg-neutral-200 transition-all"
                      >
                        Accept & Execute
                      </button>
                    </div>
                  ) : null}
                </div>
              </div>
            )}
 
            {finalReport && (
              <div className="flex gap-4">
                <div className="w-7 shrink-0" />
                <div className="flex-1 bg-[#111111] border border-[#222222] p-5 rounded-2xl shadow-sm space-y-3">
                  <div className="flex items-center gap-2 pb-2 border-b border-[#1A1A1A]">
                    <svg className="w-4 h-4 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                    <span className="text-white font-semibold text-xs uppercase tracking-wider">Plan accepted and executed</span>
                  </div>
                  <h3 className="text-white font-bold text-sm">{finalReport.projected_revenue_recovery || "Execution Complete"}</h3>
                  <p className="text-[#8C8C8C] text-xs leading-relaxed">
                    {finalReport.summary_report || finalReport.executive_summary_markdown || ''}
                  </p>
                </div>
              </div>
            )}
            
            <div ref={endRef} className="h-4" />
          </div>
        )}
      </div>

      <div className="p-4 bg-[#0A0A0A] border-t border-[#1F1F1F]">
        <div className="max-w-3xl mx-auto flex items-center gap-3">
          <form onSubmit={handleSubmit} className="flex-1">
            <div className="relative">
              <input 
                ref={inputRef}
                type="text" 
                placeholder={isRunning ? "Type an instruction..." : "Type a signal or instruction..."}
                className="w-full bg-[#111111] text-white placeholder-[#555555] rounded-xl py-3 px-4 pr-12 outline-none border border-[#222222] focus:border-[#444444] transition-all text-sm"
              />
              <button 
                type="submit"
                className="absolute right-2 top-1/2 -translate-y-1/2 p-1.5 text-white hover:text-neutral-300 transition-colors"
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
