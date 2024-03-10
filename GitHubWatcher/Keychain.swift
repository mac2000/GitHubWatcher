import Foundation

// https://www.youtube.com/watch?v=cQjgBIJtMbw
class KeychainManager {
    /// Retrieve secret for given `account` in `service`.
    ///
    /// ```
    /// let (status, secret) = KeychainManager.get(service: "https://github.com", account: "john")
    /// if status == errSecSuccess && secret != nil {
    ///     print("secret: \(secret)")
    /// }
    /// ```
    ///
    /// - Parameters:
    ///     - service: can by any string, but usually is an url, e.g.: https://github.com/
    ///     - account: our username, e.g.: john
    ///
    /// - Returns: tuple with `status` and `secret`.
    static func get(service: String, account: String) -> (status: OSStatus, secret: String?) {
        var result: CFTypeRef?
        let status = SecItemCopyMatching([
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecReturnData: kCFBooleanTrue as Any,
            kSecMatchLimit: kSecMatchLimitOne
        ] as CFDictionary, &result)
        guard let data = result as? Data else {
            return (status, nil)
        }
        let secret = String(decoding: data, as: UTF8.self)
        return (status, secret)
    }
    
    static func insert(service: String, account: String, secret: String) async -> OSStatus {
        guard let data = secret.data(using: .utf8) else {
            return errSecBadReq
        }
        return SecItemAdd([
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecValueData: data
        ] as CFDictionary, nil)
    }
    
    static func update(service: String, account: String, secret: String) -> OSStatus {
        guard let data = secret.data(using: .utf8) else {
            return errSecBadReq
        }
        return SecItemUpdate([
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ] as CFDictionary, [
            kSecValueData: data
        ] as CFDictionary)
    }
    
    /// Deletes secret from keychain
    ///
    /// ```
    ///  Task {
    ///     let status = await Keychain.delete(service: "https://github.com/", "john")
    ///     if status != errSecSuccess {
    ///         message = String(SecCopyErrorMessageString(status, nil) ?? "unknown error" as CFString)
    ///         print("unable delete secret because of \(message)")
    ///     }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///     - service: can by any string, but usually is an url, e.g.: https://github.com/
    ///     - account: our username, e.g.: john
    static func delete(service: String, account: String) async -> OSStatus {
        return SecItemDelete([
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ] as CFDictionary)
    }
    
    /// Saves secret to keychain
    ///
    /// ```
    ///  Task {
    ///     let status = await Keychain.save(service: "https://github.com/", "john", secret: "P@ssword!")
    ///     if status != errSecSuccess {
    ///         message = String(SecCopyErrorMessageString(status, nil) ?? "unknown error" as CFString)
    ///         print("failure: \(message)")
    ///     }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///     - service: can by any string, but usually is an url, e.g.: https://github.com/
    ///     - account: our username, e.g.: john
    ///     - secret: password to be saved
    static func save(service: String, account: String, secret: String) async -> OSStatus {
        let status = update(service: service, account: account, secret: secret)
        if status == errSecItemNotFound {
            return await insert(service: service, account: account, secret: secret)
        }
        return status
    }
}
