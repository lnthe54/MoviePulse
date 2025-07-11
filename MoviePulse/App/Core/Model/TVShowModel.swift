import Foundation

class TVShowObject: Codable {
    let id: Int
    let backdrop_path: String?
    let genre_ids: [Int]
    let name: String
    let popularity: Double
    let poster_path: String?
    let vote_average: Double
    let vote_count: Int
    let overview: String?
    let first_air_date: String?
    var isSelect: Bool?
    
    func getCategory() -> [String] {
        return CodableManager.shared.getTVCategories()
            .filter { genre_ids.contains($0.id) }
            .map { $0.name }
    }
}

extension TVShowObject {
    func releaseDate() -> String {
        String(self.first_air_date?.prefix(4) ?? "")
    }
}

struct TVShowContainerInfo: Codable {
    let results: [TVShowObject]
}

struct TVShowDetailInfo: Codable {
    var id: Int
    var backdropPath: String?
    var genres: [CategoryObject]
    var name: String
    var posterPath: String?
    var voteAverage: Double
    var numberOfSeasons: Int
    var firstAirDate: String
    var overView: String?
    var recommendations: RecommendationsTVShow
    var videos: VideosContainerInfo
    var credits: CreditsInfo
    var seasons: [SeasonObject]
    var reviews: ReviewContainer
    var images: ImageObject
    var countries: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case backdropPath = "backdrop_path"
        case genres = "genres"
        case posterPath = "poster_path"
        case voteAverage = "vote_average"
        case numberOfSeasons = "number_of_seasons"
        case firstAirDate = "first_air_date"
        case overView = "overview"
        case recommendations = "recommendations"
        case videos = "videos"
        case credits = "credits"
        case seasons = "seasons"
        case reviews = "reviews"
        case images = "images"
        case countries = "origin_country"
    }
    
    func releaseDate() -> String {
        String(self.firstAirDate.prefix(4))
    }
    
    static func empty() -> TVShowDetailInfo {
        return TVShowDetailInfo(id: 0,
                                backdropPath: "",
                                genres: [],
                                name: "",
                                posterPath: "",
                                voteAverage: 0,
                                numberOfSeasons: 0,
                                firstAirDate: "",
                                overView: "",
                                recommendations: RecommendationsTVShow(results: []),
                                videos: VideosContainerInfo(results: []),
                                credits: CreditsInfo(cast: [], crew: []),
                                seasons: [],
                                reviews: ReviewContainer(results: [], totalResults: 0),
                                images: ImageObject(backdrops: []),
                                countries: [])
    }
    
    func transformToInfoDetailObject() -> InfoDetailObject {
        return InfoDetailObject(
            id: self.id,
            backdrop_path: self.backdropPath,
            posterPath: self.posterPath,
            overview: self.overView,
            runtime: 0,
            releaseDate: self.releaseDate(),
            name: self.name,
            genres: self.genres,
            vote: self.voteAverage,
            recommendations: Utils.transformToInfoObject(tvShows: recommendations.results),
            credits: self.credits,
            videos: self.videos,
            reviews: self.reviews,
            numberOfSeasons: self.numberOfSeasons,
            seasons: self.seasons,
            movies: [],
            shows: [],
            type: .tv,
            images: images.backdrops
        )
    }
}

struct RecommendationsTVShow: Codable {
    var results: [TVShowObject]
}

// MARK: - Season
struct SeasonObject: Codable {
    var airDate: String?
    var episodeCount: Int
    var id: Int
    var name: String
    var overview: String
    var posterPath: String?
    var seasonNumber: Int
    var voteAverage: Double

    enum CodingKeys: String, CodingKey {
        case airDate = "air_date"
        case episodeCount = "episode_count"
        case id = "id"
        case name = "name"
        case overview = "overview"
        case posterPath = "poster_path"
        case seasonNumber = "season_number"
        case voteAverage = "vote_average"
    }
    
    func releaseDate() -> String {
        return self.airDate?
            .toDate(formatter: .fullTimeFromServer)
            .toString(formatter: .dayMonthYear)
        ?? ""
    }
}

// MARK: - SeasonInfo
struct SeasonInfo: Codable {
    let id: String
    let airDate: String?
    let episodes: [EpisodeInfo]
    let name: String
    let overview: String?
    let posterPath: String?
    let videos: VideosContainerInfo

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case airDate = "air_date"
        case episodes = "episodes"
        case name = "name"
        case overview = "overview"
        case posterPath = "poster_path"
        case videos = "videos"
    }
    
    static func empty() -> SeasonInfo {
        return SeasonInfo(id: "",
                          airDate: "",
                          episodes: [],
                          name: "",
                          overview: "",
                          posterPath: "",
                          videos: VideosContainerInfo(results: []))
    }
    
    func releaseDate() -> String {
        return self.airDate?
            .toDate(formatter: .fullTimeFromServer)
            .toString(formatter: .dayMonthYear)
        ?? ""
    }
    
    func releaseYear() -> String {
        String(self.airDate?.prefix(4) ?? "")
    }
}

// MARK: - Episode
struct EpisodeInfo: Codable {
    let airDate: String?
    let episodeNumber: Int
    let id: Int
    let name: String
    let overview: String?
    let productionCode: String
    let seasonNumber: Int
    let showID: Int
    let stillPath: String?
    let runtime: Int?
    
    enum CodingKeys: String, CodingKey {
        case airDate = "air_date"
        case episodeNumber = "episode_number"
        case id = "id"
        case name = "name"
        case overview = "overview"
        case productionCode = "production_code"
        case seasonNumber = "season_number"
        case showID = "show_id"
        case stillPath = "still_path"
        case runtime = "runtime"
    }
    
    func releaseDate() -> String {
        return self.airDate?
            .toDate(formatter: .fullTimeFromServer)
            .toString(formatter: .dayMonthYear)
        ?? ""
    }
}
