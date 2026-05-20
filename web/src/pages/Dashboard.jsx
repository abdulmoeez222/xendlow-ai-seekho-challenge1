import React, { useState } from 'react';
import { usePipelineStore } from '../store/pipelineStore';
import { usePipeline } from '../hooks/usePipeline';
import { useRealtime } from '../hooks/useRealtime';
import { api } from '../lib/api';

import { Sidebar } from '../components/Dashboard/Sidebar';
import { ChatConsole } from '../components/Dashboard/ChatConsole';
import { StoreMetrics } from '../components/Dashboard/StoreMetrics';
import { ProductsCatalog } from '../components/Dashboard/ProductsCatalog';
import { SalesLedger } from '../components/Dashboard/SalesLedger';
import { AdsManager } from '../components/Dashboard/AdsManager';

export function Dashboard() {
  const [currentTab, setCurrentTab] = useState('chat');
  
  const { runScenario, runCustom } = usePipeline();
  const actionPlan = usePipelineStore(state => state.actionPlan);

  // Activate realtime Subscriptions
  const realTimeId = actionPlan?.id || null;
  useRealtime(realTimeId);

  const handleApprovePlan = async (planId) => {
    try {
      await api.approvePlan(planId);
      // State updates will naturally flow via polling since execution_log will be generated
    } catch (e) {
      console.error("Approval failed:", e);
    }
  };

  const handleRejectPlan = async (planId) => {
    try {
      await api.rejectPlan(planId);
      // Reset pipeline state on reject
      usePipelineStore.getState().reset();
    } catch (e) {
      console.error("Rejection failed:", e);
    }
  };

  const renderContent = () => {
    switch (currentTab) {
      case 'chat':
        return (
          <ChatConsole 
            runScenario={runScenario} 
            runCustom={runCustom} 
            approvePlan={handleApprovePlan}
            rejectPlan={handleRejectPlan}
          />
        );
      case 'store':
        return <StoreMetrics />;
      case 'products':
        return <ProductsCatalog />;
      case 'sales':
        return <SalesLedger />;
      case 'ads':
        return <AdsManager />;
      default:
        return <ChatConsole runScenario={runScenario} runCustom={runCustom} approvePlan={handleApprovePlan} rejectPlan={handleRejectPlan} />;
    }
  };

  return (
    <div className="flex h-screen bg-[#0F172A] overflow-hidden">
      <Sidebar currentTab={currentTab} setCurrentTab={setCurrentTab} />
      
      {/* Main Content Area */}
      <main className="flex-1 flex flex-col relative overflow-hidden">
        {renderContent()}
      </main>
    </div>
  );
}
