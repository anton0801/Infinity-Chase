import SwiftUI

@main
struct Infinity_ChaseApp: App {
    
    @UIApplicationDelegateAdaptor(ApplicationOrigentationChecker.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ChaseMenu()
        }
    }
}
