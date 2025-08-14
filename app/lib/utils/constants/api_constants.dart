/* -- LIST OF Constants used in APIs -- */

// Base API URL - Change this to switch between production and development
// const String baseApiUrl = 'https://lino-1.onrender.com';

// For local development, uncomment the line below and comment the line above
const String baseApiUrl = 'http://10.0.2.2:3000';

// WebSocket URL - derived from base API URL
// Automatically converts http:// to ws:// and https:// to wss://
String get webSocketUrl {
  if (baseApiUrl.startsWith('https://')) {
    return '${baseApiUrl.replaceFirst('https://', 'wss://')}/ws';
  } else if (baseApiUrl.startsWith('http://')) {
    return '${baseApiUrl.replaceFirst('http://', 'ws://')}/ws';
  } else {
    throw Exception('Invalid base API URL format'); 
  }
}

