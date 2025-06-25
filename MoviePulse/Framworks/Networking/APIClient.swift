import Alamofire
import RxSwift

class APIClient {
    
    // MARK: - Session without authen
    private static let unauthenticatedSession: Session = {
        let configuration = URLSessionConfiguration.af.default
        configuration.timeoutIntervalForRequest = 30
        configuration.waitsForConnectivity = true
        
        return Session(
            configuration: configuration,
            eventMonitors: [NetworkLogger()]
        )
    }()
    
    // MARK: - Session authen
    private static var authenticatedSession: Session = {
        let configuration = URLSessionConfiguration.af.default
        configuration.timeoutIntervalForRequest = 30
        configuration.waitsForConnectivity = true
        
//        let tokenProvider = { TokenStorage.shared.accessToken }
//        let interceptor = AuthInterceptor(tokenProvider: tokenProvider)
        
        return Session(
            configuration: configuration,
//            interceptor: interceptor,
            eventMonitors: [NetworkLogger()]
        )
    }()
    
    static func unauthRequest<T: Codable>(_ urlConvertible: URLRequestConvertible) -> Observable<T> {
        return performRequest(session: unauthenticatedSession, urlConvertible: urlConvertible)
    }
    
    static func authRequest<T: Codable>(_ urlConvertible: URLRequestConvertible) -> Observable<T> {
        return performRequest(session: authenticatedSession, urlConvertible: urlConvertible)
    }
    
    static func encryptRequest<T: Codable>(_ urlConvertible: URLRequestConvertible) -> Observable<T> {
        return performEncryptRequest(session: unauthenticatedSession, urlConvertible: urlConvertible)
    }
    
    private static func performRequest<T: Codable>(session: Session, urlConvertible: URLRequestConvertible) -> Observable<T> {
        return Observable.create { observer in
            session.request(urlConvertible)
                .responseData { response in
                    let statusCode = response.response?.statusCode ?? -1
                    
                    switch response.result {
                    case .success(let data):
                        do {
                            let apiResponse = try JSONDecoder().decode(APIResponse<T>.self, from: data)
                            
                            if !apiResponse.result {
                                observer.onError(APIError.server(
                                    message: apiResponse.message,
                                    code: apiResponse.code
                                ))
                                return
                            }
                            
                            guard let data = apiResponse.data else {
                                observer.onError(APIError.noContent)
                                return
                            }
                            
                            observer.onNext(data)
                            observer.onCompleted()
                        } catch {
                            let mappedError = mapStatusCodeToAPIError(statusCode) ?? APIError.decodingError(error)
                            observer.onError(mappedError)
                        }
                        
                    case .failure(let error):
                        let mappedError = mapStatusCodeToAPIError(statusCode) ?? APIError.unknown(error)
                        observer.onError(mappedError)
                    }
                }
            return Disposables.create()
        }
    }
    
    private static func performEncryptRequest<T: Codable>(session: Session, urlConvertible: URLRequestConvertible) -> Observable<T> {
        return Observable.create { observer in
            session.request(urlConvertible)
                .responseData { response in
                    let statusCode = response.response?.statusCode ?? -1
                    
                    switch response.result {
                    case .success(let data):
                        do {
                            let apiResponse = try JSONDecoder().decode(APIResponse<T>.self, from: data)
                            
                            if !apiResponse.result {
                                observer.onError(APIError.server(
                                    message: apiResponse.message,
                                    code: apiResponse.code
                                ))
                                return
                            }
                            
                            guard let data = apiResponse.data else {
                                observer.onError(APIError.noContent)
                                return
                            }
                            
                            observer.onNext(data)
                            observer.onCompleted()
                        } catch {
                            let mappedError = mapStatusCodeToAPIError(statusCode) ?? APIError.decodingError(error)
                            observer.onError(mappedError)
                        }
                        
                    case .failure(let error):
                        let mappedError = mapStatusCodeToAPIError(statusCode) ?? APIError.unknown(error)
                        observer.onError(mappedError)
                    }
                }
            return Disposables.create()
        }
    }
    
    private static func mapStatusCodeToAPIError(_ statusCode: Int) -> APIError? {
        switch statusCode {
        case 204: return .noContent
        case 400: return .badRequest
        case 401: return .unauthorized
        case 403: return .forbidden
        case 404: return .notFound
        case 405: return .noAllowed
        case 409: return .conflict
        case 500: return .internalServerError
        default: return nil
        }
    }
}
