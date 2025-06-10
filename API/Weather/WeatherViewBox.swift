import SwiftUI

struct WeatherBoxView: View {
    let temp: String
    let time: String
    let pty: String
    let pop: String
    let reh: String  // 습도(REH) 추가
    let tmn: String // 최저기온
    let tmx: String // 최고기온
    var body: some View {
        let (ptyText, iconName) = WeatherBoxView.weatherDescriptionAndIcon(for: pty)
        
        HStack {
            VStack(alignment: .leading, spacing: 12) {
                //Text("시간: \(time)")
                    //.font(.system(size: 20))
                //Text("기온: \(temp)℃")
                    //.font(.system(size: 20))
                Text("최저기온: \(tmn)℃")
                    .font(.system(size: 20))
                Text("최고기온: \(tmx)℃")
                    .font(.system(size: 20))
                Text("습도: \(reh)%")
                    .font(.system(size: 20))
                Text("강수확률: \(pop)")
                    .font(.system(size: 20))
            }
            
            Spacer()
            
            // 강수형태 아이콘 (높이를 부모 뷰에 맞게 조정)
            Image(systemName: iconName)
                .resizable()
                .scaledToFit()
                .frame(height: 80) // 필요 시 조정 (또는 .frame(maxHeight: .infinity))
                .foregroundColor(.blue)
                .padding(.trailing)
        }
        .padding(.vertical)
        .frame(maxWidth: .infinity)
    }
    
   static func weatherDescriptionAndIcon(for code: String) -> (String, String) {
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
}
