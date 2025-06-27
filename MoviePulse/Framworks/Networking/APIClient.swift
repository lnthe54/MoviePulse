import Alamofire
import RxSwift
import CryptoSwift

class APIClient {
    
    static let sessionManagerWithoutAuthentication: Session = {
        let configuration = URLSessionConfiguration.af.default
        configuration.timeoutIntervalForRequest = 30
        configuration.waitsForConnectivity = true
        let networkLogger = NetworkLogger()
        return Session(configuration: configuration, eventMonitors: [networkLogger])
    }()
    
    // MARK: - Executador de requests
    static func request<T: Codable> (_ urlConvertible: URLRequestConvertible) -> Observable<T> {
        return Observable<T>.create { observer in
            
            sessionManagerWithoutAuthentication.request(urlConvertible).responseDecodable { (response: AFDataResponse<T>) in
                switch response.result {
                case .success(let value):
                    observer.onNext(value)
                    observer.onCompleted()
                    
                case .failure(let error):
                    let apiError = mapAPIError(statusCode: response.response?.statusCode, error: error)
                    observer.onError(apiError)
                }
            }
            
            return Disposables.create {}
        }
    }
    
    static func requestEncrypt<T: Codable>(_ urlConvertible: URLRequestConvertible) -> Observable<T> {
        return Observable<T>.create { observer in
            
            sessionManagerWithoutAuthentication.request(urlConvertible).responseData { (response: AFDataResponse<Data>) in
                switch response.result {
                case .success(let data):
                    do {
                        let aes = try AES(key: Array(Constants.Encrypt.SECRET.utf8),
                                          blockMode: CBC(iv: Array(Constants.Encrypt.IV.utf8)),
                                          padding: .pkcs5)
                        
                        let stringEncoded: String = String(data: data, encoding: .utf8) ?? ""
                        let dataEncoded = Data(base64Encoded: stringEncoded)
                        
                        guard let data = dataEncoded else {
                            observer.onError(APIError.noContent)
                            return
                        }
                        
                        let decryptedData = try aes.decrypt(data.bytes)
                        let dataDecoded = Data(decryptedData)
                        let stringDecoded = String(data: dataDecoded, encoding: .utf8) ?? ""
                        
                        let decodedData = try JSONDecoder().decode(T.self, from: Data(stringDecoded.utf8))
                        
                        observer.onNext(decodedData)
                        observer.onCompleted()
                    } catch _ {
                        observer.onError(APIError.noContent)
                    }
                    
                case .failure(let error):
                    let apiError = mapAPIError(statusCode: response.response?.statusCode, error: error)
                    observer.onError(apiError)
                }
            }
            
            return Disposables.create {}
        }
    }
    
    private static func mapAPIError(statusCode: Int?, error: Error) -> APIError {
        switch statusCode {
        case 204:
            return APIError.noContent
        case 400:
            return APIError.badRequest
        case 401:
            return APIError.unauthorized
        case 403:
            return APIError.forbidden
        case 404:
            return APIError.notFound
        case 405:
            return APIError.noAllowed
        case 409:
            return APIError.conflict
        case 500:
            return APIError.internalServerError
        default:
            return APIError.unknown(error)
        }
    }
}
