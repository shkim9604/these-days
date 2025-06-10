import Foundation

class WeatherViewModel: ObservableObject {
    @Published var weatherItems: [WeatherItem] = []
    @Published var forecastItems: [ForecastItem] = []
    // PTY, T1H만 필터링해서 노출
    var filteredItems: [WeatherItem] {
        weatherItems.filter { $0.category == "PTY" || $0.category == "T1H" || $0.category == "REH" }
    }
    
    var forecastFilteredItems: [ForecastItem] {
        // 현재 시각 구하기
        let now = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: now)
        
        // 현재 시각 기준 정각 시간 만들기 (예: 15 → "1500")
        let targetFcstTime = String(format: "%02d00", hour)
        
        // 사용할 카테고리
        let targetCategories = ["POP", "PTY"]
        
        // 조건에 맞는 항목만 필터링
        return forecastItems.filter { item in
            item.fcstTime == targetFcstTime && targetCategories.contains(item.category)
        }
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
        //print(baseDate)
        //print(baseTime)
        let nx = 67
        let ny = 100
        let servicekey = "apikey"
        guard let url = URL(string: "http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtNcst?serviceKey=\(servicekey)&pageNo=1&numOfRows=5&dataType=json&base_date=\(baseDate)&base_time=\(baseTime)&nx=\(nx)&ny=\(ny)") else {
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
            
            // 응답 원문 확인 (중요)
            if let raw = String(data: data, encoding: .utf8) {
                //print("💬 초단기실황응답 원문:\n\(raw.prefix(300))") // 길이 제한
                if raw.hasPrefix("<") {
                    print("⚠️ 날씨HTML 에러 응답입니다.")
                    return
                }
            }
            
            do {
                let decoded = try JSONDecoder().decode(WeatherResponse.self, from: data)
                DispatchQueue.main.async {
                    self.weatherItems = decoded.response.body.items.item
                }
            } catch {
                print("날씨파싱 실패: \(error)")
            }
        }.resume()
    }
    
    func fetchMainforecast() {
        let now = Date()
        let calendar = Calendar.current
        
        let baseHours = [2, 5, 8, 11, 14, 17, 20, 23]
        let currentHour = calendar.component(.hour, from: now)
        let currentMinute = calendar.component(.minute, from: now)
        
        var baseDate = ""
        var baseTime = ""
        
        // 00:00 ~ 02:10 이전이면 전날 23시 데이터 사용
        if currentHour < 2 || (currentHour == 2 && currentMinute < 10) {
            let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd"
            baseDate = formatter.string(from: yesterday)
            baseTime = "2300"
        } else {
            // 가장 가까운 발표 시각 찾기
            var selectedHour = 2
            for hour in baseHours {
                let releaseTime = calendar.date(bySettingHour: hour, minute: 10, second: 0, of: now)!
                if now >= releaseTime {
                    selectedHour = hour
                } else {
                    break
                }
            }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd"
            baseDate = formatter.string(from: now)
            baseTime = String(format: "%02d00", selectedHour)
        }
        //print(baseDate)
        //print(baseTime)
        let nx = 67
        let ny = 100
        let servicekey = "apikey"
        guard let url = URL(string: "http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst?serviceKey=\(servicekey)&pageNo=1&numOfRows=200&dataType=json&base_date=\(baseDate)&base_time=\(baseTime)&nx=\(nx)&ny=\(ny)") else {
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
            
            // 응답 원문 확인 (중요)
            if let raw = String(data: data, encoding: .utf8) {
                //print("💬 단기예보응답 원문:\n\(raw.prefix(300))") // 길이 제한
                if raw.hasPrefix("<") {
                    print("⚠️ 날씨HTML 에러 응답입니다.")
                    return
                }
            }
            
            do {
                let decoded = try JSONDecoder().decode(ShortForecastResponse.self, from: data)
                DispatchQueue.main.async {
                    self.forecastItems = decoded.response.body.items.item
                }
            } catch {
                print("날씨파싱 실패: \(error)")
            }
        }.resume()
    }
    func fetchTmnTmxForecast() {
        let now = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: now)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        
        let baseDate: String
        if hour < 2 {
            let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
            baseDate = dateFormatter.string(from: yesterday)
        } else {
            baseDate = dateFormatter.string(from: now)
        }
        let nx = 67
        let ny = 100
        let baseTime = "0200"
        let servicekey = "apikey"
        guard let url = URL(string: "http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst?serviceKey=\(servicekey)&pageNo=1&numOfRows=100&dataType=json&base_date=\(baseDate)&base_time=\(baseTime)&nx=\(nx)&ny=\(ny)") else {
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
            
            if let raw = String(data: data, encoding: .utf8) {
                //print("💬 최저최고기온 응답원문:\n\(raw.prefix(300))") // 길이 제한
                if raw.hasPrefix("<") {
                    print("⚠️ 날씨HTML 에러 응답입니다.")
                    return
                }
            }
            
            do {
                let decoded = try JSONDecoder().decode(ShortForecastResponse.self, from: data)
                DispatchQueue.main.async {
                    self.forecastItems += decoded.response.body.items.item
                }
            } catch {
                print("TMN/TMX 파싱 실패: \(error)")
            }
        }.resume()
    }
}
