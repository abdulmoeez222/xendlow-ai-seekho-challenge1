import React from 'react';
import { render, screen, cleanup, fireEvent } from '@testing-library/react';
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { Dashboard } from './Dashboard';
import { usePipelineStore } from '../store/pipelineStore';

// Mock components to keep this test focused on tab management and layout rendering
vi.mock('../components/Dashboard/Sidebar', () => ({
  Sidebar: ({ currentTab, setCurrentTab }) => (
    <div data-testid="sidebar">
      <span>Active Tab: {currentTab}</span>
      <button onClick={() => setCurrentTab('chat')}>Chat Tab Button</button>
      <button onClick={() => setCurrentTab('store')}>Store Tab Button</button>
      <button onClick={() => setCurrentTab('products')}>Products Tab Button</button>
      <button onClick={() => setCurrentTab('sales')}>Sales Tab Button</button>
      <button onClick={() => setCurrentTab('ads')}>Ads Tab Button</button>
    </div>
  )
}));

vi.mock('../components/Dashboard/ChatConsole', () => ({
  ChatConsole: () => <div data-testid="chat-console" />
}));

vi.mock('../components/Dashboard/StoreMetrics', () => ({
  StoreMetrics: () => <div data-testid="store-metrics" />
}));

vi.mock('../components/Dashboard/ProductsCatalog', () => ({
  ProductsCatalog: () => <div data-testid="products-catalog" />
}));

vi.mock('../components/Dashboard/SalesLedger', () => ({
  SalesLedger: () => <div data-testid="sales-ledger" />
}));

vi.mock('../components/Dashboard/AdsManager', () => ({
  AdsManager: () => <div data-testid="ads-manager" />
}));

vi.mock('../hooks/useRealtime', () => ({ useRealtime: vi.fn() }));
vi.mock('../hooks/usePipeline', () => ({
  usePipeline: () => ({ runScenario: vi.fn(), runCustom: vi.fn() })
}));

describe('Dashboard Module', () => {
  afterEach(cleanup);
  beforeEach(() => {
    usePipelineStore.getState().reset();
    vi.clearAllMocks();
  });

  it('renders Sidebar and default ChatConsole', () => {
    render(<Dashboard />);
    expect(screen.getByTestId('sidebar')).toBeDefined();
    expect(screen.getByText('Active Tab: chat')).toBeDefined();
    expect(screen.getByTestId('chat-console')).toBeDefined();
  });

  it('switches tabs correctly when Sidebar requests it', () => {
    render(<Dashboard />);
    
    // Switch to Store tab
    fireEvent.click(screen.getByText('Store Tab Button'));
    expect(screen.getByText('Active Tab: store')).toBeDefined();
    expect(screen.getByTestId('store-metrics')).toBeDefined();
    expect(screen.queryByTestId('chat-console')).toBeNull();

    // Switch to Products tab
    fireEvent.click(screen.getByText('Products Tab Button'));
    expect(screen.getByText('Active Tab: products')).toBeDefined();
    expect(screen.getByTestId('products-catalog')).toBeDefined();
    expect(screen.queryByTestId('store-metrics')).toBeNull();

    // Switch to Sales tab
    fireEvent.click(screen.getByText('Sales Tab Button'));
    expect(screen.getByText('Active Tab: sales')).toBeDefined();
    expect(screen.getByTestId('sales-ledger')).toBeDefined();

    // Switch to Ads tab
    fireEvent.click(screen.getByText('Ads Tab Button'));
    expect(screen.getByText('Active Tab: ads')).toBeDefined();
    expect(screen.getByTestId('ads-manager')).toBeDefined();
  });
});
