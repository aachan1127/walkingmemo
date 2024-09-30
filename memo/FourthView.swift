import SwiftUI

struct FourthView: View {
    var selectedTodo: Todo // ThirdViewから渡される選択されたTodo
    
    @State var isShowSixthView = false
    @State private var userInput: String = "" //テキスト入力の状態変数
    
    var body: some View {
        NavigationStack {
            VStack {
                NavigationLink {
                    FifthView()
                } label: {
                    //FifthViewへナビ遷移
                    Text("次へ")
                }
                
                //                //SixthViewへモーダル遷移
                //                Button("AIに考え方のヒントをもらう") {
                //                    isShowSixthView = true
                //                }
                //                .padding()
                //                .sheet(isPresented: $isShowSixthView) {
                //                    SixthView()
                //                }
                
                ZStack {
                    Color.pink
                        .ignoresSafeArea()
                    
                    VStack {
                        //                        // selectedTodoの内容を表示
                        Text("選択された項目: \(selectedTodo.value)")
                            .font(.title)
                            .foregroundColor(.white)
                        
                        //テキストフィールドの追加
                        TextField("違う見方を入力", text: $userInput)
                            .textFieldStyle(RoundedBorderTextFieldStyle()) //ボーダー付きスタイル
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .padding()
                        
                        
                        //SixthViewへモーダル遷移
                        Button("AIに考え方のヒントをもらう") {
                            isShowSixthView = true
                        }
                        .padding()
                        .sheet(isPresented: $isShowSixthView) {
                            SixthView()
                        }
                    }
                }
            }
            .navigationTitle("画面4")
        }
    }
}

struct FourthView_Previews: PreviewProvider {
    static var previews: some View {
        FourthView(selectedTodo: Todo(id: UUID(), value: "サンプルデータ"))
    }
}
