//
//  ContentView.swift
//  MoviePickerBot
//
//  Created by Daulet on 12/07/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var movieService = MovieService()
    @StateObject private var favoritesManager = FavoritesManager()
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State private var searchText = ""
    @State private var filters = MovieFilters()
    @State private var showingFilters = false
    @State private var selectedMovie: Movie?
    @State private var showingMovieDetail = false
    @State private var showingFavorites = false
    @State private var isSurpriseLoading = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                searchBar
                    .padding(.top, 12)
                // Filter and Surprise Me Buttons
                filterAndSurpriseButtons
                    .padding(.bottom, 5)
                    .padding(.top, 5)
                // Content
                if movieService.isLoading {
                    loadingView
                } else if let errorMessage = movieService.errorMessage {
                    errorView(message: errorMessage)
                } else if movieService.movies.isEmpty {
                    emptyStateView
                } else {
                    movieGridView
                }
            }
            .navigationTitle("Let The Night Pick")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(trailing: favoritesButton)
            .background(Color(.systemGroupedBackground))
            .sheet(isPresented: $showingFilters) {
                FilterView(
                    filters: $filters,
                    isPresented: $showingFilters,
                    movieService: movieService
                )
            }
            .sheet(isPresented: $showingMovieDetail) {
                if let movie = selectedMovie {
                    NavigationView {
                        MovieDetailView(movie: movie, favoritesManager: favoritesManager, detailService: MovieDetailService())
                    }
                }
            }
            .sheet(isPresented: $showingFavorites) {
                FavoritesView(favoritesManager: favoritesManager)
            }
            .onAppear {
                if movieService.movies.isEmpty {
                    movieService.fetchMovies(filters: filters)
                }
            }
        }
    }
    
    private var searchBar: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search movies...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .onSubmit {
                        if !searchText.isEmpty {
                            movieService.searchMovies(query: searchText)
                        } else {
                            movieService.fetchMovies(filters: filters)
                        }
                    }
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        movieService.fetchMovies(filters: filters)
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
        }
        .padding(.horizontal, 20)
    }
    
    private var filterAndSurpriseButtons: some View {
        HStack {
            Button(action: {
                showingFilters = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .font(.system(size: 16, weight: .medium))
                    Text("Filters")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(.purple)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(Color.purple.opacity(0.12))
                .cornerRadius(22)
            }
            
            Spacer()
            
            // Surprise Me Button
            Button(action: {
                surpriseMe()
            }) {
                HStack(spacing: 8) {
                    if isSurpriseLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "dice.fill")
                            .font(.system(size: 16, weight: .medium))
                    }
                    Text("Surprise Me")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(.orange)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(Color.orange.opacity(0.12))
                .cornerRadius(22)
            }
            .disabled(isSurpriseLoading)
            
            Spacer()
            
            // Show active filter count
            if hasActiveFilters {
                Text("\(activeFilterCount) active")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 24)
    }
    
    private var movieGridView: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 20),
                    GridItem(.flexible(), spacing: 20)
                ], spacing: 24) {
                    ForEach(movieService.movies) { movie in
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
                
                // Load More Button
                if movieService.hasMorePages {
                    loadMoreButton
                        .padding(.horizontal, 16)
                        .padding(.bottom, 32)
                }
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading movies...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            Text("Oops! Something went wrong")
                .font(.title2)
                .fontWeight(.semibold)
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Button("Try Again") {
                movieService.fetchMovies(filters: filters)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "film")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            Text("No movies found")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Try adjusting your search or filters")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var favoritesButton: some View {
        Button(action: {
            showingFavorites = true
        }) {
            HStack(spacing: 4) {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                Text("\(favoritesManager.favorites.count)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.red)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.red.opacity(0.1))
            .cornerRadius(16)
        }
    }
    
    private var loadMoreButton: some View {
        Button(action: {
            movieService.loadMoreMovies()
        }) {
            HStack(spacing: 8) {
                if movieService.isLoadingMore {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "arrow.down.circle")
                        .font(.system(size: 16, weight: .medium))
                }
                Text(movieService.isLoadingMore ? "Loading..." : "Load More Movies")
                    .font(.system(size: 16, weight: .medium))
            }
            .foregroundColor(.purple)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.purple.opacity(0.12))
            .cornerRadius(25)
        }
        .disabled(movieService.isLoadingMore)
    }
    
    private var hasActiveFilters: Bool {
        filters.minYear != nil ||
        filters.maxYear != nil ||
        filters.minRating != nil ||
        filters.maxRating != nil ||
        !filters.selectedGenres.isEmpty ||
        !filters.selectedCountries.isEmpty
    }
    
    private var activeFilterCount: Int {
        var count = 0
        if filters.minYear != nil { count += 1 }
        if filters.maxYear != nil { count += 1 }
        if filters.minRating != nil { count += 1 }
        if filters.maxRating != nil { count += 1 }
        if !filters.selectedGenres.isEmpty { count += 1 }
        if !filters.selectedCountries.isEmpty { count += 1 }
        return count
    }
    
    private func surpriseMe() {
        guard !isSurpriseLoading else { return }
        
        isSurpriseLoading = true
        
        // Reset any existing selected movie
        selectedMovie = nil
        showingMovieDetail = false
        
        movieService.fetchRandomMovie { result in
            DispatchQueue.main.async {
                self.isSurpriseLoading = false
                switch result {
                case .success(let movie):
                    self.selectedMovie = movie
                    
                    // Add a small delay to ensure state is properly updated
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.showingMovieDetail = true
                    }
                case .failure(let error):
                    print("Error fetching random movie: \(error)")
                    // You could show an alert here if needed
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(NetworkMonitor())
}
