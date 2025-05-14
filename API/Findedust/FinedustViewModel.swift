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
            
            //응답에러
            if let raw = String(data: data, encoding: .utf8) {
                print("응답 원문:\n\(raw.prefix(300))")
                if raw.hasPrefix("<") {
                    print("HTML 에러 응답입니다.")
                    return
                }
            }


            do {
                let decoded = try JSONDecoder().decode(Finedust.self, from: data)
                DispatchQueue.main.async {
                    self.finedustitems = decoded.response.body.items
                }
            } catch {
                print("미세먼지 파싱실패: \(error)")
            }
        }.resume()
    }
}

