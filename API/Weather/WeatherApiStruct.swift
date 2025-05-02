import Foundation

struct WeatherResponse: Codable {
    let response: Response
}

struct Response: Codable {
    let header: Header
    let body: Body
}

struct Header: Codable {
    let resultCode: String
    let resultMsg: String
}

struct Body: Codable {
    let dataType: String
    let items: Items
}

struct Items: Codable {
    let item: [WeatherItem]
}

struct WeatherItem: Codable {
    let baseDate: String
    let baseTime: String
    let category: String
    let nx: Int
    let ny: Int
    let obsrValue: String
}
