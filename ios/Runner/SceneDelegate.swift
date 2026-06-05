import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard let windowScene = (scene as? UIWindowScene) else { return }

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let flutterEngine = appDelegate.flutterEngine
    let flutterViewController = FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil)

    let window = UIWindow(windowScene: windowScene)
    window.rootViewController = flutterViewController
    self.window = window
    window.makeKeyAndVisible()

    super.scene(scene, willConnectTo: session, options: connectionOptions)
  }
}
