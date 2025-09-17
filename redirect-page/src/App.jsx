// src/App.jsx
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { LanguageProvider } from './contexts/LanguageContext';
import LandingPage from './components/LandingPage';
import BookboxRedirect from './components/BookboxRedirect';
import LanguageToggle from './components/LanguageToggle';
import './App.css';

function App() {
  return (
    <LanguageProvider>
      <Router>
        <div className="App">
          <LanguageToggle />
          <Routes>
            <Route path="/" element={<LandingPage />} />
            <Route path="/bookbox/:id" element={<BookboxRedirect />} />
            <Route path="*" element={<LandingPage />} />
          </Routes>
        </div>
      </Router>
    </LanguageProvider>
  );
}

export default App;