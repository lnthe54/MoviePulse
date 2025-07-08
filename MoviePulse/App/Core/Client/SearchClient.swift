import RxSwift

protocol SearchService {
    func searchMovie(by query: String, page: Int) -> Observable<MovieContainerInfo>
    func searchTV(by query: String, page: Int) -> Observable<TVShowContainerInfo>
}

class SearchClient: SearchService {
    
    func searchMovie(by query: String, page: Int) -> Observable<MovieContainerInfo> {
        APIClient.request(SearchRouter.movies(key: query, page: page))
    }
    
    func searchTV(by query: String, page: Int) -> Observable<TVShowContainerInfo> {
        APIClient.request(SearchRouter.tvShows(key: query, page: page))
    }
}
