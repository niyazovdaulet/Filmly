# 🎬 Filmly

A modern iOS movie discovery app built with SwiftUI that helps you find your next favorite film. Browse, search, and discover movies with an intuitive interface and powerful filtering options.

## ✨ Features

### 🎯 Core Functionality
- **Movie Discovery**: Browse trending and popular movies
- **Advanced Search**: Search movies by title with real-time results
- **Smart Filtering**: Filter by year range, rating, genres, and countries
- **Surprise Me**: Get random movie recommendations
- **Favorites System**: Save and manage your favorite movies locally
- **Detailed Movie Info**: View comprehensive movie details including cast, trailers, and recommendations

### 🎨 User Experience
- **Modern UI**: Clean, intuitive SwiftUI interface
- **Offline Detection**: Smart network connectivity monitoring
- **Responsive Design**: Optimized for iPhone with portrait orientation
- **Smooth Animations**: Fluid transitions and loading states
- **Dark Mode Support**: Automatic system theme adaptation

### 📱 Technical Features
- **Local Storage**: Favorites saved locally using UserDefaults
- **Network Monitoring**: Real-time internet connectivity detection
- **Image Caching**: Efficient movie poster and backdrop loading
- **Pagination**: Load more movies seamlessly
- **Error Handling**: Graceful error states and retry mechanisms

## 🛠️ Technology Stack

- **Framework**: SwiftUI
- **Language**: Swift 5.0
- **iOS Target**: iOS 18.5+
- **Architecture**: MVVM with ObservableObject
- **Networking**: URLSession with Combine
- **Storage**: UserDefaults for local data persistence
- **Network Monitoring**: Network framework

<<<<<<< HEAD
### Screenshots

*Welcome to Filmly*

<p align="center">
<img width="200" height="450" alt="homePage" src="https://github.com/user-attachments/assets/995101d2-50b0-408f-9856-4790dd8e26ae" />
<img width="200" height="450" alt="FiltersPage" src="https://github.com/user-attachments/assets/7961e4fa-7916-470d-b5cb-071a1bf481f3" />
<img width="200" height="450" alt="MovieCardPage-1" src="https://github.com/user-attachments/assets/b8f5c8ce-1771-4c89-9fb7-7af61f4f545f" />
<img width="200" height="450" alt="MovieCardPage-2" src="https://github.com/user-attachments/assets/644c06d8-384e-47eb-83a8-4903a1954d6b" />
<img width="200" height="450" alt="FavoritesPage-3" src="https://github.com/user-attachments/assets/4219bf6d-53f7-4623-bdc8-a2a7a704cade" />
</p>


=======
>>>>>>> main
## 📋 Requirements

- Xcode 16.4+
- iOS 18.5+
- Swift 5.0+
- Internet connection for movie data

## 🚀 Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/Filmly.git
   cd Filmly
   ```

2. **Open in Xcode**
   ```bash
   open Filmly.xcodeproj
   ```

3. **Build and Run**
   - Select your target device or simulator
   - Press `Cmd + R` to build and run the app

## 🎯 Usage

### Browsing Movies
- The app opens to a curated list of trending movies
- Scroll through the movie grid to discover new films
- Tap any movie card to view detailed information

### Searching
- Use the search bar at the top to find specific movies
- Search results update in real-time as you type
- Clear the search to return to the main movie list

### Filtering
- Tap the "Filters" button to access advanced filtering options
- Filter by:
  - Year range (1980-2025)
  - Rating range (0-10)
  - Genres (Action, Comedy, Drama, etc.)
  - Countries (US, UK, France, etc.)
- Apply filters to see personalized movie recommendations

### Favorites
- Tap the heart icon on any movie to add it to favorites
- Access your favorites via the heart button in the navigation bar
- View favorites count in the navigation button
- Use "Clear All" to remove all favorites at once

### Surprise Me
- Tap "Surprise Me" to get a random movie recommendation
- Perfect for when you can't decide what to watch

## 📁 Project Structure

```
Filmly/
├── Filmly/
│   ├── FilmlyApp.swift          # Main app entry point
│   ├── ContentView.swift        # Main content view
│   ├── Models/                  # Data models
│   │   ├── Movie.swift
│   │   ├── Credits.swift
│   │   ├── Video.swift
│   │   └── Recommendation.swift
│   ├── Services/                # Business logic and API calls
│   │   ├── MovieService.swift
│   │   ├── MovieDetailService.swift
│   │   ├── FavoritesManager.swift
│   │   └── NetworkMonitor.swift
│   ├── Views/                   # UI components
│   │   ├── MovieCardView.swift
│   │   ├── MovieDetailView.swift
│   │   ├── FavoritesView.swift
│   │   └── FilterView.swift
│   └── Assets.xcassets/         # App icons and assets
└── Filmly.xcodeproj/           # Xcode project file
```

## 🔧 Configuration

### API Key Setup
The app uses The Movie Database (TMDB) API. The API key is currently hardcoded in the service files. For production use, consider:

1. **Environment Variables**: Store API keys in environment variables
2. **Configuration Files**: Use a separate configuration file
3. **Key Management**: Implement secure key management

### Customization
- **App Icon**: Replace icons in `Assets.xcassets/AppIcon.appiconset/`
- **Colors**: Modify accent colors in `Assets.xcassets/AccentColor.colorset/`
- **UI**: Customize SwiftUI views in the `Views/` directory

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

### Data Sources
- **Movie Data**: [The Movie Database (TMDB)](https://www.themoviedb.org/)
- **Trailers**: YouTube (via TMDB API)

### API Attribution
This product uses the TMDB API but is not endorsed or certified by TMDB. Movie data and trailer links are provided by TMDB and sourced from official YouTube channels.

### Icons and Assets
- SF Symbols (Apple's built-in icon system)
- Custom app icons and assets

## 🔮 Future Enhancements

- [ ] Cloud sync for favorites
- [ ] Watchlist functionality
- [ ] Movie recommendations based on viewing history
- [ ] Push notifications for new releases
- [ ] Social sharing features
- [ ] Offline movie data caching

---

**Made with ❤️ using SwiftUI** 
