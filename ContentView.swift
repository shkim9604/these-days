import SwiftUI

struct ContentView: View {
    @StateObject private var weatherViewModel = WeatherViewModel()
    @StateObject private var movieViewModel = MovieViewModel()
    @StateObject private var exchangerateViewModel = ExchangeRateViewModel()
    @StateObject private var finedustViewModel = FinedustViewModel()
    @StateObject private var coinViewModel = CoinViewModel()
    // 현재 메인 관심사
    @State private var mainInterest: String = "날씨"
    
    // 기타 관심사 리스트
    @State private var interests = ["영화순위", "미세먼지", "환율", "코인시세", "기타2"]
    
    // 팝업 띄우기 여부
    @State private var showPopup = false
    
    // 선택한 관심사
    @State private var selectedInterest: String? = nil
    
    // 확인 모달 띄우기 여부
    @State private var showConfirmation = false
    
    //관심사API전부호출
    func runInterestAction(for interest: String) {
        let actions: [String: () -> Void] = [
            "날씨": { weatherViewModel.fetchWeather()
                    weatherViewModel.fetchMainforecast()
                    weatherViewModel.fetchTmnTmxForecast() },
            "영화순위": { movieViewModel.fetchmovie() },
            "환율": {exchangerateViewModel.fetchrate()},
            "미세먼지": {finedustViewModel.fetchFinedust()},
            "코인시세": {coinViewModel.fetchcoin()}
            // 필요시 추가
        ]
        actions[interest]?()
    }

