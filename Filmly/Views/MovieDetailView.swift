import SwiftUI

struct MovieDetailView: View {
    let movie: Movie
    @ObservedObject var favoritesManager: FavoritesManager
    @ObservedObject var detailService: MovieDetailService
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedMovie: Movie?
    
    init(movie: Movie, favoritesManager: FavoritesManager, detailService: MovieDetailService) {
        self.movie = movie
        self.favoritesManager = favoritesManager
        self.detailService = detailService
//        print("MovieDetailView: init for movie \(movie.id)")
    }
    
    var currentMovie: Movie {
        selectedMovie ?? movie
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Color.clear.frame(height: 0).id("top") // Anchor for scrolling
                        // Hero Image with Backdrop
                        ZStack(alignment: .bottomLeading) {
                            AsyncImage(url: currentMovie.backdropURL) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .overlay(
                                        Image(systemName: "film")
                                            .font(.largeTitle)
                                            .foregroundColor(.gray)
                                    )
                            }
                            .frame(height: 300)
                            .clipped()
                            // Removed the overlay with the close button
                            // Gradient overlay
                            LinearGradient(
                                gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.7)]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: 300)
                            // Movie info overlay
                            VStack(alignment: .leading, spacing: 8) {
                                Text(currentMovie.title)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .lineLimit(2)
                                    .padding(.top, 8)
                                HStack(spacing: 16) {
                                    if let year = currentMovie.year {
                                        Text("\(year)")
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                    HStack(spacing: 4) {
                                        Image(systemName: "star.fill")
                                            .font(.caption)
                                            .foregroundColor(.yellow)
                                        Text(String(format: "%.1f", currentMovie.voteAverage))
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.white)
                                    }
                                    Text("\(currentMovie.voteCount) votes")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                            .padding(.leading, 80)
                            .padding(.trailing, 0)
                            .padding(.bottom, 28)
                        }
                        .frame(width: geometry.size.width, height: 300)
                        .background(Color.black)

                        // Favorites button just below the hero image
                        HStack {
                            Spacer()
                            Button(action: {
                                favoritesManager.toggleFavorite(currentMovie)
                            }) {
                                Image(systemName: favoritesManager.isFavorite(currentMovie) ? "heart.fill" : "heart")
                                    .font(.title)
                                    .foregroundColor(favoritesManager.isFavorite(currentMovie) ? .red : .gray)
                                    .padding(16)
                                    .background(Color(.systemBackground).opacity(0.9))
                                    .clipShape(Circle())
                                    .shadow(radius: 4)
                            }
                            .padding(.trailing, 24)
                            .padding(.top, -32)
                        }

                        VStack(alignment: .leading, spacing: 28) {
                            // Overview Section (always show)
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Overview")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                Text(currentMovie.overview)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .lineSpacing(4)
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            
                            // Movie Details (always show)
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Details")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                VStack(spacing: 12) {
                                    DetailRow(title: "Release Date", value: currentMovie.formattedReleaseDate)
                                    DetailRow(title: "Language", value: currentMovie.originalLanguage.uppercased())
                                    DetailRow(title: "Popularity", value: String(format: "%.1f", currentMovie.popularity))
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            // Cast & Crew Section
                            if let credits = detailService.credits {
                                CastSection(credits: credits)
                            } else {
                                LoadingSection(title: "Cast & Crew")
                            }
                            
                            // Trailers Section
                            if let trailer = detailService.videos.first(where: { $0.type == "Trailer" && $0.site == "YouTube" }) {
                                TrailerSection(trailer: trailer)
                            } else {
                                LoadingSection(title: "Trailer")
                            }
                            
                            // Recommendations Section
                            if !detailService.recommendations.isEmpty {
                                MovieCarouselSection(title: "Recommended Movies", movies: detailService.recommendations, onSelect: { movie in
                                    if movie.id != currentMovie.id {
                                        selectedMovie = movie
                                    }
                                })
                            } else {
                                LoadingSection(title: "Recommended Movies")
                            }
                            
                            // Similar Movies Section
                            if !detailService.similarMovies.isEmpty {
                                MovieCarouselSection(title: "Similar Movies", movies: detailService.similarMovies, onSelect: { movie in
                                    if movie.id != currentMovie.id {
                                        selectedMovie = movie
                                    }
                                })
                            } else {
                                LoadingSection(title: "Similar Movies")
                            }
                        }
                        .padding(.bottom, geometry.safeAreaInsets.bottom)
                    }
                }
                .edgesIgnoringSafeArea(.top)
                .onAppear {
                    detailService.loadData(for: currentMovie.id)
                }
                .onChange(of: selectedMovie) { newMovie in
                    if let newMovie = newMovie {
                        detailService.loadData(for: newMovie.id)
                        withAnimation {
                            proxy.scrollTo("top", anchor: .top)
                        }
                    }
                }
            }
        }
        .background(Color(.systemBackground))
        .ignoresSafeArea(.container, edges: .bottom)
        .navigationBarHidden(true)
    }
    

}

