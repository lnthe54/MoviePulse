import UIKit

struct Utils {
    
    // MARK: - Get URL from Back drop Path
    static func getBackDropPath(_ path: String? = nil, size: BackDropSize = .w780) -> String  {
        return getURL(fromPath: path, size: size.rawValue)
    }
    
    // MARK: - Get URL from Poster Path
    static func getPosterPath(_ path: String? = nil, size: PosterSize = .w342) -> String  {
        return getURL(fromPath: path, size: size.rawValue)
    }
    
    // MARK: - Get URL from Profile Path
    static func getProfilePath(_ path: String? = nil, size: ProfileSize = .w185) -> String  {
        return getURL(fromPath: path, size: size.rawValue)
    }
    
    private static func getURL(fromPath path: String? = nil, size: String) -> String {
        if let path = path {
            return Constants.Network.IMAGES_BASE_URL + "/\(size)" + path
        } else {
            return ""
        }
    }
    
    static func getCategoryString(from categories: [CategoryObject], separator: String) -> String {
        let names: [String] = categories.map({ return $0.name })
        return names.joined(separator: separator)
    }
    
    static func getNameCategories(from categories: [CategoryObject], jonined char: String = "  •  ") -> String {
        return categories.map { $0.name }.joined(separator: "\(char)")
    }
    
    static func getNameMovieCategories(ids: [Int],
                                       categories: [CategoryObject],
                                       joined char: String = "  •  ") -> String {
        var listName: [String] = []
        for category in categories {
            for id in ids where id == category.id {
                listName.append(category.name)
            }
        }
        
        return listName.joined(separator: char)
    }
    
    static func getNameTVCategories(from categories: [CategoryObject]) -> String {
        return categories.map { $0.name }.joined(separator: "  •  ")
    }
    
    static func open(with url: URL) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    static func openYoutube(with key: String) {
        guard let youtubeURL = URL(string: "youtube://\(key)") else { return }
        
        if UIApplication.shared.canOpenURL(youtubeURL) {
            Utils.open(with: youtubeURL)
        } else{
            guard let youtubeURL = URL(string:"https://www.youtube.com/watch?v=\(key)") else { return }
            Utils.open(with: youtubeURL)
        }
    }
    
    /**
     Convert Movieobject > InforObject
     */
    static func transformToInfoObject(movies: [MovieObject]) -> [InfoObject] {
        return movies.map { movie in
            return InfoObject(
                id: movie.id,
                name: movie.title,
                path: movie.poster_path,
                releaseDate: movie.releaseDate(),
                categories: movie.getCategory(),
                vote: movie.vote_average,
                department: nil,
                type: .movie
            )
        }
    }
    
    /**
     Convert TVShowObject > InforObject
     */
    static func transformToInfoObject(tvShows: [TVShowObject]) -> [InfoObject] {
        return tvShows.map { tvShow in
            return InfoObject(
                id: tvShow.id,
                name: tvShow.name,
                path: tvShow.poster_path,
                releaseDate: tvShow.releaseDate(),
                categories: tvShow.getCategory(),
                vote: tvShow.vote_average,
                department: nil,
                type: .tv
            )
        }
    }
    
    /**
     Convert ActorInfo > InfoObject
     */
    static func transformToInfoObject(actors: [ActorInfo]) -> [InfoObject] {
        return actors.map { actor in
            return InfoObject(
                id: actor.id,
                name: actor.name,
                path: actor.profile_path,
                releaseDate: nil,
                categories: [],
                vote: 0,
                department: actor.known_for_department,
                type: .actor
            )
        }
    }
    
    static func transformToInfoObject(casts: [CastInfo]) -> [InfoObject] {
        return casts.map { $0.transformToInfoObject() }
    }
  
    /**
     Convert Actor Info > CastInfo
     */
    static func trasnformToCastInfo(actors: [ActorInfo]) -> [CastInfo] {
        return actors.map { actor in
            return CastInfo(id: actor.id, name: actor.name, profile_path: actor.profile_path)
        }
    }
    
