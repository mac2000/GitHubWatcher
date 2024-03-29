import SwiftUI

@main
struct GitHubWatcherApp: App {
    // Hacky workaround
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// Widgets does not allow us to have links, thats why we are doing this workaround with deep links
// tap on widget number opens our app with deep link
// we are checking if thats a case and if yes - open corresponding GitHub page in Safari and terminate the app
class AppDelegate: NSObject, NSApplicationDelegate {
    func application(_ application: NSApplication, open urls: [URL]) {
        if let url = urls.first {
            guard let scheme = url.scheme, let host = url.host else {
                return
            }
            
            guard scheme == "ua.org.mac-blog.GitHubWatcher" else {
                return
            }
    
            var targetUrl: URL?
            if host == "review" {
                targetUrl = URL(string:"https://github.com/pulls?q=is%3Apr+is%3Aopen+-review%3Aapproved+-draft%3Atrue+-label%3Anot-for-review+org%3Arabotaua+review-requested%3A%40me+-author%3Adependabot%5Bbot%5D")
            } else if host == "my" {
                targetUrl = URL(string:"https://github.com/pulls?q=is%3Aopen+review%3Aapproved+author%3A%40me+")
            } else if host == "dependabot" {
                targetUrl = URL(string:"https://github.com/pulls?q=is%3Apr+is%3Aopen+-review%3Aapproved+-draft%3Atrue+-label%3Anot-for-review+org%3Arabotaua+review-requested%3A%40me+author%3Adependabot%5Bbot%5D")
            }
            if targetUrl != nil {
                NSWorkspace.shared.open(targetUrl!)
                NSApp.terminate(nil)
            }
        }
    }
}
