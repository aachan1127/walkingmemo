import SwiftUI
struct FourthView: View {
    var selectedTodo: Todo
    
    @State var isShowSixthView = false
    
    var body: some View {
        VStack {
            Text("選択された項目: \(selectedTodo.value)")
                .font(.title)
                .foregroundColor(.white)
            
            Button("AIに相談") {
                isShowSixthView = true
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            
            // SixthViewへモーダル遷移
            .sheet(isPresented: $isShowSixthView) {
                SixthView(selectedTodo: selectedTodo) // selectedTodoを渡す
                    .presentationDetents([.medium, .large]) // ハーフモーダルに設定
                    .presentationDragIndicator(.visible) // ドラッグインジケーターを表示
                
            }
        }
        .padding()
        .background(Color.pink.ignoresSafeArea())
    }
}
