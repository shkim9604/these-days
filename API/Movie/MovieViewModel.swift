import Foundation

class MovieViewModel: ObservableObject {
    @Published var movieinfos: [MovieList] = []
    
    
    var filteredItems: [MovieList] {
        movieinfos.filter { $0.rank == "1" || $0.rank == "2" }
    }
    func fetchmovie() {
        let now = Date()
        let yesterday = Calendar.current.date(byAdding: .day,value: -1 ,to: now)!
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyyMMdd"
        let baseDate = formatter.string(from: yesterday)
        let servicekey = "apikey"
        guard let url = URL(string: "http://kobis.or.kr/kobisopenapi/webservice/rest/boxoffice/searchDailyBoxOfficeList.json?key=\(servicekey)&targetDt=\(baseDate)") else {
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
                let decoded = try JSONDecoder().decode(MovieResponse.self, from: data)
                DispatchQueue.main.async {
                    self.movieinfos = decoded.boxOfficeResult.dailyBoxOfficeList
                }
            } catch {
                print("영화파싱 실패: \(error)")
            }
        }.resume()
    }
}

