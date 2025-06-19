import SwiftUI

struct MovieBoxView: View {
    let movies: [MovieItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("🎬 일일박스오피스")
                .font(.headline)
                .padding(.leading, 4)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(movies.prefix(10), id: \.rank) { movie in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(movie.rank)위")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(movie.movieNm)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .lineLimit(1)
                            Text("누적: \(movie.audiCnt)명")
                            Text("당일: \(movie.audiAcc)명")
                        }
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(8)
                        .frame(width: .infinity, alignment: .leading) // 영화 하나당 박스 크기
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding(.vertical)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
