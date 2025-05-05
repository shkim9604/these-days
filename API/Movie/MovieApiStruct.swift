import Foundation

struct MovieResponse: Codable {
    let boxOfficeResult: BoxOfficeResult
}

struct BoxOfficeResult: Codable {
    let boxofficeType: String
    let showRange: String
    let dailyBoxOfficeList: [MovieList]
}

struct MovieList: Codable {
    let rank: String
    let movieNm: String
}
