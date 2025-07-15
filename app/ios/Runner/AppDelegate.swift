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
      print("Warning: Google Maps API key not found in .env file")
    }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func getGoogleMapsApiKey() -> String? {
    // Try to read from Flutter assets
    guard let path = Bundle.main.path(forResource: "flutter_assets/.env", ofType: nil) else {
      print("Could not find .env file in flutter_assets")
      return nil
    }
    
    do {
      let content = try String(contentsOfFile: path)
      let lines = content.components(separatedBy: .newlines)
      
      for line in lines {
        if line.hasPrefix("GOOGLE_API_KEY=") {
          let apiKey = String(line.dropFirst("GOOGLE_API_KEY=".count))
          return apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        }
      }
    } catch {
      print("Error reading .env file: \(error)")
    }
    
    return nil
  }
}
