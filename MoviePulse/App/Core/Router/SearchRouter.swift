import Alamofire

enum SearchRouter: APIConfiguration {
    
    case movies(key: String, page: Int)
    
    case tvShows(key: String, page: Int)
        
    var hostURL: String {
        return Constants.Network.HOST_URL
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var path: String {
        switch self {
        case .movies:
            return "/search/movie"
            
        case .tvShows:
            return "/search/tv"
        }
    }
    
    var requestParams: APIRequestParams? {
        switch self {
        case .movies(let query, let page):
            return getParams(query, page: page)
            
        case .tvShows(let query, let page):
            return getParams(query, page: page)
        }
    }
    
    private func getParams(_ query: String, page: Int) -> APIRequestParams {
        let params: [String: Any] = [
            "api_key": Constants.Network.API_KEY,
            "language": "en-US",
            "query": query,
            "page": page
        ]
        
        return .query(params)
    }
}
