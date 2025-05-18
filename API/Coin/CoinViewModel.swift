import Foundation

class CoinViewModel: ObservableObject {
    @Published var coin: [CoinResponse] = []
    
    var filterdItems: [CoinResponse] {
        coin.filter { $0.rank == 1 || $0.rank == 2}
    }
    
    func fetchcoin() {
        guard let url = URL(string: "http://api.coinpaprika.com/v1/tickers?quotes=KRW") else {
            print("잘못된 URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("에러 발생: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("데이터 없음")
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode([CoinResponse].self, from: data)
                DispatchQueue.main.async {
                    self.coin = decoded
                }
            } catch {
                print("환율파싱 실패: \(error)")
            }
        }.resume()
    }
}