struct LoadingSection: View {
    let title: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.horizontal, 20)
            
            HStack {
                ProgressView()
                    .scaleEffect(0.8)
                Text("Loading...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
        }
    }
}

struct CastSection: View {
    let credits: CreditsResponse
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let director = credits.crew.first(where: { $0.job == "Director" }) {
                Text("Director: \(director.name)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .padding(.horizontal, 20)
            }
            Text("Cast")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.horizontal, 20)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(credits.cast.prefix(12)) { cast in
                        VStack(spacing: 8) {
                            AsyncImage(url: cast.profileURL) { image in
                                image.resizable().aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Circle().fill(Color.gray.opacity(0.2))
                                    .overlay(Image(systemName: "person.fill").foregroundColor(.gray))
                            }
                            .frame(width: 64, height: 64)
                            .clipShape(Circle())
                            Text(cast.name)
                                .font(.caption)
                                .fontWeight(.medium)
                                .lineLimit(1)
                            if let character = cast.character {
                                Text(character)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        .frame(width: 80)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

struct TrailerSection: View {
    let trailer: Video
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Trailer")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.horizontal, 20)
            if let thumbnailURL = trailer.youtubeThumbnailURL, let youtubeURL = trailer.youtubeURL {
                Link(destination: youtubeURL) {
                    ZStack(alignment: .center) {
                        AsyncImage(url: thumbnailURL) { image in
                            image.resizable().aspectRatio(16/9, contentMode: .fill)
                        } placeholder: {
                            Rectangle().fill(Color.gray.opacity(0.2))
                        }
                        .frame(height: 180)
                        .cornerRadius(12)
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 56))
                            .foregroundColor(.white)
                            .shadow(radius: 8)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

struct MovieCarouselSection: View {
    let title: String
    let movies: [Movie]
    let onSelect: (Movie) -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.horizontal, 20)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(movies.prefix(12)) { movie in
                        VStack(spacing: 8) {
                            AsyncImage(url: movie.posterURL) { image in
                                image.resizable().aspectRatio(2/3, contentMode: .fill)
                            } placeholder: {
                                Rectangle().fill(Color.gray.opacity(0.2))
                                    .overlay(Image(systemName: "film").foregroundColor(.gray))
                            }
                            .frame(width: 90, height: 135)
                            .cornerRadius(10)
                            Text(movie.title)
                                .font(.caption)
                                .fontWeight(.medium)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                        }
                        .frame(width: 90)
                        .onTapGesture { onSelect(movie) }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 100, alignment: .leading)
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
            Spacer()
        }
    }
}

#Preview {
    NavigationView {
        let detailService = MovieDetailService()
        MovieDetailView(movie: Movie(
            id: 1,
            title: "Sample Movie Title",
            overview: "This is a detailed overview of the movie that provides comprehensive information about the plot, characters, and storyline. It gives viewers a good understanding of what to expect from the film.",
            posterPath: nil,
            backdropPath: nil,
            releaseDate: "2023-01-01",
            voteAverage: 8.5,
            voteCount: 1000,
            genreIds: [1, 2],
            originalLanguage: "en",
            popularity: 100.0
        ), favoritesManager: FavoritesManager(), detailService: detailService)
    }
}
