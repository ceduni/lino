import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Read API key from .env file in Flutter assets
    if let apiKey = getGoogleMapsApiKey() {
      GMSServices.provideAPIKey(apiKey)
    } else {
      print("Warning: Google Maps API key not found in Secrets.plist file")
    }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func getGoogleMapsApiKey() -> String? {
    // Try to read from Secrets.plist file
    guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist") else {
      print("Could not find Secrets.plist file")
      return nil
    }
    
    guard let plist = NSDictionary(contentsOfFile: path) else {
      print("Could not load Secrets.plist file")
      return nil
    }
    
    guard let apiKey = plist["GOOGLE_API_KEY"] as? String else {
      print("GOOGLE_API_KEY not found in Secrets.plist")
      return nil
    }
    
    return apiKey
  }
}
