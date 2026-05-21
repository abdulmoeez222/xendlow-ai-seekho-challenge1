import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'
import { api } from './api'
import { supabase } from './supabase'

describe('Supabase Client', () => {
  it('initializes supabase client with env variables', () => {
    // The createClient function creates an object with various methods.
    // We just verify it's not null and has expected shape.
    expect(supabase).toBeDefined()
    expect(supabase.channel).toBeDefined()
    expect(supabase.from).toBeDefined()
  })
})

describe('API Library', () => {
  beforeEach(() => {
    global.fetch = vi.fn()
  })

  afterEach(() => {
    vi.resetAllMocks()
  })

  it('runScenario calls correct endpoint with POST', async () => {
    global.fetch.mockResolvedValueOnce({
      json: () => Promise.resolve({ success: true, planId: '123' })
    })

    const result = await api.runScenario('scenario-1')
    
    expect(global.fetch).toHaveBeenCalledWith(
      expect.stringContaining('/run-scenario/scenario-1'),
      expect.objectContaining({ method: 'POST' })
    )
    expect(result).toEqual({ success: true, planId: '123' })
  })

  it('runCustom calls /run-custom with POST and body', async () => {
    global.fetch.mockResolvedValueOnce({
      json: () => Promise.resolve({ success: true })
    })

    const signals = { text: 'test' }
    const result = await api.runCustom(signals)
    
    expect(global.fetch).toHaveBeenCalledWith(
      expect.stringContaining('/run-custom'),
      expect.objectContaining({ 
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ signals })
      })
    )
    expect(result).toEqual({ success: true })
  })

  it('getStateBefore calls /state/before', async () => {
    global.fetch.mockResolvedValueOnce({
      json: () => Promise.resolve({ pricing: 100 })
    })

    const result = await api.getStateBefore()
    
    expect(global.fetch).toHaveBeenCalledWith(
      expect.stringContaining('/state/before')
    )
    expect(result).toEqual({ pricing: 100 })
  })

  it('getStateAfter calls /state/after/{planId}', async () => {
    global.fetch.mockResolvedValueOnce({
      json: () => Promise.resolve({ pricing: 120 })
    })

    const result = await api.getStateAfter('plan-456')
    
    expect(global.fetch).toHaveBeenCalledWith(
      expect.stringContaining('/state/after/plan-456')
    )
    expect(result).toEqual({ pricing: 120 })
  })

  it('getLogs calls /logs/{planId}', async () => {
    global.fetch.mockResolvedValueOnce({
      json: () => Promise.resolve({ logs: [] })
    })

    const result = await api.getLogs('plan-456')
    
    expect(global.fetch).toHaveBeenCalledWith(
      expect.stringContaining('/logs/plan-456')
    )
    expect(result).toEqual({ logs: [] })
  })

  it('getScenarios calls /scenarios', async () => {
    global.fetch.mockResolvedValueOnce({
      json: () => Promise.resolve([{ id: 1 }])
    })

    const result = await api.getScenarios()
    
    expect(global.fetch).toHaveBeenCalledWith(
      expect.stringContaining('/scenarios')
    )
    expect(result).toEqual([{ id: 1 }])
  })
})
