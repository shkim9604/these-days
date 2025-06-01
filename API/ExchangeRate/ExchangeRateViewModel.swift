import Foundation

class ExchangeRateViewModel: ObservableObject {
    @Published var exchangerate: [ExchangeRateResponse] = []
    
    var filterdItems: [ExchangeRateResponse] {
        exchangerate.filter { $0.cur_unit == "USD"}
    }
    
    private func getLatestExchangeDate() -> String {
        let now = Date()
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: now) // 1: 일요일, 2: 월요일, ..., 7: 토요일
        let hour = calendar.component(.hour, from: now)
        
        var daysToSubtract = 0

        switch weekday {
        case 1: // 일요일
            daysToSubtract = 2
        case 2: // 월요일
            daysToSubtract = hour < 11 ? 3 : 0
        case 7: // 토요일
            daysToSubtract = 1
        default: // 화~금
            daysToSubtract = hour < 11 ? 1 : 0
        }

        let targetDate = Calendar.current.date(byAdding: .day, value: -daysToSubtract, to: now)!

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter.string(from: targetDate)
    }



    func fetchrate() {
        let baseDate = getLatestExchangeDate()
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
