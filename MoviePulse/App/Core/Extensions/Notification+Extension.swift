import Foundation

extension Notification.Name {
    static let hideTabBar = Notification.Name("hide_tab_bar")
    static let showTabBar = Notification.Name("show_tab_bar")
    static let reloadFavoriteList = Notification.Name("reload_favorite_list")
    static let switchToDiscoverTab = Notification.Name("switch_to_discover_tab")
    static let requestGDPR = Notification.Name("request_gdpr")
    static let permisstionNotificationChange = Notification.Name("permission_notification_change")
}