    func weatherDescriptionAndIcon(for code: String) -> (String, String) {
        switch code {
        case "0": return ("없음", "sun.max.fill")
        case "1": return ("비", "cloud.rain.fill")
        case "2": return ("비/눈", "cloud.sleet.fill")
        case "3": return ("눈", "cloud.snow.fill")
        case "5": return ("빗방울", "cloud.drizzle.fill")
        case "6": return ("빗방울눈날림", "cloud.snow.fill")
        case "7": return ("눈날림", "snowflake")
        default: return ("-", "questionmark")
        }
    }

    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                // 메인 관심사 박스
                Rectangle()
                    .stroke(Color.blue, lineWidth: 1)
                    .frame(height: 150)
                    .overlay(
                        VStack(alignment: .leading,spacing: 8) {

                            if mainInterest == "날씨" {
                                WeatherBoxView(
                                    temp: weatherViewModel.filteredItems.first { $0.category == "T1H" }?.obsrValue ?? "-",
                                    time: DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .short),
                                    pty: weatherViewModel.filteredItems.first { $0.category == "PTY" }?.obsrValue ?? "-",
                                    pop: weatherViewModel.forecastFilteredItems.first { $0.category == "POP" }?.fcstValue ?? "-",
                                    reh: weatherViewModel.filteredItems.first { $0.category == "REH" }?.obsrValue ?? "-",
                                    tmn: weatherViewModel.forecastItems.first { $0.category == "TMN" }?.fcstValue ?? "-",
                                    tmx: weatherViewModel.forecastItems.first { $0.category == "TMX" }?.fcstValue ?? "-"
                                )
                            }
                            if mainInterest == "영화순위" {
                                MovieBoxView(movies: movieViewModel.movieinfos)
                            }
                            if mainInterest == "환율" {
                                ForEach(exchangerateViewModel.filterdItems, id: \.cur_unit) { item in 
                                    Text("\(item.cur_nm): \(item.deal_bas_r)")    
                                }
                            }
                            if mainInterest == "미세먼지" {
                                ForEach(finedustViewModel.filteredItems, id: \.stationName) {item in 
                                    Text("\(item.stationName): \(item.pm10Value)")    
                                }
                            }
                            if mainInterest == "코인시세" {
                                CoinBoxView(coins: coinViewModel.filterdItems)
                            }
                        }
                    )
                
                // 새로고침 + 재설정 버튼
                HStack {
                    Button(action: {
                        weatherViewModel.fetchWeather()
                        weatherViewModel.fetchMainforecast()
                        weatherViewModel.fetchTmnTmxForecast()
                        movieViewModel.fetchmovie()
                        exchangerateViewModel.fetchrate()
                        finedustViewModel.fetchFinedust()
                        print("새로고침")
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.green)
                    }
                    Spacer()
                    Button(action: {
                        showPopup = true
                    }) {
                        Text("재설정")
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.orange)
                            .cornerRadius(6)
                    }
                }
                
                // 기타 관심사 리스트 (날씨 제외)
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(interests, id: \.self) { item in
                            VStack(alignment: .leading) {
                                Text(item)
                                    .bold()
                                
                                if item == "날씨" {
                                    let temp = weatherViewModel.filteredItems.first { $0.category == "T1H" }?.obsrValue ?? "-"
                                    let reh = weatherViewModel.filteredItems.first { $0.category == "REH" }?.obsrValue ?? "-"
                                    let pty = weatherViewModel.filteredItems.first { $0.category == "PTY" }?.obsrValue ?? "-"
                                    
                                    let ptyText = WeatherBoxView.weatherDescriptionAndIcon(for: pty).0
                                    
                                    Text("기온: \(temp)℃ / 습도: \(reh)% / 강수: \(ptyText)")
                                        .font(.system(size: 21))
                                        .frame(maxWidth: .infinity,alignment: .leading)
                                }
                                if item == "영화순위" {
                                    ForEach(movieViewModel.filteredItems, id: \.rank) {movieitem in 
                                        Text("\(movieitem.rank) ~~ \(movieitem.movieNm)")  
                                    }
                                }
                                if item == "환율" {
                                    ForEach(exchangerateViewModel.filterdItems, id: \.cur_unit) {rateitem in
                                        Text("\(rateitem.cur_unit): \(rateitem.deal_bas_r)")    
                                    }
                                }
                                if item == "미세먼지" {
                                    ForEach(finedustViewModel.filteredItems, id: \.stationName) {item in 
                                        Text("\(item.stationName): \(item.pm10Value)")    
                                    }
                                }
                                if item == "코인시세" {
                                    ForEach(coinViewModel.filteredItems, id: \.rank) {item in 
                                        Text("\(item.rank): \(item.name)")    
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, minHeight: 75)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.blue, lineWidth: 1)
                            )
                        }
                    }
                }
            }
            .padding()
            
            // 팝업창
            if showPopup {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 16) {
                    HStack {
                        Spacer()
                        Button(action: {
                            showPopup = false
                            selectedInterest = nil
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.black)
                                .padding()
                        }
                    }
                    
                    LazyVGrid(columns: [GridItem(), GridItem()], spacing: 16) {
                        ForEach(interests, id: \.self) { item in
                            Button(action: {
                                selectedInterest = item
                            }) {
                                Text(item)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(selectedInterest == item ? Color.blue : Color.clear)
                                    .foregroundColor(selectedInterest == item ? Color.yellow : Color.black)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.black, lineWidth: 1)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        if selectedInterest != nil {
                            showConfirmation = true
                        }
                    }) {
                        Text("확인")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: 200)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    
                    Spacer()
                }
                .padding()
                .frame(width: 300, height: 400)
                .background(Color(UIColor.systemGray5))
                .cornerRadius(12)
            }
        }
        .onAppear {
            runInterestAction(for: mainInterest)
            for interest in interests {
                runInterestAction(for: interest)
            }
        }
        .alert(isPresented: $showConfirmation) {
            Alert(
                title: Text("최대관심사를 바꾸시겠습니까?"),
                primaryButton: .default(Text("예"), action: {
                    if let selected = selectedInterest {
                        if let index = interests.firstIndex(of: selected) {
                            // 1. 기존 메인 관심사를 교환
                            interests[index] = mainInterest
                            // 2. 메인 관심사 변경
                            mainInterest = selected
                            
                            // 3. 새로 메인 관심사가 "날씨"라면 API 다시 호출
                            runInterestAction(for: mainInterest)
                        }
                    }
                    showPopup = false
                }),
                secondaryButton: .cancel(Text("아니요"), action: {
                    // 팝업 유지
                })
            )
        }
    }
}

#Preview {
    ContentView()
}
