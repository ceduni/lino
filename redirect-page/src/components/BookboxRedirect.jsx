// src/components/BookboxRedirect.jsx
import React, { useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';

const BookboxRedirect = () => {
  const { id } = useParams();
  const [status, setStatus] = useState('detecting');
  const [countdown, setCountdown] = useState(3);

  useEffect(() => {
    const tryOpenApp = () => {
      setStatus('trying');
      
      // Try to open the app
      const appUrl = `lino://bookbox/${id}`;
      window.location.href = appUrl;
      
      // Start countdown for fallback
      let timeLeft = 3;
      const countdownInterval = setInterval(() => {
        timeLeft -= 1;
        setCountdown(timeLeft);
        
        if (timeLeft <= 0) {
          clearInterval(countdownInterval);
          setStatus('fallback');
        }
      }, 1000);
      
      // Check if user left the page (app opened)
      const checkBlur = () => {
        clearInterval(countdownInterval);
        // If user returns, they didn't have the app
        setStatus('fallback');
      };
      
      window.addEventListener('focus', checkBlur);
      
      // Cleanup
      return () => {
        clearInterval(countdownInterval);
        window.removeEventListener('focus', checkBlur);
      };
    };

    // Start trying to open app after a brief delay
    const timeout = setTimeout(tryOpenApp, 500);
    
    return () => clearTimeout(timeout);
  }, [id]);

  const handleDownloadApp = () => {
    // Detect platform and redirect appropriately
    const userAgent = navigator.userAgent.toLowerCase();
    if (/android/.test(userAgent)) {
      window.open('https://play.google.com/store/apps/details?id=ca.umontreal.ceduni.lino', '_blank');
    } else if (/iphone|ipad|ipod/.test(userAgent)) {
      window.open('https://apps.apple.com/app/lino/id123456789', '_blank');
    } else {
      // Desktop - show both options
      window.open('https://play.google.com/store/apps/details?id=ca.umontreal.ceduni.lino', '_blank');
    }
  };

  const handleGoToMain = () => {
    window.open('https://ceduni.github.io/lino/', '_blank');
  };

  if (status === 'detecting') {
    return (
      <div className="bookbox-container">
        <div className="bookbox-content">
          <div className="loader">⏳</div>
          <h2>Getting ready...</h2>
          <p>Preparing to open bookbox {id}</p>
        </div>
      </div>
    );
  }

  if (status === 'trying') {
    return (
      <div className="bookbox-container">
        <div className="bookbox-content">
          <div className="loader spinning">📚</div>
          <h2>Opening Lino App</h2>
          <p>Bookbox ID: <strong>{id}</strong></p>
          <p className="countdown">Fallback in {countdown}s...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="bookbox-container">
      <div className="bookbox-content">
        <div className="logo">📱</div>
        <h2>App Not Found</h2>
        <p>To access bookbox <strong>{id}</strong>, you need the Lino app.</p>
        
        <div className="action-buttons">
          <button 
            className="download-btn primary"
            onClick={handleDownloadApp}
          >
            Download Lino App
          </button>
          
          <button 
            className="secondary-btn"
            onClick={handleGoToMain}
          >
            Visit Main Site
          </button>
        </div>
      </div>
    </div>
  );
};

export default BookboxRedirect;