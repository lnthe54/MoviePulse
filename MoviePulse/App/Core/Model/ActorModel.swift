struct ActorInfo: Codable {
    let id: Int
    let adult: Bool
    let gender: Int
    let name: String
    let popularity: Double
    let profile_path: String?
    let known_for: [ActorKnowFor]
    let known_for_department: String?
}

struct ActorContainer: Codable {
    let results: [ActorInfo]
}

struct ActorDetailInfo: Codable {
    let id: Int
    let name: String
    let profile_path: String?
    let gender: Int
    let birthday: String?
    let place_of_birth: String?
    let biography: String?
    let movie_credits: MovieCredits
    let tv_credits: TVCreditsInfo
    let known_for_department: String
    let images: ImageActorInfo
    
    static func empty() -> ActorDetailInfo {
        return .init(id: 0,
                     name: "",
                     profile_path: nil,
                     gender: 0,
                     birthday: nil,
                     place_of_birth: nil,
                     biography: nil,
                     movie_credits: MovieCredits(cast: []),
                     tv_credits: TVCreditsInfo(cast: []),
                     known_for_department: "",
                     images: ImageActorInfo(profiles: []))
    }
    
    func getBirthday() -> String {
        let birthday = birthday?
            .toDate(formatter: .dateOnlyFromServer)
            .toString(formatter: .dayMonthYear) ?? ""
        return birthday
    }
    
    func transformToInfoDetailObject() -> InfoDetailObject {
        return InfoDetailObject(
            id: self.id,
            backdrop_path: "",
            posterPath: self.profile_path,
            overview: self.biography,
            runtime: 0,
            releaseDate: self.getBirthday(),
            name: self.name,
            genres: [],
            vote: 0,
            recommendations: [],
            credits: nil,
            videos: nil,
            reviews: nil,
            numberOfSeasons: 0,
            seasons: [],
            movies: Utils.transformToInfoObject(movies: movie_credits.cast),
            shows: Utils.transformToInfoObject(tvShows: tv_credits.cast),
            type: .actor,
            place: self.place_of_birth,
            images: images.profiles
        )
    }
}

// MARK: - Movie Credits Info
struct MovieCredits: Codable {
    let cast: [MovieObject]
}

// MARK: - TV Credits Info
struct TVCreditsInfo: Codable {
    let cast: [TVShowObject]
}

struct ActorKnowFor: Codable {
    let genre_ids: [Int]
}

struct ImageActorInfo: Codable {
    let profiles: [BackdropObject]
}
