import SwiftUI

struct ContentView: View {
    // 현재 메인 관심사
    @State private var mainInterest: String = "날씨"
    
    // 기타 관심사 리스트
    @State private var interests = ["영화순위", "주가지수", "환율", "기타1", "기타2"]
    
    // 팝업 띄우기 여부
    @State private var showPopup = false
    
    // 선택한 관심사
    @State private var selectedInterest: String? = nil
    
    // 확인 모달 띄우기 여부
    @State private var showConfirmation = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                // 메인 관심사 박스
                Rectangle()
                    .stroke(Color.blue, lineWidth: 1)
                    .frame(height: 150)
                    .overlay(
                        Text("최대관심사(\(mainInterest))")
                            .foregroundColor(.black)
                            .font(.headline)
                    )
                
                // 새로고침 + 재설정 버튼
                HStack {
                    Button(action: {
                        print("새로고침")
                    }) {
                        Image(systemName: "repeat")
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
                
                // 기타 관심사 리스트
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(interests, id: \.self) { item in
                            Text(item)
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
                    
                    // 관심사 선택 리스트
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
                    
                    // 확인 버튼
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
        // 알림창(Confirmation)
        .alert(isPresented: $showConfirmation) {
            Alert(
                title: Text("최대관심사를 바꾸시겠습니까?"),
                primaryButton: .default(Text("예"), action: {
                    if let selected = selectedInterest {
                        if let index = interests.firstIndex(of: selected) {
                            // 1. 기존 메인 관심사로 선택된 항목 자리 덮어쓰기
                            interests[index] = mainInterest
                            
                            // 2. 메인 관심사를 선택된 항목으로 변경
                            mainInterest = selected
                        }
                    }
                    showPopup = false // 팝업 닫기
                }),
                secondaryButton: .cancel(Text("아니요"), action: {
                    // 그냥 알림창만 닫기, 팝업은 유지
                })
            )
        }
    }
}

#Preview {
    ContentView()
}

