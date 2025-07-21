import Foundation

class FavoritesManager: ObservableObject {
    @Published var favorites: [Movie] = []
    private let userDefaults = UserDefaults.standard
    private let favoritesKey = "favoriteMovies"
    
    init() {
        loadFavorites()
    }
    
    func addToFavorites(_ movie: Movie) {
        if !favorites.contains(where: { $0.id == movie.id }) {
            favorites.append(movie)
            saveFavorites()
        }
    }
    
    func removeFromFavorites(_ movie: Movie) {
        favorites.removeAll { $0.id == movie.id }
        saveFavorites()
    }
    
    func isFavorite(_ movie: Movie) -> Bool {
        return favorites.contains { $0.id == movie.id }
    }
    
    func toggleFavorite(_ movie: Movie) {
        if isFavorite(movie) {
            removeFromFavorites(movie)
        } else {
            addToFavorites(movie)
        }
    }
    
    func clearAllFavorites() {
        favorites.removeAll()
        saveFavorites()
    }
    
    private func saveFavorites() {
        do {
            let data = try JSONEncoder().encode(favorites)
            userDefaults.set(data, forKey: favoritesKey)
        } catch {
            print("Error saving favorites: \(error)")
        }
    }
    
    private func loadFavorites() {
        guard let data = userDefaults.data(forKey: favoritesKey) else { return }
        do {
            favorites = try JSONDecoder().decode([Movie].self, from: data)
        } catch {
            print("Error loading favorites: \(error)")
            favorites = []
        }
    }
} 