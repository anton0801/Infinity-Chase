import SwiftUI

class ApplicationOrigentationChecker: NSObject, UIApplicationDelegate {
    
    static var orientationLock = UIInterfaceOrientationMask.all
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return ApplicationOrigentationChecker.orientationLock
    }
    
}
