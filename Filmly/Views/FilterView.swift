import SwiftUI

struct FilterView: View {
    @Binding var filters: MovieFilters
    @Binding var isPresented: Bool
    @ObservedObject var movieService: MovieService
    
    @State private var tempFilters: MovieFilters
    
    init(filters: Binding<MovieFilters>, isPresented: Binding<Bool>, movieService: MovieService) {
        self._filters = filters
        self._isPresented = isPresented
        self.movieService = movieService
        self._tempFilters = State(initialValue: filters.wrappedValue)
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Year Range Section
                Section("Year Range") {
                    HStack {
                        Text("From")
                        Spacer()
                        Picker("Min Year", selection: $tempFilters.minYear) {
                            Text("Any").tag(nil as Int?)
                            ForEach(1980...2025, id: \.self) { year in
                                Text("\(year)").tag(year as Int?)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    HStack {
                        Text("To")
                        Spacer()
                        Picker("Max Year", selection: $tempFilters.maxYear) {
                            Text("Any").tag(nil as Int?)
                            ForEach(1980...2025, id: \.self) { year in
                                Text("\(year)").tag(year as Int?)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
                
                // Rating Range Section
                Section("Rating Range") {
                    HStack {
                        Text("Min Rating")
                        Spacer()
                        Picker("", selection: $tempFilters.minRating) {
                            Text("Any").tag(nil as Double?)
                            ForEach([1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0], id: \.self) { rating in
                                Text("\(rating, specifier: "%.1f")").tag(rating as Double?)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
                
                // Genres Section
                Section("Genres") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                        ForEach(movieService.genres) { genre in
                            GenreToggleButton(
                                genre: genre,
                                isSelected: tempFilters.selectedGenres.contains(genre.id)
                            ) {
                                if tempFilters.selectedGenres.contains(genre.id) {
                                    tempFilters.selectedGenres.removeAll { $0 == genre.id }
                                } else {
                                    tempFilters.selectedGenres.append(genre.id)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                // Countries Section
                Section("Countries") {
                    ForEach(MovieFilters.availableCountries) { country in
                        HStack {
                            Text(country.displayName)
                            Spacer()
                            if tempFilters.selectedCountries.contains(where: { $0.id == country.id }) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.purple)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if let index = tempFilters.selectedCountries.firstIndex(where: { $0.id == country.id }) {
                                tempFilters.selectedCountries.remove(at: index)
                            } else {
                                tempFilters.selectedCountries.append(country)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        tempFilters = MovieFilters()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        filters = tempFilters
                        movieService.fetchMovies(filters: filters)
                        isPresented = false
                    }
                }
            }
        }
    }
}

struct GenreToggleButton: View {
    let genre: Genre
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(genre.name)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isSelected ? Color.purple : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    FilterView(
        filters: .constant(MovieFilters()),
        isPresented: .constant(true),
        movieService: MovieService()
    )
}
 
