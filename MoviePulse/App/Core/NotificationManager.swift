import UIKit
import UserNotifications

class NotificationManager {
    
    static let shared = NotificationManager()
    
    private enum NotificationKeys {
        static let notificationEnabledKey = "notifications_enabled"
        static let hasRequestedPermissionKey = "has_requested_notification_permission"
    }

    func hasRequestedPermission() -> Bool {
        return UserDefaults.standard.bool(forKey: NotificationKeys.hasRequestedPermissionKey)
    }

    private func markPermissionRequested() {
        UserDefaults.standard.set(true, forKey: NotificationKeys.hasRequestedPermissionKey)
    }
    
    func setNotificationEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: NotificationKeys.notificationEnabledKey)
        
        if enabled {
            requestNotificationPermission()
        } else {
            DispatchQueue.main.async {
                UIApplication.shared.unregisterForRemoteNotifications()
            }
        }
    }
    
    func isNotificationEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: NotificationKeys.notificationEnabledKey)
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            self.markPermissionRequested()
            
            if let error = error {
                print("Request notification permission error: \(error.localizedDescription)")
                return
            }
            
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                    NotificationCenter.default.post(name: .requestGDPR, object: nil)
                }
            } else {
                print("User denied notification permission")
                self.setNotificationEnabled(false)
                NotificationCenter.default.post(name: .requestGDPR, object: nil)
            }
        }
    }
    
    func checkSystemNotificationPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional:
                completion(true)
            case .denied, .notDetermined, .ephemeral:
                completion(false)
            @unknown default:
                completion(false)
            }
        }
    }
    
    func syncNotification() {
        checkSystemNotificationPermission { granted in
            DispatchQueue.main.async {
                let currentState = self.isNotificationEnabled()
                
                if currentState != granted {
                    // Update state in app
                    UserDefaults.standard.set(granted, forKey: NotificationKeys.notificationEnabledKey)
                    
                    // Post notification state is change
                    NotificationCenter.default.post(name: .permisstionNotificationChange, object: nil)
                }
            }
        }
    }
}
