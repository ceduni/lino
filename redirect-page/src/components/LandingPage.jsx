// src/components/LandingPage.jsx
import React from 'react';
import { AppStoreButton, GooglePlayButton } from 'react-mobile-app-button';

const LandingPage = () => {
  const handleMoreDetails = () => {
    window.open('https://ceduni.github.io/lino/', '_blank');
  };

  return (
    <div className="landing-container">
      <div className="content">
        {/* Header */}
        <header className="header">
          <div className="logo">
            <img 
              src="/logo.png" 
              alt="Lino Logo" 
              className="logo-image"
            />
          </div>
        </header>

        {/* Main Content */}
        <main className="main">
          

          {/* Download Buttons */}
          <div className="download-section">
            <h2>Download the App</h2>
            <div className="download-buttons">
              <GooglePlayButton
                url="https://play.google.com/store/apps/details?id=ca.umontreal.ceduni.lino"
                theme="dark"
                className="download-btn"
              />
              
              <AppStoreButton
                url="https://apps.apple.com/app/lino/id123456789"
                theme="dark"
                className="download-btn"
              />
            </div>
          </div>

          {/* More Info Link */}
          <div className="more-info">
            <button 
              className="info-link"
              onClick={handleMoreDetails}
            >
              Learn more about Lino →
            </button>
          </div>
        </main>

        {/* Footer */}
        <footer className="footer">
          <p>
            A project by{' '}
            <a 
              href="https://github.com/ceduni" 
              target="_blank" 
              rel="noopener noreferrer"
              className="footer-link"
            >
              ceduni
            </a>
            {' '}• Université de Montréal
          </p>
        </footer>
      </div>
    </div>
  );
};

export default LandingPage;
