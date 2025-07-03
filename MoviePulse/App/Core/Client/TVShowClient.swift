import RxSwift

protocol TVShowServices {
    func getTVShowsPopular(page: Int) -> Observable<TVShowContainerInfo>
    func getTVShowsTopRate(page: Int) -> Observable<TVShowContainerInfo>
    func getTVShowsOnAir(page: Int) -> Observable<TVShowContainerInfo>
    func getTVShowsLastest(page: Int) -> Observable<TVShowContainerInfo>
    func getTVShowCategories() -> Observable<CategoryContainer>
    func getTVShowsByCategory(id: Int, page: Int) -> Observable<TVShowContainerInfo>
    func getTVShowDetail(id: Int) -> Observable<TVShowDetailInfo>
    func getSeasons(idTVShow: Int, index: Any) -> Observable<SeasonInfo>
    func getFM(tvName: String, seasonName: String, episcode: Int) -> Observable<LinkContainer>
    func getDiscover(query: String, page: Int) -> Observable<TVShowContainerInfo>
    func getTrending(page: Int) -> Observable<TVShowContainerInfo>
}

class TVShowClient: TVShowServices {
    func getTVShowsPopular(page: Int) -> Observable<TVShowContainerInfo> {
        APIClient.request(TVShowRouter.popular(page: page))
    }
    
    func getTVShowsTopRate(page: Int) -> Observable<TVShowContainerInfo> {
        APIClient.request(TVShowRouter.topRate(page: page))
    }
    
    func getTVShowsOnAir(page: Int) -> Observable<TVShowContainerInfo> {
        APIClient.request(TVShowRouter.onAir(page: page))
    }
    
    func getTVShowsLastest(page: Int) -> Observable<TVShowContainerInfo> {
        APIClient.request(TVShowRouter.lastest(page: page))
    }
    
    func getTVShowCategories() -> Observable<CategoryContainer> {
        APIClient.request(TVShowRouter.category)
    }
    
    func getTVShowsByCategory(id: Int, page: Int) -> Observable<TVShowContainerInfo> {
        APIClient.request(TVShowRouter.withCategory(id: id, page: page))
    }
    
    func getTVShowDetail(id: Int) -> Observable<TVShowDetailInfo> {
        APIClient.request(TVShowRouter.detail(id: id))
    }
    
    func getSeasons(idTVShow: Int, index: Any) -> Observable<SeasonInfo> {
        APIClient.request(TVShowRouter.seasons(idTVShow: idTVShow, index: index))
    }
    
    func getFM(tvName: String, seasonName: String, episcode: Int) -> Observable<LinkContainer> {
        APIClient.requestEncrypt(TVShowRouter.link(name: tvName, seasonName: seasonName, episcode: episcode))
    }
    
    func getDiscover(query: String, page: Int) -> Observable<TVShowContainerInfo> {
        APIClient.request(TVShowRouter.other(query: query, page: page))
    }
    
    func getTrending(page: Int) -> Observable<TVShowContainerInfo> {
        APIClient.request(TVShowRouter.trending(page: page))
    }
}
