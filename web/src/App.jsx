import React, { useState } from 'react';
import { Dashboard } from './pages/Dashboard';
import { Login } from './pages/Login';

function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(false);

  if (!isAuthenticated) {
    return <Login onLogin={() => setIsAuthenticated(true)} />;
  }

  return (
    <Dashboard />
  );
}

export default App;
