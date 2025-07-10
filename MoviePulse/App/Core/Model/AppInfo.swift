import Foundation

struct AppInfo {
    static var name: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
               Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "Unknown App"
    }

    static var version: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "N/A"
    }

    static var build: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "N/A"
    }

    static var versionDescription: String {
        return "v\(version) (\(build))"
    }

    static var fullInfo: String {
        return "\(name) \(versionDescription)"
    }
}
