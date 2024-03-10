import SwiftUI

struct ContentView: View {
    @Environment(\.openURL) var openURL
    
    @State private var secret: String = ""
    @State var pulls = 0
    @State var message: String = "Loading..."
    
    var body: some View {
        Grid {
                    GridRow {
                        Text("secret")
                        SecureField("secret, e.g. P@ssword!", text: $secret)
                    }
                }.padding()
                
                VStack {
                    HStack {
                        
                        Button("save") {
                            Task {
                                do {
                                    try await CredentialsManager.set(secret: secret)
                                    let result = try await GitHub.shared.pullRequestsWaitingMyReview()
                                    pulls = result.totalCount
                                    message = "Saved. \(pulls) pull requests waiting for your review"
                                } catch {
                                    message = error.localizedDescription
                                }
                            }
                        }
                        
                    }
                    if (message != "") {
                        Text(message).foregroundStyle(.secondary).padding()
                    }
                }
        .padding()
        .task {
            do {
                guard let storedSecret = try CredentialsManager.get() else {
                    message = "Credentials missing"
                    return
                }
                
                secret = storedSecret
                let result = try await GitHub.shared.pullRequestsWaitingMyReview()
                pulls = result.totalCount
                message = "Loaded. \(pulls) pull requests waiting for your review"
                
            }
            catch {
                message = error.localizedDescription
            }
        }
    }
}

#Preview {
    ContentView()
}
