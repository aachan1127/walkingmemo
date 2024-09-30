import SwiftUI

struct SecondView: View {
    var currentTodos: [Todo] // リストデータを受け取るためのプロパティを追加
    
    // カテゴリ別のデータを保持する配列
    @State private var taskTodos: [Todo] = []
    @State private var positiveTodos: [Todo] = []
    @State private var negativeTodos: [Todo] = []
    @State private var otherTodos: [Todo] = [] // 「その他」に分類されるTodo
    
    // カスタマイズされたカテゴリ名
    @AppStorage("taskCategory") var taskCategory: String = "タスク"
    @AppStorage("positiveCategory") var positiveCategory: String = "ポジティブ"
    @AppStorage("negativeCategory") var negativeCategory: String = "ネガティブ"
    
    @State private var showSettings = false // 設定画面を表示するためのフラグ

    var body: some View {
        NavigationStack {
            VStack {
                // 「次へ」ボタンを追加し、押すと ThirdView に全てのデータを渡して遷移
                NavigationLink(destination: ThirdView(currentTodos: currentTodos)) {
                    Text("次へ")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()

                ZStack {
                    Color.green
                        .ignoresSafeArea()

                    // 分類したカテゴリ別にリスト表示
                    VStack {
                        // タスクカテゴリ
                        if !taskTodos.isEmpty {
                            Text(taskCategory)
                                .font(.headline)
                                .padding(.top)
                            List(taskTodos, id: \.id) { todo in
                                Text(todo.value)
                            }
                            .frame(height: 150)
                        }

                        // ポジティブカテゴリ
                        if !positiveTodos.isEmpty {
                            Text(positiveCategory)
                                .font(.headline)
                                .padding(.top)
                            List(positiveTodos, id: \.id) { todo in
                                Text(todo.value)
                            }
                            .frame(height: 150)
                        }

                        // ネガティブカテゴリ
                        if !negativeTodos.isEmpty {
                            Text(negativeCategory)
                                .font(.headline)
                                .padding(.top)
                            List(negativeTodos, id: \.id) { todo in
                                Text(todo.value)
                            }
                            .frame(height: 150)
                        }

                        // その他カテゴリ
                        if !otherTodos.isEmpty {
                            Text("その他")
                                .font(.headline)
                                .padding(.top)
                            List(otherTodos, id: \.id) { todo in
                                Text(todo.value)
                            }
                            .frame(height: 150)
                        }
                    }
                }
            }
            .navigationTitle("画面2")
            .toolbar {
                // 右上に設定ボタンを追加
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showSettings.toggle()
                    }) {
                        Image(systemName: "gearshape.fill")
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingView()
            }
            .onAppear {
                // 各カテゴリの配列を初期化
                taskTodos = []
                positiveTodos = []
                negativeTodos = []
                otherTodos = []
                
                // currentTodos をループして、各カテゴリに分類
                for todo in currentTodos {
                    if todo.value.hasPrefix(taskCategory) {
                        taskTodos.append(todo)
                    } else if todo.value.hasPrefix(positiveCategory) {
                        positiveTodos.append(todo)
                    } else if todo.value.hasPrefix(negativeCategory) {
                        negativeTodos.append(todo)
                    } else {
                        // どのカテゴリにも該当しない場合は「その他」に追加
                        otherTodos.append(todo)
                    }
                }
            }
        }
    }
}

struct SecondView_Previews: PreviewProvider {
    static var previews: some View {
        // テスト用のデータを渡してプレビュー
        SecondView(currentTodos: [
            Todo(id: UUID(), value: "タスク1: 今日は買い物に行く"),
            Todo(id: UUID(), value: "ポジティブ: 今日は天気がいい"),
            Todo(id: UUID(), value: "ネガティブ: 天気が悪い"),
            Todo(id: UUID(), value: "未分類のタスク")
        ])
    }
}
