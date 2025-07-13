import Foundation
import Combine

class MovieDetailService: ObservableObject {
    private let apiKey = "404125da4b382c37bfb650bd5ceab531"
    private let baseURL = "https://api.themoviedb.org/3"
    
    @Published var credits: CreditsResponse?
    @Published var videos: [Video] = []
    @Published var recommendations: [Movie] = []
    @Published var similarMovies: [Movie] = []
    @Published var isLoading = true
    
    private var cancellables = Set<AnyCancellable>()
    
    func loadData(for movieID: Int) {
//        print("MovieDetailService: Starting to load data for movie \(movieID)")
        
        // Reset state
        credits = nil
        videos = []
        recommendations = []
        similarMovies = []
        isLoading = true
        
        // Fetch all data concurrently using Combine
        let creditsPublisher = fetchCreditsPublisher(for: movieID)
        let videosPublisher = fetchVideosPublisher(for: movieID)
        let recommendationsPublisher = fetchRecommendationsPublisher(for: movieID)
        let similarMoviesPublisher = fetchSimilarMoviesPublisher(for: movieID)
        
        // Combine all publishers and handle completion
        Publishers.Zip4(creditsPublisher, videosPublisher, recommendationsPublisher, similarMoviesPublisher)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("MovieDetailService: Error loading movie data for \(movieID): \(error)")
                    }
//                    print("MovieDetailService: Completed loading data for movie \(movieID)")
                    self.isLoading = false
                },
                receiveValue: { (credits, videos, recommendations, similarMovies) in
//                    print("MovieDetailService: Received data for movie \(movieID)")
//                    print("  - Credits: \(credits.cast.count) cast members")
//                    print("  - Videos: \(videos.results.count) videos")
//                    print("  - Recommendations: \(recommendations.results.count) movies")
//                    print("  - Similar: \(similarMovies.results.count) movies")
                    
                    DispatchQueue.main.async {
                        self.credits = credits
                        self.videos = videos.results
                        self.recommendations = recommendations.results
                        self.similarMovies = similarMovies.results
                        self.isLoading = false
//                        print("MovieDetailService: Updated @Published properties for movie \(movieID)")
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    private func fetchCreditsPublisher(for movieID: Int) -> AnyPublisher<CreditsResponse, Error> {
        let urlString = "\(baseURL)/movie/\(movieID)/credits?api_key=\(apiKey)&language=en-US"
        guard let url = URL(string: urlString) else { 
            return Fail(error: NSError(domain: "Invalid URL", code: -1))
                .eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: CreditsResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }

    private func fetchVideosPublisher(for movieID: Int) -> AnyPublisher<VideoResponse, Error> {
        let urlString = "\(baseURL)/movie/\(movieID)/videos?api_key=\(apiKey)&language=en-US"
        guard let url = URL(string: urlString) else { 
            return Fail(error: NSError(domain: "Invalid URL", code: -1))
                .eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: VideoResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }

    private func fetchRecommendationsPublisher(for movieID: Int) -> AnyPublisher<RecommendationResponse, Error> {
        let urlString = "\(baseURL)/movie/\(movieID)/recommendations?api_key=\(apiKey)&language=en-US&page=1"
        guard let url = URL(string: urlString) else { 
            return Fail(error: NSError(domain: "Invalid URL", code: -1))
                .eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: RecommendationResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }

    private func fetchSimilarMoviesPublisher(for movieID: Int) -> AnyPublisher<RecommendationResponse, Error> {
        let urlString = "\(baseURL)/movie/\(movieID)/similar?api_key=\(apiKey)&language=en-US&page=1"
        guard let url = URL(string: urlString) else { 
            return Fail(error: NSError(domain: "Invalid URL", code: -1))
                .eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: RecommendationResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
} 
