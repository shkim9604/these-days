import Foundation

class FinedustViewModel: ObservableObject {
    @Published var finedustitems: [FinedustItem] = []
    
    // PTY, T1H만 필터링해서 노출
    var filteredItems: [FinedustItem] {
        finedustitems.filter { $0.stationName == "둔산동" }
    }
    
    func fetchFinedust() {
        let servicekey = "apikey"
        guard let url = URL(string: "http://apis.data.go.kr/B552584/ArpltnInforInqireSvc/getCtprvnRltmMesureDnsty?serviceKey=\(servicekey)&returnType=json&numOfRows=100&pageNo=1&sidoName=대전&ver=1.0") else {
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
                let decoded = try JSONDecoder().decode(FinedustResponse.self, from: data)
                DispatchQueue.main.async {
                    self.finedustitems = decoded.body.items
                }
            } catch {
                print("날씨파싱 실패: \(error)")
            }
        }.resume()
    }
}

