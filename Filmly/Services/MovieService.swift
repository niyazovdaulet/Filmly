import Foundation
import Combine

class MovieService: ObservableObject {
    private let apiKey = "404125da4b382c37bfb650bd5ceab531"
    private let baseURL = "https://api.themoviedb.org/3"
    
    @Published var movies: [Movie] = []
    @Published var genres: [Genre] = []
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var errorMessage: String?
    @Published var credits: CreditsResponse?
    @Published var videos: [Video] = []
    @Published var recommendations: [Movie] = []
    @Published var similarMovies: [Movie] = []
    
    // Pagination properties
    @Published var currentPage = 1
    @Published var totalPages = 1
    @Published var hasMorePages = true
    
    private var cancellables = Set<AnyCancellable>()
    private var currentFilters: MovieFilters = MovieFilters()
    
    init() {
        fetchGenres()
    }
    
    func fetchMovies(filters: MovieFilters = MovieFilters()) {
        // Reset pagination for new search/filter
        currentPage = 1
        totalPages = 1
        hasMorePages = true
        currentFilters = filters
        movies = []
        
        // Load initial pages (1-5)
        loadInitialPages(filters: filters)
    }
    
    private func loadInitialPages(filters: MovieFilters) {
        isLoading = true
        errorMessage = nil
        
        // Load pages 1-5 concurrently
        let initialPages = Array(1...5)
        let group = DispatchGroup()
        var allMovies: [Movie] = []
        var pageErrors: [String] = []
        
        for page in initialPages {
            group.enter()
            fetchMoviesPage(page: page, filters: filters) { result in
                switch result {
                case .success(let movieResponse):
                    allMovies.append(contentsOf: movieResponse.results)
                    if page == 1 {
                        DispatchQueue.main.async {
                            self.totalPages = movieResponse.totalPages
                            self.hasMorePages = self.currentPage < self.totalPages
                        }
                    }
                case .failure(let error):
                    pageErrors.append("Page \(page): \(error.localizedDescription)")
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.isLoading = false
            if !pageErrors.isEmpty {
                self.errorMessage = "Some pages failed to load: \(pageErrors.joined(separator: "; "))"
            }
            self.movies = allMovies
            self.currentPage = 5 // Set to last loaded page
        }
    }
    
    func loadMoreMovies() {
        guard !isLoadingMore && hasMorePages else { return }
        
        isLoadingMore = true
        let nextPage = currentPage + 1
        
        fetchMoviesPage(page: nextPage, filters: currentFilters) { result in
            DispatchQueue.main.async {
                self.isLoadingMore = false
                
                switch result {
                case .success(let movieResponse):
                    self.movies.append(contentsOf: movieResponse.results)
                    self.currentPage = nextPage
                    self.hasMorePages = self.currentPage < self.totalPages
                case .failure(let error):
                    self.errorMessage = "Failed to load more movies: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func fetchMoviesPage(page: Int, filters: MovieFilters, completion: @escaping (Result<MovieResponse, Error>) -> Void) {
        var components = URLComponents(string: "\(baseURL)/discover/movie")!
        var queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "language", value: "en-US"),
            URLQueryItem(name: "sort_by", value: "popularity.desc"),
            URLQueryItem(name: "include_adult", value: "false"),
            URLQueryItem(name: "include_video", value: "false"),
            URLQueryItem(name: "page", value: String(page))
        ]
        
        // Apply filters
        if let minYear = filters.minYear {
            queryItems.append(URLQueryItem(name: "primary_release_date.gte", value: "\(minYear)-01-01"))
        }
        
        if let maxYear = filters.maxYear {
            queryItems.append(URLQueryItem(name: "primary_release_date.lte", value: "\(maxYear)-12-31"))
        }
        
        if let minRating = filters.minRating {
            queryItems.append(URLQueryItem(name: "vote_average.gte", value: String(minRating)))
        }
        
        if let maxRating = filters.maxRating {
            queryItems.append(URLQueryItem(name: "vote_average.lte", value: String(maxRating)))
        }
        
        if !filters.selectedGenres.isEmpty {
            let genreIds = filters.selectedGenres.map { String($0) }.joined(separator: ",")
            queryItems.append(URLQueryItem(name: "with_genres", value: genreIds))
        }
        
        if !filters.selectedCountries.isEmpty {
            let countryCodes = filters.selectedCountries.map { $0.id }.joined(separator: ",")
            queryItems.append(URLQueryItem(name: "with_origin_country", value: countryCodes))
        }
        
        components.queryItems = queryItems
        
        guard let url = components.url else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1)))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: -2)))
                return
            }
            
            do {
                let movieResponse = try JSONDecoder().decode(MovieResponse.self, from: data)
                completion(.success(movieResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchGenres() {
        let urlString = "\(baseURL)/genre/movie/list?api_key=\(apiKey)&language=en-US"
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: GenreResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { response in
                    self.genres = response.genres
                }
            )
            .store(in: &cancellables)
    }
    
    func searchMovies(query: String) {
        guard !query.isEmpty else { return }
        
        // Reset pagination for search
        currentPage = 1
        totalPages = 1
        hasMorePages = true
        movies = []
        
        isLoading = true
        errorMessage = nil
        
        let urlString = "\(baseURL)/search/movie?api_key=\(apiKey)&language=en-US&query=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&page=1&include_adult=false"
        
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: MovieResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    self.isLoading = false
                    if case .failure(let error) = completion {
                        self.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { response in
                    self.movies = response.results
                    self.totalPages = response.totalPages
                    self.hasMorePages = self.currentPage < self.totalPages
                }
            )
            .store(in: &cancellables)
    }
    
    func fetchCredits(for movieID: Int, completion: @escaping (Result<CreditsResponse, Error>) -> Void = { _ in }) {
        let urlString = "\(baseURL)/movie/\(movieID)/credits?api_key=\(apiKey)&language=en-US"
        guard let url = URL(string: urlString) else { 
            completion(.failure(NSError(domain: "Invalid URL", code: -1)))
            return 
        }
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: CreditsResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { result in
                    if case .failure(let error) = result {
                        completion(.failure(error))
                    }
                },
                receiveValue: { [weak self] response in
                    self?.credits = response
                    completion(.success(response))
                }
            )
            .store(in: &cancellables)
    }

    func fetchVideos(for movieID: Int, completion: @escaping (Result<VideoResponse, Error>) -> Void = { _ in }) {
        let urlString = "\(baseURL)/movie/\(movieID)/videos?api_key=\(apiKey)&language=en-US"
        guard let url = URL(string: urlString) else { 
            completion(.failure(NSError(domain: "Invalid URL", code: -1)))
            return 
        }
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: VideoResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { result in
                    if case .failure(let error) = result {
                        completion(.failure(error))
                    }
                },
                receiveValue: { [weak self] response in
                    self?.videos = response.results
                    completion(.success(response))
                }
            )
            .store(in: &cancellables)
    }

    func fetchRecommendations(for movieID: Int, completion: @escaping (Result<RecommendationResponse, Error>) -> Void = { _ in }) {
        let urlString = "\(baseURL)/movie/\(movieID)/recommendations?api_key=\(apiKey)&language=en-US&page=1"
        guard let url = URL(string: urlString) else { 
            completion(.failure(NSError(domain: "Invalid URL", code: -1)))
            return 
        }
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: RecommendationResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { result in
                    if case .failure(let error) = result {
                        completion(.failure(error))
                    }
                },
                receiveValue: { [weak self] response in
                    self?.recommendations = response.results
                    completion(.success(response))
                }
            )
            .store(in: &cancellables)
    }

    func fetchSimilarMovies(for movieID: Int, completion: @escaping (Result<RecommendationResponse, Error>) -> Void = { _ in }) {
        let urlString = "\(baseURL)/movie/\(movieID)/similar?api_key=\(apiKey)&language=en-US&page=1"
        guard let url = URL(string: urlString) else { 
            completion(.failure(NSError(domain: "Invalid URL", code: -1)))
            return 
        }
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: RecommendationResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { result in
                    if case .failure(let error) = result {
                        completion(.failure(error))
                    }
                },
                receiveValue: { [weak self] response in
                    self?.similarMovies = response.results
                    completion(.success(response))
                }
            )
            .store(in: &cancellables)
    }
    
    func fetchRandomMovie(completion: @escaping (Result<Movie, Error>) -> Void) {
        // Try multiple approaches to find a random movie
        let attempts = [
            // Attempt 1: Popular movies with minimal filters
            { () -> MovieFilters in
                var filters = MovieFilters()
                filters.minRating = 5.0 // Lower threshold
                //print("Creating filters for attempt 1: minRating=5.0")
                return filters
            },
            // Attempt 2: Recent popular movies
            { () -> MovieFilters in
                var filters = MovieFilters()
                let currentYear = Calendar.current.component(.year, from: Date())
                filters.minYear = currentYear - 5
                filters.maxYear = currentYear
                filters.minRating = 5.0
                //print("Creating filters for attempt 2: minYear=\(currentYear-5), maxYear=\(currentYear), minRating=5.0")
                return filters
            },
            // Attempt 3: Random genre with minimal restrictions
            { () -> MovieFilters in
                var filters = MovieFilters()
                if !self.genres.isEmpty {
                    let randomGenre = self.genres.randomElement()!
                    filters.selectedGenres = [randomGenre.id]
                    //print("Creating filters for attempt 3: genre=\(randomGenre.name) (ID: \(randomGenre.id)), minRating=4.0")
                } else {
                    //print("Creating filters for attempt 3: no genres available, minRating=4.0")
                }
                filters.minRating = 4.0
                return filters
            },
            // Attempt 4: No filters at all (fallback)
            { () -> MovieFilters in
//                print("Creating filters for attempt 4: no filters")
                return MovieFilters()
            }
        ]
        
        func tryNextAttempt(_ attemptIndex: Int) {
            guard attemptIndex < attempts.count else {
                // All attempts failed
//                print("All random movie attempts failed")
                completion(.failure(NSError(domain: "No movies found after all attempts", code: -3)))
                return
            }
            
            let filters = attempts[attemptIndex]()
//            print("Random movie attempt \(attemptIndex + 1): filters = \(filters.description)")
            
            fetchMoviesPage(page: 1, filters: filters) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let movieResponse):
//                        print("Random movie attempt \(attemptIndex + 1): found \(movieResponse.results.count) movies")
                        if let randomMovie = movieResponse.results.randomElement() {
//                            print("Random movie selected: \(randomMovie.title)")
                            completion(.success(randomMovie))
                        } else {
//                            print("Random movie attempt \(attemptIndex + 1): no movies in results")
                            // Try next attempt
                            tryNextAttempt(attemptIndex + 1)
                        }
                    case .failure(let error):
//                        print("Random movie attempt \(attemptIndex + 1) failed: \(error)")
                        // Try next attempt
                        tryNextAttempt(attemptIndex + 1)
                    }
                }
            }
        }
        
        // Start with first attempt
        tryNextAttempt(0)
    }
}

