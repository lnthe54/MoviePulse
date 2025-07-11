import UIKit

struct Constants {
    
    static let HEIGHT_NAV: CGFloat = 56
    static let BOTTOM_TABBAR: CGFloat = 100
    static let feels: [String] = ["Excited", "Nostagic", "Tense", "Scared", "Calm", "Emotional", "Melancholic", "Neutral"]
    static let genreBaseBPM: [String: Int] = [
        // Movie genres
        "Action": 78, "Adventure": 75, "Animation": 70, "Comedy": 72,
        "Crime": 76, "Documentary": 65, "Drama": 70, "Family": 70,
        "Fantasy": 73, "History": 68, "Horror": 85, "Music": 74,
        "Mystery": 76, "Romance": 68, "Science Fiction": 77,
        "TV Movie": 67, "Thriller": 80, "War": 74, "Western": 71,
        // TV show genres
        "Action & Adventure": 77, "Kids": 68, "Sci-Fi & Fantasy": 77,
        "Reality": 73, "News": 66, "Soap": 74, "Talk": 65,
        "War & Politics": 72
    ]
    
    // MARK: - ENCRYPT
    struct Encrypt {
        static let SECRET: String = ""
        static let IV: String = ""
    }
    
    // MARK: - NETWORK
    struct Network {
        static let HOST_URL: String = "https://api.themoviedb.org/3"
        static let HOST_LINK_URL: String = "https://thekight.link"
        static let APP_ID: String = ""
        static let APP_KEY: String = ""
        static let API_KEY: String = ""
        static let IMAGES_BASE_URL = "https://image.tmdb.org/t/p/"
        static let THUMBNAIL_YOUTUBE_URL = "https://img.youtube.com/vi/"
        static let THUMBNAIL_MAX_YOUTUBE = "/maxresdefault.jpg"
    }
    
    // MARK: - ADS
    struct ADS {
        static let HEIGHT_LARGE_ADS: CGFloat = 260
        static let HEIGHT_SMALL_ADS: CGFloat = 100
        static let WAIT_TIME_SHOW_INTERSTITIAL_AD = 6.0
        static let WAIT_TIME_SHOW_OPEN_AD = 4
        static let LOADING_ADS: String = "Loading ads"
        static let DEFAULT_OPEN_ADS = "01/01/2026"
        static let DEFAULT_JSON: String = "[]"
        
        enum AdUnit: String, CaseIterable {
            case openApp = "1"
            case interstitial = "2"
            case splashInterstitial = "3"
            case nativeAd = "4"
            case banner = "5"
        }
    }
    
    struct Config {
        static let MY_APP_ID: String = ""
        static let URL_POLICY: String = ""
        static let ABOUT_POLICY: String = ""
        static let EMAIL_FEEDBACK: String = ""
        static let SUBJECT_CONTENT: String = ""
        static let BODY_CONTENT: String = ""
        static let URL_SHARE_APP: String = "https://itunes.apple.com/us/app/myapp/id\(Config.MY_APP_ID)?ls=1&mt=8"
        static let COPY_RIGHT: String = ""
        
        // MARK: - Ads
        enum RemoteConfigKey: String {
            case adsOpenTime = "ADS_OPEN_TIME"
            case isShowFM = "isShowFM"
            case isShowRating = "isShowRating"
            case movieDiscover = "movie_discover"
            case tvDiscover = "tv_discover"
            case buttonDetail = "button_detail"
        }
    }
}