    static func createEmailUrl(to: String, subject: String, body: String) -> URL? {
        let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let bodyEncoded = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        let gmailUrl = URL(string: "googlegmail://co?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let outlookUrl = URL(string: "ms-outlook://compose?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let yahooMail = URL(string: "ymail://mail/compose?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let sparkUrl = URL(string: "readdle-spark://compose?recipient=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let defaultUrl = URL(string: "mailto:\(to)?subject=\(subjectEncoded)&body=\(bodyEncoded)")
        
        if let gmailUrl = gmailUrl, UIApplication.shared.canOpenURL(gmailUrl) {
            return gmailUrl
        } else if let outlookUrl = outlookUrl, UIApplication.shared.canOpenURL(outlookUrl) {
            return outlookUrl
        } else if let yahooMail = yahooMail, UIApplication.shared.canOpenURL(yahooMail) {
            return yahooMail
        } else if let sparkUrl = sparkUrl, UIApplication.shared.canOpenURL(sparkUrl) {
            return sparkUrl
        }
        
        return defaultUrl
    }
    
    static func getAvgPluse(withGenre genre: String, voteAvg: Double) -> Int {
        let baseBPM = Constants.genreBaseBPM[genre] ?? 72
        let ratingInfluence = Int((voteAvg - 5.0) * 2.5)
        let noise = Int.random(in: -5...5)

        return baseBPM + ratingInfluence + noise
    }
    
    static func emotionPercentages(for avgPulse: Int) -> [String: Int] {
        switch avgPulse {
        case 90...:
            return ["Tense": 38, "Excited": 30, "Emotional": 20, "Calm": 7, "Neutral": 5]
        case 80..<90:
            return ["Excited": 30, "Tense": 28, "Emotional": 20, "Calm": 12, "Neutral": 10]
        case 70..<80:
            return ["Calm": 35, "Nostalgic": 25, "Neutral": 20, "Emotional": 15, "Excited": 5]
        case ..<70:
            return ["Neutral": 40, "Calm": 30, "Emotional": 20, "Tense": 5, "Excited": 5]
        default:
            return ["Neutral": 100]
        }
    }
    
    // MARK: - Energy Calculation
    /// Calculates energy level based on BPM.
    /// - Parameter bpm: Beats per minute.
    /// - Returns: A string representing the energy level.
    static func calculateEnergy(from bpm: Int) -> String {
        switch bpm {
        case ..<65: return "Low"
        case 65..<75: return "Moderate"
        case 75..<90: return "High"
        default: return "Very High"
        }
    }

    // MARK: - Emotion Detection
    /// Detects emotion based on BPM.
    /// - Parameter bpm: Beats per minute.
    /// - Returns: A string representing the detected emotion.
    static func detectEmotion(from bpm: Int) -> String {
        let rng = Int.random(in: 0..<100)

        switch bpm {
        case ..<65:
            return rng < 60 ? "Calm" : "Melancholic"
        case 65..<75:
            return rng < 50 ? "Nostalgic" : "Emotional"
        case 75..<85:
            return rng < 60 ? "Excited" : "Tense"
        case 85...:
            return rng < 70 ? "Tense" : "Scared"
        default:
            return "Neutral"
        }
    }
    
    // MARK: - Tension Detection
    /// Detects tension level based on BPM.
    /// - Parameter bpm: Beats per minute.
    /// - Returns: A string representing the detected tension level.
    static func getInfoMessage(from bpm: Int) -> String {
        switch bpm {
        case ..<69:
            return "Slightly low. Stay relaxed."
        case 69..<99:
            return "Normal range. Nothing to worry about!"
        default:
            return "High. Consider slowing down."
        }
    }
    
    // MARK: - Date Comparison
    static func isSameDay(from date: Date) -> Bool {
        return Calendar.current.isDate(date, inSameDayAs: Date())
    }
    
    static func filterThisWeek(from results: [PulseResultInfo]) -> [PulseResultInfo] {
        let calendar = Calendar.current
        let now = Date()
        let currentYear = calendar.component(.yearForWeekOfYear, from: now)
        let currentWeek = calendar.component(.weekOfYear, from: now)

        return results.filter {
            let year = calendar.component(.yearForWeekOfYear, from: $0.date)
            let week = calendar.component(.weekOfYear, from: $0.date)
            return year == currentYear && week == currentWeek
        }
    }
}
