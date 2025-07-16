import Foundation
import RxSwift

protocol MovieServices {
    func getMovieTopRate(at page: Int) -> Observable<MovieContainerInfo>
    func getMovieUpComing(at page: Int) -> Observable<MovieContainerInfo>
    func getMovieNowPlaying(at page: Int) -> Observable<MovieContainerInfo>
    func getMoviePopular(at page: Int, categoryId: Int) -> Observable<MovieContainerInfo>
    func getMovieCategories() -> Observable<CategoryContainer>
    func getMovieDetail(_ id: Int) -> Observable<MovieDetailInfo>
    func getMovies(by categoryId: Int, page: Int) -> Observable<MovieContainerInfo>
    func getFM(name: String) -> Observable<LinkContainer>
    func getDiscover(query: String, page: Int) -> Observable<MovieContainerInfo>
    func getTrending(at page: Int) -> Observable<MovieContainerInfo>
    func getDiscover(request: DiscoverMovieRequest) -> Observable<MovieContainerInfo>
}

class MovieClient: MovieServices {
    
    func getMovieTopRate(at page: Int) -> Observable<MovieContainerInfo> {
        movieRequest(router: .topRate(page: page))
    }
    
    func getMovieUpComing(at page: Int) -> Observable<MovieContainerInfo> {
        movieRequest(router: .comming(page: page))
    }
    
    func getMovieNowPlaying(at page: Int) -> Observable<MovieContainerInfo> {
        movieRequest(router: .nowplaying(page: page))
    }
    
    func getMoviePopular(at page: Int, categoryId: Int) -> Observable<MovieContainerInfo> {
        movieRequest(router: .popular(page: page, categoryId: categoryId))
    }
    
    func getMovieCategories() -> Observable<CategoryContainer> {
        movieRequest(router: .category)
    }
    
    func getMovieDetail(_ id: Int) -> Observable<MovieDetailInfo> {
        movieRequest(router: .detail(id: id))
    }
    
    func getMovies(by categoryId: Int, page: Int) -> Observable<MovieContainerInfo> {
        movieRequest(router: .movies(categoryId: categoryId, page: page))
    }
    
    func getFM(name: String) -> Observable<LinkContainer> {
        APIClient.requestEncrypt(MovieRouter.link(name: name))
    }
    
    func getDiscover(query: String, page: Int) -> Observable<MovieContainerInfo> {
        movieRequest(router: .other(query: query, page: page))
    }
    
    func getTrending(at page: Int) -> Observable<MovieContainerInfo> {
        movieRequest(router: .trending(page: page))
    }
    
    func getDiscover(request: DiscoverMovieRequest) -> Observable<MovieContainerInfo> {
        movieRequest(router: .discover(request: request))
    }
    
    private func movieRequest<T: Codable>(router: MovieRouter) -> Observable<T> {
        APIClient.request(router)
    }
}
