import Foundation

struct Finedust: Codable {
    let response: FinedustResponse
}

struct FinedustResponse: Codable {
    let body: FinedustBody
}

struct FinedustBody: Codable {
    let items: [FinedustItem]
}
struct FinedustItem: Codable {
    let stationName: String
    let pm10Value: String
}
