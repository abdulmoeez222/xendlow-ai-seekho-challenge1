import { create } from 'zustand'

export const usePipelineStore = create((set) => ({
  // Pipeline state
  isRunning: false,
  currentStep: null,      // 0-4 (which agent is active)
  completedSteps: [],     // array of step indexes

  // Data
  planId: null,
  signals: null,
  insightReport: null,
  actionPlan: null,
  executionLog: null,
  finalReport: null,

  // State snapshots
  stateBefore: null,
  stateAfter: null,

  // Realtime data (live DB rows)
  liveCampaigns: [],
  livePricingLog: [],
  liveNotifications: [],

  // Actions
  setStep: (step) => set({ currentStep: step }),
  completeStep: (step, data) => set((s) => ({
    completedSteps: [...s.completedSteps, step],
    ...data
  })),
  setLiveCampaigns: (rows) => set({ liveCampaigns: rows }),
  setLivePricingLog: (rows) => set({ livePricingLog: rows }),
  setLiveNotifications: (rows) => set({ liveNotifications: rows }),
  reset: () => set({
    isRunning: false, currentStep: null, completedSteps: [],
    planId: null, signals: null, insightReport: null,
    actionPlan: null, executionLog: null, finalReport: null,
    stateBefore: null, stateAfter: null,
    liveCampaigns: [], livePricingLog: [], liveNotifications: []
  })
}))
