import Foundation
import Alamofire

enum MovieRouter: APIConfiguration {
    
    case topRate(page: Int)
    case comming(page: Int)
    case nowplaying(page: Int)
    case popular(page: Int, categoryId: Int)
    case category
    case detail(id: Int)
    case link(name: String)
    case movies(categoryId: Int, page: Int)
    case other(query: String, page: Int)
    case trending(page: Int)
    case discover(request: DiscoverMovieRequest)
    
    var hostURL: String {
        switch self {
        case .link(_):
            return Constants.Network.HOST_LINK_URL
            
        default:
            return Constants.Network.HOST_URL
        }
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var path: String {
        switch self {
        case .topRate:
            return "/movie/top_rated"
            
        case .comming:
            return "/movie/upcoming"
            
        case .nowplaying:
            return "/movie/now_playing"
            
        case .popular:
            return "/movie/popular"
            
        case .category:
            return "/genre/movie/list"
            
        case .detail(let id):
            return "/movie/\(id)"
            
        case .link(_):
            return "/encrypt/movie"
            
        case .movies, .other:
            return "/discover/movie"
            
        case .trending:
            return "/trending/movie/day"
            
        case .discover:
            return "/discover/movie"
        }
    }
    
    var requestParams: APIRequestParams? {
        switch self {
        case .topRate(let page):
            return getCommonParams(page: page)
            
        case .comming(let page):
            return getCommonParams(page: page)
            
        case .nowplaying(let page):
            return getCommonParams(page: page)
            
        case .popular(let page, let categoryId):
            return getCommonParams(page: page, categoryID: categoryId)
            
        case .category:
            return getCommonParams()
            
        case .detail(_):
            let params: [String: Any] = [
                "api_key": Constants.Network.API_KEY,
                "append_to_response": "videos,credits,recommendations,reviews,images"
            ]
            return .query(params)
            
        case .link(let name):
            let params: [String: Any] = [
                "appId": Constants.Network.APP_ID,
                "name": name
            ]
            return .query(params)
            
        case .movies(let categoryId, let page):
            return getCommonParams(page: page, categoryID: categoryId)
            
        case .other(let query, let page):
            var params = getParams(formQuery: query)
            params["api_key"] = Constants.Network.API_KEY
            params["page"] = page
            return .query(params)
            
        case .trending(let page):
            return getCommonParams(page: page)
            
        case .discover(let request):
            var params: [String: Any] = [
                "api_key": Constants.Network.API_KEY,
                "page": request.page
            ]
            
            if !request.genres.isEmpty {
                params["with_genres"] = request.genres.map { String($0) }.joined(separator: ",")
            }
            if let sortBy = request.sortBy {
                params["sort_by"] = sortBy
            }
            
            if let voteAverageGTE = request.voteAverageGTE {
                params["vote_average.gte"] = voteAverageGTE
            }
            if let voteAverageLTE = request.voteAverageLTE {
                params["vote_average.lte"] = voteAverageLTE
            }
            if let voteCountLTE = request.voteCountLTE {
                params["vote_count.lte"] = voteCountLTE
            }
            if let releaseDateGTE = request.releaseDateGTE {
                params["release_date.gte"] = releaseDateGTE
            }
            if let releaseDateLTE = request.releaseDateLTE {
                params["release_date.lte"] = releaseDateLTE
            }
            
            return .query(params)
        }
    }
}

struct DiscoverMovieRequest {
    var genres: [Int] = []
    var sortBy: String? = nil
    var voteCountLTE: Int? = nil
    var voteAverageGTE: Double? = nil
    var voteAverageLTE: Double? = nil
    var releaseDateGTE: String? = nil
    var releaseDateLTE: String? = nil
    var page: Int = 1
}

extension DiscoverMovieRequest {
    static func from(emotion: EmotionType, page: Int) -> DiscoverMovieRequest? {
        switch emotion {
        case .excited:
            return DiscoverMovieRequest(genres: [28, 12], sortBy: "vote_average.asc", voteCountLTE: 3000, page: page)
        case .nostalgic:
            return DiscoverMovieRequest(genres: [16, 10751], sortBy: "release_date.asc", voteCountLTE: 2000, page: page)
        case .tense:
            return DiscoverMovieRequest(genres: [53, 80], sortBy: "vote_average.asc", voteCountLTE: 3000, page: page)
        case .scared:
            return DiscoverMovieRequest(genres: [27], sortBy: "popularity.desc", voteCountLTE: 2000, voteAverageLTE: 6.5, page: page)
        case .calm:
            return DiscoverMovieRequest(genres: [10749, 18], sortBy: "vote_average.asc", voteCountLTE: 3000, page: page)
        case .emotional:
            return DiscoverMovieRequest(genres: [18, 10402], sortBy: "vote_average.desc", voteCountLTE: 3000, page: page)
        case .melancholic:
            return DiscoverMovieRequest(genres: [18, 36], sortBy: "release_date.asc", voteCountLTE: 2000, page: page)
        case .neutral:
            return DiscoverMovieRequest(genres: [99], voteAverageGTE: 5.5, voteAverageLTE: 6.5, page: page)
        }
    }
}
