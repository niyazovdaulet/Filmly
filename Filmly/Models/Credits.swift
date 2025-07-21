import Foundation

struct CreditsResponse: Codable {
    let cast: [CastMember]
    let crew: [CrewMember]
}

struct CastMember: Codable, Identifiable {
    let id: Int
    let name: String
    let character: String?
    let profilePath: String?
    let order: Int?
    
    enum CodingKeys: String, CodingKey {
        case id, name, character, order
        case profilePath = "profile_path"
    }
    
    var profileURL: URL? {
        guard let path = profilePath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w185\(path)")
    }
}

struct CrewMember: Codable, Identifiable {
    let id: Int
    let name: String
    let job: String?
    let department: String?
    let profilePath: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, job, department
        case profilePath = "profile_path"
    }
    
    var profileURL: URL? {
        guard let path = profilePath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w185\(path)")
    }
} 