struct MovieFilters {
    var minYear: Int?
    var maxYear: Int?
    var minRating: Double?
    var maxRating: Double?
    var selectedGenres: [Int] = []
    var selectedCountries: [Country] = []
    
    var description: String {
        var parts: [String] = []
        if let minYear = minYear { parts.append("minYear=\(minYear)") }
        if let maxYear = maxYear { parts.append("maxYear=\(maxYear)") }
        if let minRating = minRating { parts.append("minRating=\(minRating)") }
        if let maxRating = maxRating { parts.append("maxRating=\(maxRating)") }
        if !selectedGenres.isEmpty { parts.append("genres=\(selectedGenres)") }
        if !selectedCountries.isEmpty { parts.append("countries=\(selectedCountries.map { $0.name })") }
        return parts.isEmpty ? "no filters" : parts.joined(separator: ", ")
    }
    
    static let availableCountries = [
        Country(id: "US", name: "United States"),
        Country(id: "GB", name: "United Kingdom"),
        Country(id: "CA", name: "Canada"),
        Country(id: "AU", name: "Australia"),
        Country(id: "DE", name: "Germany"),
        Country(id: "FR", name: "France"),
        Country(id: "IT", name: "Italy"),
        Country(id: "ES", name: "Spain"),
        Country(id: "JP", name: "Japan"),
        Country(id: "KR", name: "South Korea"),
        Country(id: "IN", name: "India"),
        Country(id: "BR", name: "Brazil"),
        Country(id: "MX", name: "Mexico"),
        Country(id: "RU", name: "Russia"),
        Country(id: "CN", name: "China")
    ]
} 
