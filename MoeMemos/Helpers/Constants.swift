//
//  Constants.swift
//  MoeMemos
//
//  Created by Mudkip on 2022/11/5.
//

import Foundation
import KeychainSwift

let groupContainerIdentifier = "group.me.mudkip.MoeMemos"
let keychainAccessGroupName = "AHAQ4D2466.me.mudkip.MoeMemos"
let memosHostKey = "memosHost"
let memosAccessTokenKey = "memosAccessToken"
let memosOpenIdKey = "memosOpenId"
let listItemSymbolList = ["- [ ] ", "- [x] ", "- [X] ", "* ", "- "]

enum CredentialStore {
    private static var sharedKeychain: KeychainSwift {
        let keychain = KeychainSwift()
        keychain.accessGroup = keychainAccessGroupName
        return keychain
    }

    private static var localKeychain: KeychainSwift { KeychainSwift() }

    static func saveAccessToken(_ token: String) {
        let savedToSharedKeychain = sharedKeychain.set(token, forKey: memosAccessTokenKey)
        let savedToLocalKeychain = localKeychain.set(token, forKey: memosAccessTokenKey)

        // TrollStore/unsigned builds can reject the original signed app's Keychain access group.
        // Persist an app-sandbox fallback only when neither Keychain location is writable.
        if !savedToSharedKeychain && !savedToLocalKeychain {
            UserDefaults.standard.set(token, forKey: memosAccessTokenKey)
            UserDefaults(suiteName: groupContainerIdentifier)?.set(token, forKey: memosAccessTokenKey)
        } else {
            UserDefaults.standard.removeObject(forKey: memosAccessTokenKey)
            UserDefaults(suiteName: groupContainerIdentifier)?.removeObject(forKey: memosAccessTokenKey)
        }
    }

    static func accessToken() -> String? {
        sharedKeychain.get(memosAccessTokenKey)
            ?? localKeychain.get(memosAccessTokenKey)
            ?? UserDefaults(suiteName: groupContainerIdentifier)?.string(forKey: memosAccessTokenKey)
            ?? UserDefaults.standard.string(forKey: memosAccessTokenKey)
    }

    static func deleteAccessToken() {
        sharedKeychain.delete(memosAccessTokenKey)
        localKeychain.delete(memosAccessTokenKey)
        UserDefaults(suiteName: groupContainerIdentifier)?.removeObject(forKey: memosAccessTokenKey)
        UserDefaults.standard.removeObject(forKey: memosAccessTokenKey)
    }

    static func saveHost(_ host: String) {
        UserDefaults(suiteName: groupContainerIdentifier)?.set(host, forKey: memosHostKey)
        UserDefaults.standard.set(host, forKey: memosHostKey)
    }

    static func host() -> String? {
        let shared = UserDefaults(suiteName: groupContainerIdentifier)?.string(forKey: memosHostKey)
        return (shared?.isEmpty == false ? shared : nil) ?? UserDefaults.standard.string(forKey: memosHostKey)
    }
}
