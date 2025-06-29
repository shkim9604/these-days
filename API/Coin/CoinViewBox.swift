import SwiftUI

struct CoinBoxView: View {
    let coins: [CoinResponse]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("💰 코인 시세")
                .font(.headline)
                .padding(.leading, 4)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(coins.prefix(10), id: \.rank) { coin in
                        VStack(alignment: .leading, spacing: 6) {
                            Text("\(coin.rank)위")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(coin.name)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("₩\(Int(coin.quotes.KRW.price))")
                                .font(.body)
                            HStack(spacing: 4) {
                                let change = coin.quotes.KRW.percent_change_24h
                                let color: Color = change >= 0 ? .red : .blue
                                let arrow = change >= 0 ? "arrow.up" : "arrow.down"
                                Image(systemName: arrow)
                                    .foregroundColor(color)
                                Text("\(String(format: "%.2f", change))%")
                                    .foregroundColor(color)
                            }
                        }
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                        .frame(width: .infinity, alignment: .leading)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding(.vertical)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
