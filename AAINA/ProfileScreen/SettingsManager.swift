//
//  SettingsManager.swift
//  AAINA
//
//  Created by Archana Bisht on 08/04/26.
//

import Foundation

class SettingsManager {

    static let shared = SettingsManager()
    private init() {}

    private let notificationsKey = "notifications_enabled"
    private let languageKey = "app_language"

    var isNotificationsEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: notificationsKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: notificationsKey)
        }
    }

    var selectedLanguage: String {
        get { UserDefaults.standard.string(forKey: languageKey) ?? "English" }
        set { UserDefaults.standard.set(newValue, forKey: languageKey) }
    }

    var selectedLanguageCode: String {
        get { UserDefaults.standard.string(forKey: "app_language_code") ?? "en" }
        set { UserDefaults.standard.set(newValue, forKey: "app_language_code") }
    }
}
