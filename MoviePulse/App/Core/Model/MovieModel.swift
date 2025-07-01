import Foundation

struct MovieObject: Codable {
    let id: Int
    let title: String?
    let original_title: String?
    let overview: String
    let backdrop_path: String?
    let poster_path: String?
    let vote_average: Double
    let vote_count: Int
    let genre_ids: [Int]
    let release_date: String?
}

extension MovieObject {
    static func empty() -> MovieObject {
        return MovieObject(id: 0,
                           title: "",
                           original_title: "",
                           overview: "",
                           backdrop_path: "",
                           poster_path: "",
                           vote_average: 0,
                           vote_count: 0,
                           genre_ids: [],
                           release_date: ""
        )
    }
    
    func releaseDate() -> String {
        String(self.release_date?.prefix(4) ?? "")
    }
    
    func getCategory() -> [String] {
        return CodableManager.shared.getMovieCategories()
            .filter { genre_ids.contains($0.id) }
            .map { $0.name }
    }
}

struct MovieContainerInfo: Codable {
    let results: [MovieObject]
}

struct MovieDetailInfo: Codable {
    let id: Int
    let backdrop_path: String?
    let poster_path: String?
    let overview: String?
    let runtime: Int
    let release_date: String
    let original_title: String
    let genres: [CategoryObject]
    let vote_average: Double
    let recommendations: RecommendationsInfo
    let credits: CreditsInfo
    let videos: VideosContainerInfo
    let budget: Double
    let reviews: ReviewContainer
    let images: ImageObject
    let origin_country: [String]?
    
    static func empty() -> MovieDetailInfo {
        return MovieDetailInfo(id: 0,
                               backdrop_path: "",
                               poster_path: "",
                               overview: "",
                               runtime: 0,
                               release_date: "",
                               original_title: "",
                               genres: [],
                               vote_average: 0,
                               recommendations: RecommendationsInfo(results: []),
                               credits: CreditsInfo(cast: [], crew: []),
                               videos: VideosContainerInfo(results: []),
                               budget: 0,
                               reviews: ReviewContainer(results: [], totalResults: 0),
                               images: ImageObject(backdrops: []),
                               origin_country: [])
    }
    
    func releaseDate() -> String {
        String(self.release_date.prefix(4))
    }
    
    func transformToInfoDetailObject() -> InfoDetailObject {
        return InfoDetailObject(
            id: self.id,
            backdrop_path: self.backdrop_path,
            posterPath: self.poster_path,
            overview: self.overview,
            runtime: self.runtime,
            releaseDate: self.releaseDate(),
            name: self.original_title,
            genres: self.genres,
            vote: self.vote_average,
            recommendations: Utils.transformToInfoObject(movies: self.recommendations.results),
            credits: self.credits,
            videos: self.videos,
            reviews: self.reviews,
            numberOfSeasons: 0,
            seasons: [],
            movies: [],
            shows: [],
            type: .movie,
            images: images.backdrops
        )
    }
}

struct RecommendationsInfo: Codable {
    let results: [MovieObject]
}

struct VideosContainerInfo: Codable {
    let results: [VideoInfo]
}

struct VideoInfo: Codable {
    let id: String
    let name: String
    let key: String
    let published_at: String
    
    var publishedDate: String {
        published_at.toDate(formatter: .fullTimeFromServer).toString(formatter: .dayMonthYear) ?? ""
    }
}

struct CreditsInfo: Codable {
    let cast: [CastInfo]
    let crew: [CastInfo]
}

struct CastInfo: Codable {
    let id: Int
    let name: String
    let profile_path: String?
    
    func transformToInfoObject() -> InfoObject {
        return InfoObject(
            id: self.id,
            name: self.name,
            path: self.profile_path,
            releaseDate: "",
            categories: [],
            vote: 0,
            department: "",
            type: .actor
        )
    }
}

// MARK: - ReviewContainer
struct ReviewContainer: Codable {
    var results: [ReviewObject]
    var totalResults: Int
    
