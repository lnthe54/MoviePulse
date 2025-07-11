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
        }
    }
}
