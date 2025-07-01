import Foundation
import CodableFiles

class CodableManager {
    
    static let shared =  CodableManager()
    
    private let codableFiles = CodableFiles.shared
    
    private enum Constants {
        static let KEY_COLLECT: String = "KEY_COLLECT"
        static let KEY_SEARCH: String = "KEY_SEARCH"
        static let KEY_FAVORITE: String = "LIST_FAVORITE"
    }
    
    func saveMovieCategories(_ categories: [CategoryObject]) {
        _ = try? codableFiles.saveAsArray(objects: categories, withFilename: "movieCategories")
    }
    
    func getMovieCategories() -> [CategoryObject] {
        if let categories = try? codableFiles.loadAsArray(objectType: CategoryObject.self, withFilename: "movieCategories") {
            return categories
        } else {
            return []
        }
    }
    
    func saveTVCategories(_ categories: [CategoryObject]) {
        _ = try? codableFiles.saveAsArray(objects: categories, withFilename: "tvCategories")
    }
    
    func getTVCategories() -> [CategoryObject] {
        if let categories = try? codableFiles.loadAsArray(objectType: CategoryObject.self, withFilename: "tvCategories") {
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
}
