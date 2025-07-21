import Foundation

struct MovieResponse: Codable {
    let page: Int
    let results: [Movie]
    let totalPages: Int
    let totalResults: Int
    
    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

struct Movie: Codable, Identifiable, Equatable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String
    let voteAverage: Double
    let voteCount: Int
    let genreIds: [Int]
    let originalLanguage: String
    let popularity: Double
    
    enum CodingKeys: String, CodingKey {
        case id, title, overview
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case genreIds = "genre_ids"
        case originalLanguage = "original_language"
        case popularity
    }
    
    var posterURL: URL? {
        guard let posterPath = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
    }
    
    var backdropURL: URL? {
        guard let backdropPath = backdropPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/original\(backdropPath)")
    }
    
    var year: Int? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: releaseDate) else { return nil }
        return Calendar.current.component(.year, from: date)
    }
    
    var formattedReleaseDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: releaseDate) else { return releaseDate }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        return displayFormatter.string(from: date)
    }
}

struct Genre: Codable, Identifiable {
    let id: Int
    let name: String
}

struct GenreResponse: Codable {
    let genres: [Genre]
}

struct Country: Codable, Identifiable {
    let id: String
    let name: String
    
    var displayName: String {
        return name
    }
}
