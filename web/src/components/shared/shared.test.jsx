import React from 'react';
import { render, screen } from '@testing-library/react';
import { describe, it, expect, vi } from 'vitest';
import { Badge } from './Badge';
import { Skeleton } from './Skeleton';
import { MetricCard } from './MetricCard';

describe('Shared Components', () => {
  describe('Badge', () => {
    it('renders with children and default blue color', () => {
      const { container } = render(<Badge>Status</Badge>);
      expect(screen.getByText('Status')).toBeDefined();
      expect(container.firstChild.className).toContain('text-blue-800');
    });

    it('applies pulse animation when pulse is true', () => {
      const { container } = render(<Badge pulse={true}>Alert</Badge>);
      expect(container.firstChild.className).toContain('animate-pulse');
    });

    it('renders different colors correctly', () => {
      const { container } = render(<Badge color="red">Danger</Badge>);
      expect(container.firstChild.className).toContain('text-red-800');
    });
  });

  describe('Skeleton', () => {
    it('renders with rectangular variant by default', () => {
      const { container } = render(<Skeleton className="w-10" />);
      expect(container.firstChild.className).toContain('animate-pulse');
      expect(container.firstChild.className).toContain('rounded-md');
    });

    it('renders circular variant', () => {
      const { container } = render(<Skeleton variant="circular" />);
      expect(container.firstChild.className).toContain('rounded-full');
    });
  });

  describe('MetricCard', () => {
    // Mock Framer motion's animate
    it('renders static label and value', () => {
      render(<MetricCard label="Revenue" value="1000" icon="💰" color="green" />);
      expect(screen.getByText('Revenue')).toBeDefined();
      // Because Framer motion might take a tick to update displayValue if animating
      // We check if it eventually renders the value or starts at 0.
      // Since our initial state in MetricCard is displayValue = value, it should be in the DOM.
      expect(screen.getByText('1000')).toBeDefined();
    });
  });
});
