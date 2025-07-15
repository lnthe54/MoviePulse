import Foundation
import CodableFiles

class CodableManager {
    
    static let shared =  CodableManager()
    
    private let codableFiles = CodableFiles.shared
    
    private enum Constants {
        static let KEY_COLLECT: String = "KEY_COLLECT"
        static let KEY_SEARCH: String = "KEY_SEARCH"
        static let KEY_FAVORITE: String = "LIST_FAVORITE"
        static let KEY_MOVIE_CATEGORIES: String = "movieCategories"
        static let KEY_TV_CATEGORIES: String = "tvCategories"
        static let KEY_PULSE_RESULT: String = "KEY_PULSE_RESULT"
    }
    
    func saveMovieCategories(_ categories: [CategoryObject]) {
        _ = try? codableFiles.saveAsArray(objects: categories, withFilename: Constants.KEY_MOVIE_CATEGORIES)
    }
    
    func getMovieCategories() -> [CategoryObject] {
        if let categories = try? codableFiles.loadAsArray(objectType: CategoryObject.self, withFilename: Constants.KEY_MOVIE_CATEGORIES) {
            return categories
        } else {
            return []
        }
    }
    
    func saveTVCategories(_ categories: [CategoryObject]) {
        _ = try? codableFiles.saveAsArray(objects: categories, withFilename: Constants.KEY_TV_CATEGORIES)
    }
    
    func getTVCategories() -> [CategoryObject] {
        if let categories = try? codableFiles.loadAsArray(objectType: CategoryObject.self, withFilename: Constants.KEY_TV_CATEGORIES) {
            return categories
        } else {
            return []
        }
    }
    
    func saveListFarotie(_ favorites: [InfoDetailObject]) {
        _ = try? codableFiles.saveAsArray(objects: favorites, withFilename: Constants.KEY_FAVORITE)
    }
    
    func getListFavorite() -> [InfoDetailObject] {
        if let list = try? codableFiles.loadAsArray(objectType: InfoDetailObject.self, withFilename: Constants.KEY_FAVORITE) {
            return list
        } else {
            return []
        }
    }
   
    func saveKeySearch(_ key: String) {
        var keys = getListKeySearch()
        keys.removeAll(where: { $0 == key})
        keys.insert(key, at: 0)
        saveKeys(keys)
    }
    
    func saveKeys(_ keys: [String]) {
        UserDefaults.standard.set(keys, forKey: Constants.KEY_SEARCH)
    }
    
    func getListKeySearch() -> [String] {
        if let keys = UserDefaults.standard.value(forKey: Constants.KEY_SEARCH) as? [String] {
            return keys
        } else {
            return []
        }
    }
    
    func savePulseResults(_ results: [PulseResultInfo]) {
        _ = try? codableFiles.saveAsArray(objects: results, withFilename: Constants.KEY_PULSE_RESULT)
    }
    
    func getPulseResults() -> [PulseResultInfo] {
        if let results = try? codableFiles.loadAsArray(objectType: PulseResultInfo.self, withFilename: Constants.KEY_PULSE_RESULT) {
            return results
        } else {
            return []
        }
    }
}
