import SwiftUI

struct MovieCardView: View {
    let movie: Movie
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Poster Image
            AsyncImage(url: movie.posterURL) { image in
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
            .frame(height: 280)
            .clipped()
            
            // Movie Info
            VStack(alignment: .leading, spacing: 8) {
                // Title and Rating
                HStack {
                    Text(movie.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", movie.voteAverage))
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.yellow.opacity(0.2))
                    .cornerRadius(8)
                }
                
                // Year and Language
                HStack {
                    if let year = movie.year {
                        Text("\(year)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if !movie.originalLanguage.isEmpty {
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(movie.originalLanguage.uppercased())
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Overview
                Text(movie.overview)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }
            .padding(12)
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    MovieCardView(movie: Movie(
        id: 1,
        title: "Sample Movie",
        overview: "This is a sample movie overview that demonstrates how the card will look with real content.",
        posterPath: nil,
        backdropPath: nil,
        releaseDate: "2023-01-01",
        voteAverage: 8.5,
        voteCount: 1000,
        genreIds: [1, 2],
        originalLanguage: "en",
        popularity: 100.0
    ))
    .padding()
} 
