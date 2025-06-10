import Foundation

struct WeatherResponse: Codable {
    let response: Response
}

struct ShortForecastResponse: Codable {
    let response: ForecastResponse
}

struct Response: Codable {
    let body: Body
}

struct ForecastResponse: Codable {
    let body: ForecastBody
}

struct Body: Codable {
    let dataType: String
    let items: Items
}

struct ForecastBody: Codable {
    let items: ForecastItems
}

struct Items: Codable {
    let item: [WeatherItem]
}

struct ForecastItems: Codable {
    let item: [ForecastItem]
}

struct WeatherItem: Codable {
    let baseDate: String
    let baseTime: String
    let category: String
    let nx: Int
    let ny: Int
    let obsrValue: String
}

struct ForecastItem: Codable {
    let baseDate: String
    let baseTime: String
    let category: String
    let fcstDate: String
    let fcstTime: String
    let fcstValue: String
}
