import Foundation

class CredentialsManager {
    static private let service = "github.com"
    static private let account = "GitHubWatcher"
    
    static func get() throws -> String? {
        let (status, secret) = KeychainManager.get(service: service, account: account)
        if status == errSecSuccess {
            return secret
        } else {
            let message = String(SecCopyErrorMessageString(status, nil) ?? "unknown" as CFString)
            throw CredentialsManagerError.runtimeError(message)
        }
    }
    
    static func set(secret: String) async throws {
        let status = await KeychainManager.save(service: service, account: account, secret: secret)
        if status != errSecSuccess {
            let message = String(SecCopyErrorMessageString(status, nil) ?? "unknown" as CFString)
            throw CredentialsManagerError.runtimeError(message)
        }
    }
}

enum CredentialsManagerError: Error {
    case runtimeError(String)
}
