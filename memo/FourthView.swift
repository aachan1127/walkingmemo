import SwiftUI

struct FourthView: View {
    var selectedTodo: Todo
    
    @State var isShowSixthView = false
    @State var inputDetail = "" // 1つ目の入力フィールド用
    @State var inputEmotion = "" // 2つ目の入力フィールド用
    @State var inputPositiveThought = "" // 3つ目の入力フィールド用
    
    var body: some View {
        ScrollView { // ScrollViewで全体をラップする
            VStack {
                // FifthViewへのナビゲーションリンクを追加
                NavigationLink(destination: FifthView()) {
                    Text("FifthViewへ進む")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Text("選択された項目: \(selectedTodo.value)")
                    .font(.title)
                    .foregroundColor(.gray)
                
                TextField("選択した項目についての詳細を記入", text: $inputDetail)
                    .padding()
                    .background(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                
                Text("その時どういう感情になりましたか？")
                    .padding(EdgeInsets(top: 50, leading: 20, bottom: 10, trailing: 20))
                
                TextField("不安、悲しみ、怒り、無力感など。", text: $inputEmotion)
                    .padding()
                    .background(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                
                Image(systemName: "arrowshape.down.fill")
                    .padding()
                    .font(Font.system(size: 60))
                
                Text("この感情に対して、どのように考え直しますか？")
                
                TextField("前向きな考えを記入してみよう。", text: $inputPositiveThought)
                    .padding()
                    .background(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                
                Button("AIに考え方のヒントをもらう") {
                    isShowSixthView = true
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding()
                
                .sheet(isPresented: $isShowSixthView) {
                    SixthView(selectedTodo: selectedTodo, inputDetail: inputDetail, inputEmotion: inputEmotion)
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.visible)
                }
            }
            .padding()
            .background(Color.white.ignoresSafeArea())
        }
    }
}

#Preview {
    FourthView(selectedTodo: Todo(id: UUID(), value: "サンプルTodo", date: Date()))
}
