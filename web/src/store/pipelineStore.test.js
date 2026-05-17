import { describe, it, expect, beforeEach } from 'vitest'
import { usePipelineStore } from './pipelineStore'

describe('pipelineStore', () => {
  beforeEach(() => {
    // Reset store before each test
    usePipelineStore.getState().reset()
  })

  it('initializes with default state', () => {
    const state = usePipelineStore.getState()
    expect(state.isRunning).toBe(false)
    expect(state.currentStep).toBeNull()
    expect(state.completedSteps).toEqual([])
    expect(state.planId).toBeNull()
    expect(state.liveCampaigns).toEqual([])
    expect(state.livePricingLog).toEqual([])
    expect(state.liveNotifications).toEqual([])
  })

  it('setStep updates currentStep', () => {
    usePipelineStore.getState().setStep(2)
    expect(usePipelineStore.getState().currentStep).toBe(2)
  })

  it('completeStep adds to completedSteps and merges data', () => {
    usePipelineStore.getState().completeStep(0, { signals: { foo: 'bar' } })
    const state = usePipelineStore.getState()
    expect(state.completedSteps).toEqual([0])
    expect(state.signals).toEqual({ foo: 'bar' })

    // Complete another step
    usePipelineStore.getState().completeStep(1, { insightReport: { severity: 8 } })
    const state2 = usePipelineStore.getState()
    expect(state2.completedSteps).toEqual([0, 1])
    expect(state2.signals).toEqual({ foo: 'bar' }) // preserves old data
    expect(state2.insightReport).toEqual({ severity: 8 })
  })

  it('live data setters update correctly', () => {
    usePipelineStore.getState().setLiveCampaigns([{ id: 1 }])
    expect(usePipelineStore.getState().liveCampaigns).toEqual([{ id: 1 }])

    usePipelineStore.getState().setLivePricingLog([{ price: 100 }])
    expect(usePipelineStore.getState().livePricingLog).toEqual([{ price: 100 }])

    usePipelineStore.getState().setLiveNotifications([{ msg: 'hi' }])
    expect(usePipelineStore.getState().liveNotifications).toEqual([{ msg: 'hi' }])
  })

  it('reset clears all state', () => {
    usePipelineStore.getState().setStep(3)
    usePipelineStore.getState().completeStep(0, { planId: 'test-123', isRunning: true })
    usePipelineStore.getState().setLiveCampaigns([{ id: 1 }])
    
    // Ensure state is dirty
    expect(usePipelineStore.getState().planId).toBe('test-123')
    
    // Reset
    usePipelineStore.getState().reset()
    const state = usePipelineStore.getState()
    
    expect(state.isRunning).toBe(false)
    expect(state.currentStep).toBeNull()
    expect(state.completedSteps).toEqual([])
    expect(state.planId).toBeNull()
    expect(state.liveCampaigns).toEqual([])
  })
})
