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
}
