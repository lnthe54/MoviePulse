struct APIResponse<T: Codable>: Codable {
    let result: Bool
    
    let code: Int
    
    let message: String
    
    let data: T?
    
    let pagination: PageResponse?
}

struct PageResponse: Codable {
    let page: Int
    
    let totalPage: Int
    
    let totalRecord: Int
}
