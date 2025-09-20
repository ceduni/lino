// src/contexts/LanguageContext.jsx
import React, { createContext, useContext, useState, useEffect } from 'react';
import enTranslations from '../translations/en.json';
import frTranslations from '../translations/fr.json';

const LanguageContext = createContext();

const translations = {
  en: enTranslations,
  fr: frTranslations
};

export const useLanguage = () => {
  const context = useContext(LanguageContext);
  if (!context) {
    throw new Error('useLanguage must be used within a LanguageProvider');
  }
  return context;
};

// Function to detect device language
const detectDeviceLanguage = () => {
  const browserLang = navigator.language || navigator.languages[0];
  // Check if it's French (fr, fr-CA, fr-FR, etc.)
  if (browserLang.toLowerCase().startsWith('fr')) {
    return 'fr';
  }
  // Default to English
  return 'en';
};

export const LanguageProvider = ({ children }) => {
  const [currentLanguage, setCurrentLanguage] = useState(() => {
    // Try to get saved language from localStorage, otherwise detect device language
    const savedLanguage = localStorage.getItem('lino-language');
    return savedLanguage || detectDeviceLanguage();
  });

  // Save language preference to localStorage whenever it changes
  useEffect(() => {
    localStorage.setItem('lino-language', currentLanguage);
  }, [currentLanguage]);

  const toggleLanguage = () => {
    setCurrentLanguage(prev => prev === 'en' ? 'fr' : 'en');
  };

  const t = (key, params = {}) => {
    const keys = key.split('.');
    let value = translations[currentLanguage];
    
    for (const k of keys) {
      value = value?.[k];
    }
    
    if (!value) {
      // Fallback to English if translation not found
      value = translations.en;
      for (const k of keys) {
        value = value?.[k];
      }
    }
    
    // Replace parameters in the translation
    if (typeof value === 'string' && params) {
      return value.replace(/{(\w+)}/g, (match, param) => params[param] || match);
    }
    
    return value || key;
  };

  const value = {
    currentLanguage,
    setLanguage: setCurrentLanguage,
    toggleLanguage,
    t
  };

  return (
    <LanguageContext.Provider value={value}>
      {children}
    </LanguageContext.Provider>
  );
};