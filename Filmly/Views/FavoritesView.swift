import SwiftUI

struct FavoritesView: View {
    @ObservedObject var favoritesManager: FavoritesManager
    @StateObject private var detailService = MovieDetailService()
    @State private var selectedMovie: Movie?
    @State private var showingMovieDetail = false
    @State private var showingClearAllAlert = false
    
    var body: some View {
        NavigationView {
            VStack {
                if favoritesManager.favorites.isEmpty {
                    emptyStateView
                } else {
                    favoritesList
                }
            }
            .navigationTitle("Wishlist")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if !favoritesManager.favorites.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Clear All") {
                            showingClearAllAlert = true
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .sheet(isPresented: $showingMovieDetail) {
                if let movie = selectedMovie {
                    NavigationView {
                        MovieDetailView(movie: movie, favoritesManager: favoritesManager, detailService: detailService)
                    }
                }
            }
            .alert("Clear All Favorites", isPresented: $showingClearAllAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear All", role: .destructive) {
                    favoritesManager.clearAllFavorites()
                }
            } message: {
                Text("Are you sure you want to remove all movies from your favorites? This action cannot be undone.")
            }
            .onChange(of: selectedMovie) { newMovie in
                if let movie = newMovie {
                    detailService.loadData(for: movie.id)
                }
            }
        }
    }
    
    private var favoritesList: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 20),
                GridItem(.flexible(), spacing: 20)
            ], spacing: 24) {
                ForEach(favoritesManager.favorites) { movie in
                    MovieCardView(movie: movie)
                        .onTapGesture {
                            selectedMovie = movie
                            
                            // Add a small delay to ensure state is properly updated
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                showingMovieDetail = true
                            }
                        }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart")
                .font(.system(size: 50))
                .foregroundColor(.red)
            Text("No favorites yet")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Tap the heart icon on any movie to add it to your favorites")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    FavoritesView(favoritesManager: FavoritesManager())
} 
