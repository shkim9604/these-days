import Foundation

class WeatherViewModel: ObservableObject {
    @Published var weatherItems: [WeatherItem] = []
    
    // PTY, T1H만 필터링해서 노출
    var filteredItems: [WeatherItem] {
        weatherItems.filter { $0.category == "PTY" || $0.category == "T1H" }
    }
    
    func fetchWeather() {
    let now = Date()
    let calendar = Calendar.current

    let hour = calendar.component(.hour, from: now)
    let minute = calendar.component(.minute, from: now)

    var baseDate: String
    var baseTime: String

    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "ko_KR")
    dateFormatter.dateFormat = "yyyyMMdd"

    if minute < 10 {
        // 10분 이전이면 1시간 전 + 55분으로 설정
        let adjustedDate = calendar.date(byAdding: .hour, value: -1, to: now)!
        let adjustedHour = calendar.component(.hour, from: adjustedDate)
        baseDate = dateFormatter.string(from: adjustedDate)
        baseTime = String(format: "%02d55", adjustedHour)
    } else {
        // 10분 이후면 현재 시각 그대로
        baseDate = dateFormatter.string(from: now)
        baseTime = String(format: "%02d%02d", hour, minute)
    }

        let servicekey = "apikey"
        guard let url = URL(string: "http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtNcst?serviceKey=\(servicekey)&pageNo=1&numOfRows=5&dataType=json&base_date=\(baseDate)&base_time=\(baseTime)&nx=55&ny=127") else {
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
            
            //응답에러
            if let raw = String(data: data, encoding: .utf8) {
                print("응답 원문:\n\(raw.prefix(300))")
                if raw.hasPrefix("<") {
                    print("HTML 에러 응답입니다.")
                    return
                }
            }

            do {
                let decoded = try JSONDecoder().decode(WeatherResponse.self, from: data)
                DispatchQueue.main.async {
                    self.weatherItems = decoded.response.body.items.item
                }
            } catch {
                print("파싱 실패: \(error)")
            }
        }.resume()
    }
}
