import Flutter
import UIKit
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject],
           let apiKey = dict["GOOGLE_MAPS_API_KEY"] as? String {
          GMSServices.provideAPIKey(apiKey)
        } else {
          fatalError("Google Maps API key not found.")
        }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    // Handle the custom URL scheme
    if let scheme = url.scheme, scheme == "lino", let host = url.host {
      // Parse your URI here and navigate to the appropriate page
      // Example: lino://bookbox?bookBoxId=idblabla
      let bookBoxId = url.queryParameters?["bookBoxId"]
      // Use the parsed bookBoxId to navigate or show dialog
      // For example, use GetX to navigate or show dialog
      Get.dialog(BookBoxAction(bbid: bookBoxId));
    }
    return true
  }
}

// Extension to parse query parameters
extension URL {
  var queryParameters: [String: String]? {
    guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true) else { return nil }
    return components.queryItems?.reduce(into: [String: String](), { result, item in
      result[item.name] = item.value
    })
  }
}
