import SwiftUI

struct WeatherBoxView: View {
    let temp: String
    let time: String
    let pty: String
    
    var body: some View {
        let (ptyText, icon) = weatherDescriptionAndIcon(for: pty)
        
        VStack(alignment: .leading, spacing: 0) {
            Text("시간: \(time)")
                .font(.system(size: 20))
            Spacer()

            Text("기온: \(temp)℃")
                .font(.system(size: 20))

            Spacer()
            HStack(spacing: 8) {
                Text("강수형태:")
                    .font(.system(size: 20))
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .font(.system(size: 22))
                Text(ptyText)
                    .font(.system(size: 20))
                
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
}