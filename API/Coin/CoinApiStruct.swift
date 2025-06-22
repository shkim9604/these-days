import Foundation

struct CoinResponse: Codable {
    let name: String
    let rank: Int
    let quotes: Quotes

    struct Quotes: Codable {
        let KRW: KRWQuote

        struct KRWQuote: Codable {
            let price: Double
            let percent_change_24h: Double
        }
    }
}