    enum CodingKeys: String, CodingKey {
        case results = "results"
        case totalResults = "total_results"
    }
}

// MARK: - Result
struct ReviewObject: Codable {
    var author: String
    var authorDetails: AuthorDetailsObject
    var content: String
    var createdAt: String
    var id: String
    var updatedAt: String
    var url: String

    enum CodingKeys: String, CodingKey {
        case author = "author"
        case authorDetails = "author_details"
        case content = "content"
        case createdAt = "created_at"
        case id = "id"
        case updatedAt = "updated_at"
        case url = "url"
    }
}

// MARK: - AuthorDetails
struct AuthorDetailsObject: Codable {
    var name: String
    var username: String
    var avatarPath: String?
    var rating: Int?

    enum CodingKeys: String, CodingKey {
        case name = "name"
        case username = "username"
        case avatarPath = "avatar_path"
        case rating = "rating"
    }
}

// MARK: - Images
struct ImageObject: Codable {
    var backdrops: [BackdropObject]

    enum CodingKeys: String, CodingKey {
        case backdrops = "backdrops"
    }
}

// MARK: - Backdrop
struct BackdropObject: Codable {
    var filePath: String

    enum CodingKeys: String, CodingKey {
        case filePath = "file_path"
    }
}

struct InfoObject: Codable {
    let id: Int
    let name: String?
    let path: String?
    let releaseDate: String?
    let categories: [String]
    let vote: Double?
    let department: String?
    let type: ObjectType?
}

class InfoDetailObject: Codable {
    let id: Int
    let backdrop_path: String?
    let posterPath: String?
    let overview: String?
    let runtime: Int?
    let releaseDate: String
    let name: String
    let genres: [CategoryObject]
    let vote: Double?
    let recommendations: [InfoObject]
    let credits: CreditsInfo?
    let videos: VideosContainerInfo?
    let reviews: ReviewContainer?
    let numberOfSeasons: Int
    let seasons: [SeasonObject]
    let movies: [InfoObject]
    let shows: [InfoObject]
    let type: ObjectType
    let place: String?
    let images: [BackdropObject]
    
    init(id: Int, backdrop_path: String?, posterPath: String?, overview: String?, runtime: Int?, releaseDate: String, name: String, genres: [CategoryObject], vote: Double?, recommendations: [InfoObject], credits: CreditsInfo?, videos: VideosContainerInfo?, reviews: ReviewContainer?, numberOfSeasons: Int, seasons: [SeasonObject], movies: [InfoObject], shows: [InfoObject], type: ObjectType, place: String? = nil, images:  [BackdropObject] = []) {
        self.id = id
        self.backdrop_path = backdrop_path
        self.posterPath = posterPath
        self.overview = overview
        self.runtime = runtime
        self.releaseDate = releaseDate
        self.name = name
        self.genres = genres
        self.vote = vote
        self.recommendations = recommendations
        self.credits = credits
        self.videos = videos
        self.reviews = reviews
        self.numberOfSeasons = numberOfSeasons
        self.seasons = seasons
        self.movies = movies
        self.shows = shows
        self.type = type
        self.place = place
        self.images = images
    }
    
    static func empty() -> InfoDetailObject {
        return InfoDetailObject(
            id: 0,
            backdrop_path: nil,
            posterPath: nil,
            overview: nil,
            runtime: 0,
            releaseDate: "",
            name: "",
            genres: [],
            vote: 0,
            recommendations: [],
            credits: nil,
            videos: nil,
            reviews: nil,
            numberOfSeasons: 0,
            seasons: [],
            movies: [],
            shows: [],
            type: .movie
        )
    }
    
    func transformToInfoObject() -> InfoObject {
        return InfoObject(
            id: self.id,
            name: self.name,
            path: self.posterPath,
            releaseDate: self.releaseDate,
            categories: [],
            vote: self.vote,
            department: nil,
            type: self.type
        )
    }
}
