// src/components/LanguageToggle.jsx
import React from 'react';
import { useLanguage } from '../contexts/LanguageContext';

const LanguageToggle = () => {
  const { currentLanguage, toggleLanguage } = useLanguage();

  return (
    <button 
      onClick={toggleLanguage}
      className="language-toggle"
      title={currentLanguage === 'en' ? 'Switch to French' : 'Changer vers l\'anglais'}
    >
      <span className="flag">
        {currentLanguage === 'en' ? '🇺🇸' : '🇫🇷'}
      </span>
      <span className="lang-code">
        {currentLanguage.toUpperCase()}
      </span>
    </button>
  );
};

export default LanguageToggle;