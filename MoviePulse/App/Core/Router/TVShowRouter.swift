import Alamofire

enum TVShowRouter: APIConfiguration {
    
    case popular(page: Int)
    
    case topRate(page: Int)
    
    case onAir(page: Int)
    
    case lastest(page: Int)
    
    case withCategory(id: Int, page: Int)
    
    case detail(id: Int)
    
    case seasons(idTVShow: Int, index: Any)
    
    case link(name: String, seasonName: String, episcode: Int)
    
    case other(query: String, page: Int)
    
    case category
    
    var hostURL: String {
        switch self {
        case .link(_, _, _):
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
        case .popular:
            return "tv/popular"
            
        case .topRate:
            return "tv/top_rated"
            
        case .onAir:
            return "tv/on_the_air"
            
        case .lastest:
            return "tv/airing_today"
            
        case .withCategory, .other:
            return "discover/tv"
            
        case .detail(let id):
            return "tv/\(id)"
            
        case .seasons(let idTVShow, let index):
            return "tv/\(idTVShow)/season/\(index)"
            
        case .link(_, _, _):
            return "/encrypt/series"
            
        case .category:
            return "/genre/tv/list"
        }
    }
    
    var requestParams: APIRequestParams? {
        switch self {
        case .popular(let page):
            return getCommonParams(page: page)
            
        case .topRate(let page):
            return getCommonParams(page: page)
            
        case .onAir(let page):
            return getCommonParams(page: page)
            
        case .lastest(let page):
            return getCommonParams(page: page)
            
        case .withCategory(let id, let page):
            return getCommonParams(page: page, categoryID: id)
            
        case .detail:
            let params: [String: Any] = [
                "api_key": Constants.Network.API_KEY,
                "language": "en-US",
                "append_to_response": "videos,credits,recommendations,images,reviews"
            ]
            return .query(params)
            
        case .seasons:
            let params: [String: Any] = [
                "api_key": Constants.Network.API_KEY,
                "language": "en-US",
                "append_to_response": "videos,credits,recommendations,images,reviews"
            ]
            return .query(params)
            
        case .link(let name, let seasonName, let episcode):
            let params: [String: Any] = [
                "appId": Constants.Network.APP_ID,
                "name": name + " - " + seasonName,
                "episode": episcode
            ]
            return .query(params)
            
        case .other(let query, let page):
            var params = getParams(formQuery: query)
            params["api_key"] = Constants.Network.API_KEY
            params["page"] = page
            return .query(params)
            
        case .category:
            return getCommonParams()
        }
    }
}
