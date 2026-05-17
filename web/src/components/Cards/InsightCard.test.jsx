import React from 'react';
import { render, screen, cleanup } from '@testing-library/react';
import { describe, it, expect, afterEach } from 'vitest';
import { InsightCard } from './InsightCard';

describe('InsightCard Module', () => {
  afterEach(cleanup);

  const mockReport = {
    severity_score: 9,
    affected_domains: ['pricing', 'logistics', 'revenue'],
    primary_insight: 'Fuel prices increased by 20%, erasing all margin from free delivery zones.',
    causal_chain: ['Fuel ↑', 'Delivery Cost ↑', 'Margin ↓', 'Revenue Gap']
  };

  it('renders nothing if no report provided', () => {
    const { container } = render(<InsightCard />);
    expect(container.firstChild).toBeNull();
  });

  it('renders primary insight and affected domains', () => {
    render(<InsightCard report={mockReport} />);
    expect(screen.getByText(mockReport.primary_insight)).toBeDefined();
    expect(screen.getByText('pricing')).toBeDefined();
    expect(screen.getByText('logistics')).toBeDefined();
  });

  it('renders severity score correctly (HIGH/red pulse for 9)', () => {
    const { container } = render(<InsightCard report={mockReport} />);
    const badge = screen.getByText('HIGH (9/10)');
    expect(badge).toBeDefined();
    // HIGH badge uses pulse
    expect(badge.className).toContain('animate-pulse');
    expect(badge.className).toContain('text-red-800');
  });

  it('renders severity score correctly (MEDIUM for 6)', () => {
    render(<InsightCard report={{ ...mockReport, severity_score: 6 }} />);
    const badge = screen.getByText('MEDIUM (6/10)');
    expect(badge).toBeDefined();
    expect(badge.className).not.toContain('animate-pulse');
    expect(badge.className).toContain('text-amber-800');
  });

  it('renders severity score correctly (LOW for 2)', () => {
    render(<InsightCard report={{ ...mockReport, severity_score: 2 }} />);
    const badge = screen.getByText('LOW (2/10)');
    expect(badge).toBeDefined();
    expect(badge.className).toContain('text-emerald-800');
  });

  it('renders causal chain pills properly', () => {
    render(<InsightCard report={mockReport} />);
    mockReport.causal_chain.forEach(segment => {
      expect(screen.getByText(segment)).toBeDefined();
    });
  });
});
