import Alamofire

protocol APIConfiguration: URLRequestConvertible {
    var hostURL: String { get }
    var method: HTTPMethod { get }
    var path: String { get }
    var requestParams: APIRequestParams? { get }
}

extension APIConfiguration {
    func asURLRequest() throws -> URLRequest {
        var urlComponents = URLComponents(string: hostURL + "/" + path)
        
        // Handle query parameters
        switch requestParams {
        case .query(let query), .queryAndBody(let query, _):
            if !query.isEmpty {
                urlComponents?.queryItems = query.map {
                    URLQueryItem(name: $0.key, value: "\($0.value)")
                }
            }
        default:
            break
        }
        
        guard let finalURL = urlComponents?.url else {
            throw AFError.invalidURL(url: hostURL + "/" + path)
        }
        
        var urlRequest = URLRequest(url: finalURL)
        urlRequest.httpMethod = method.rawValue
        
        urlRequest.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.acceptType.rawValue)
        urlRequest.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.contentType.rawValue)
        
        // Encode body
        switch requestParams {
        case .body(let body), .queryAndBody(_, let body):
            if method != .get && method != .delete {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            }
        default:
            break
        }
        
        return urlRequest
    }
}

enum HTTPHeaderField: String {
    case authentication = "Authorization"
    case contentType = "Content-Type"
    case acceptType = "Accept"
    case acceptEncoding = "Accept-Encoding"
    case string = "String"
}

enum ContentType: String {
    case json = "application/json"
    case formEncode = "application/x-www-form-urlencoded"
}

enum APIRequestParams {
    case query(_ params: Parameters)
    case body(_ params: Parameters)
    case queryAndBody(query: Parameters, body: Parameters)
}

enum APIError: Error {
    case noContent
    case badRequest
    case unauthorized
    case forbidden
    case notFound
    case noAllowed
    case conflict
    case internalServerError
    case server(message: String, code: Int)
    case unknown(Error)
    case decodingError(Error)
}

struct APIErrorHandler {
    static func message(for error: Error) -> String {
        guard let apiError = error as? APIError else {
            return error.localizedDescription
        }
        
        switch apiError {
        case .server(let msg, _):
            return msg
        case .unauthorized:
            return "Session expired! Please log in again."
        case .notFound:
            return "Resource not found."
        case .badRequest:
            return "Bad request. Please check your input."
        case .unknown(let err):
            return "Unknown error: \(err.localizedDescription)"
        case .decodingError(let err):
            return "Decoding error: \(err.localizedDescription)"
        case .internalServerError:
            return "Internal server error. Please try again later."
        case .noAllowed:
            return "Method not allowed."
        case .noContent:
            return "No content available."
        case .conflict:
            return "Conflict occurred. Try again."
        case .forbidden:
            return "Session expired! Please log in again."
        }
    }
}
