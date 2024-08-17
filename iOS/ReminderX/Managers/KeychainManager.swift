import Foundation
import Security

class KeychainManager {
    static func save(_ data: Data, service: String, account: String) -> OSStatus {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]

        SecItemDelete(query as CFDictionary)
        return SecItemAdd(query as CFDictionary, nil)
    }

    static func load(service: String, account: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == noErr else { return nil }

        return (item as? Data)
    }
    static func delete(service: String, account: String) -> OSStatus {
            let query = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account
            ] as [String: Any]

            return SecItemDelete(query as CFDictionary)
    }
    static func loadAuthKey() -> String? {
            guard let authKeyData = load(service: "YourAppService", account: "authKey"),
                  let authKey = String(data: authKeyData, encoding: .utf8) else {
                return nil
            }
            return authKey
        }
}
