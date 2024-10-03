import SwiftUI

struct ThirdView: View {
    var currentTodos: [Todo] // SecondViewから渡されるリスト

    var body: some View {
        NavigationStack {
            VStack {
                Text("ネガティブを一つ選んで\nそこから考えられる、他の見方を考えよう")
                ZStack {
                    Color.yellow
                        .ignoresSafeArea()

                    // currentTodos を表示し、タップしたら FourthView に渡す
                    List(currentTodos, id: \.id) { todo in
                        NavigationLink(destination: FourthView(selectedTodo: todo)) {
                            Text(todo.value)
                        }
                    }
                }
            }
            .navigationTitle("画面3")
        }
    }
}

struct ThirdView_Previews: PreviewProvider {
    static var previews: some View {
        ThirdView(currentTodos: [
            Todo(id: UUID(), value: "サンプルデータ1", date: Date()),
            Todo(id: UUID(), value: "サンプルデータ2", date: Date())
        ])
    }
}
