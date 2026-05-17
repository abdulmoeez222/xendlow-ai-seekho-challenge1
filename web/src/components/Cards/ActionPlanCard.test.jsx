import React from 'react';
import { render, screen, cleanup, fireEvent } from '@testing-library/react';
import { describe, it, expect, afterEach } from 'vitest';
import { ActionPlanCard } from './ActionPlanCard';

describe('ActionPlanCard Module', () => {
  afterEach(cleanup);

  const mockPlan = {
    action_name: 'Deploy Dynamic Discounting',
    reasoning: 'The causal analysis shows an immediate need to offset logistics costs. We are prioritizing revenue retention over pure margin in the short term.',
    fallbacks: [
      { condition: 'discount fails to convert', action: 'halt campaign and revert pricing' }
    ]
  };

  it('renders nothing if no plan provided', () => {
    const { container } = render(<ActionPlanCard />);
    expect(container.firstChild).toBeNull();
  });

  it('renders committed action badge', () => {
    render(<ActionPlanCard plan={mockPlan} />);
    expect(screen.getByText('COMMITTED ACTION')).toBeDefined();
    // Verify it doesn't say "recommended"
    expect(screen.queryByText(/recommended/i)).toBeNull();
  });

  it('renders action name and reasoning', () => {
    render(<ActionPlanCard plan={mockPlan} />);
    expect(screen.getByText(mockPlan.action_name)).toBeDefined();
    // The quote includes the reasoning text
    expect(screen.getByText(`"${mockPlan.reasoning}"`)).toBeDefined();
  });

  it('toggles fallback accordion', () => {
    render(<ActionPlanCard plan={mockPlan} />);
    
    // Check fallback toggle exists
    const toggleBtn = screen.getByText('Fallback Conditions');
    expect(toggleBtn).toBeDefined();

    // The fallback condition content might be hidden by CSS/opacity (Framer motion)
    // but in jsdom without full CSS resolution, it might just be removed or present.
    // AnimatePresence removes from DOM when exit animation completes. Initially it's not in DOM.
    expect(screen.queryByText(/discount fails to convert/)).toBeNull();

    // Click to open
    fireEvent.click(toggleBtn);

    // Now it should be in DOM
    expect(screen.getByText(/discount fails to convert/)).toBeDefined();
    expect(screen.getByText(/halt campaign and revert pricing/)).toBeDefined();
  });
});
