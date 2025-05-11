import Foundation

class ExchangeRateViewModel: ObservableObject {
    @Published var exchangerate: [ExchangeRateResponse] = []
    
    var filterdItems: [ExchangeRateResponse] {
        exchangerate.filter { $0.cur_unit == "USD"}
    }
    
    func fetchrate() {
        let baseDate = "20250509"
        let servicekey = "apikey"
        guard let url = URL(string: "http://www.koreaexim.go.kr/site/program/financial/exchangeJSON?authkey=\(servicekey)&data=AP01&searchdate=\(baseDate)") else {
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
                let decoded = try JSONDecoder().decode([ExchangeRateResponse].self, from: data)
                DispatchQueue.main.async {
                    self.exchangerate = decoded
                }
            } catch {
                print("환율파싱 실패: \(error)")
            }
        }.resume()
    }
}
