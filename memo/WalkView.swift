//
//  WalkView.swift
//  memo
//
//  Created by 山本明音 on 2024/09/02.
//

import SwiftUI
import Speech
import AVFoundation

// SpeechRecognizerクラスの追加
class SpeechRecognizer: ObservableObject {
    private var audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja_JP"))
    
    @Published var recognizedText = ""
    
    init() {
        requestSpeechAuthorization()
    }
    
    func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { status in
            switch status {
            case .authorized:
                print("音声認識が許可されました")
            case .denied, .restricted, .notDetermined:
                print("音声認識が許可されていません")
            @unknown default:
                print("不明なエラーが発生しました")
            }
        }
    }
    
    func startRecording() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("音声認識リクエストの作成に失敗しました")
        }
        
        let inputNode = audioEngine.inputNode
        
        guard inputNode.inputFormat(forBus: 0).channelCount > 0 else {
            fatalError("マイク入力が利用できません")
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
            recognitionRequest.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            fatalError("オーディオエンジンの開始に失敗しました: \(error.localizedDescription)")
        }
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                self.recognizedText = result.bestTranscription.formattedString
            }
            
            if error != nil || result?.isFinal == true {
                self.stopRecording()
            }
        }
    }
    
    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
    }
}


struct WalkView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State var currentTodos: [Todo] = []
    @State private var todosData: Data = Data()
    
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @State var input = ""
    @State var isRecording = false
    
    @State private var isUserLoaded = false // ユーザー情報のロード状態を管理
    
    var body: some View {
        NavigationStack {
            if !isUserLoaded {
                ProgressView("ユーザー情報を取得中です...")
                    .onAppear {
                        if authViewModel.currentUser == nil {
                            waitForCurrentUser()
                        } else {
                            isUserLoaded = true
                            loadTodos()
                        }
                    }
            } else {
                VStack (spacing: 0) {
                    NavigationLink {
                        SecondView(currentTodos: currentTodos)
                    } label: {
                        Text("終了")
                    }
                    
                    List {
                        ForEach(currentTodos, id: \.id) { currentTodo in
                            Text(currentTodo.value)
                        }
                        .onDelete(perform: deleteTodo) // スワイプ削除を追加
                    }
                    
                    HStack {
                        TextField("memo", text: $input)
                            .padding()
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius:5))
                        
                        Button("Enter") {
                            do {
                                if authViewModel.currentUser != nil {
                                    try saveTodo(todo: input)
                                    currentTodos = try getTodos(for: Date())
                                    input = ""
                                } else {
                                    print("ユーザー情報を取得中です。少々お待ちください。")
                                }
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                        .disabled(!isUserLoaded)
                        .padding()
                        .foregroundStyle(.white)
                        .background(.blue)
                        .clipShape(RoundedRectangle(cornerRadius:5))
                        .padding()
                        
                        Button(action: {
                            if isRecording {
                                speechRecognizer.stopRecording()
                            } else {
                                speechRecognizer.startRecording()
                            }
                            isRecording.toggle()
                        }) {
                            Text(isRecording ? "音声入力停止" : "音声入力開始")
                                .padding()
                                .background(isRecording ? Color.red : Color.green)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                        }
                        .padding()
                    }
                    .padding(.horizontal)
                    .background(.yellow)
                    
                    Text(speechRecognizer.recognizedText)
                        .padding()
                        .background(.gray)
                }
                .navigationTitle("画面１")
                .onAppear {
                    loadTodos()
                }
                .onChange(of: speechRecognizer.recognizedText) { newValue in
                    input = newValue
                }
                .onChange(of: authViewModel.currentUser) { _ in
                    loadTodos()
                }
            }
        }
    }
    
    func waitForCurrentUser() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if authViewModel.currentUser != nil {
                isUserLoaded = true
                loadTodos()
            } else {
                waitForCurrentUser()
            }
        }
    }
    
    func loadTodos() {
        do {
            currentTodos = try getTodos(for: Date())
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func saveTodo(todo: String) throws {
        let calendar = Calendar.current
        let date = calendar.startOfDay(for: Date())
        let todo = Todo(id: UUID(), value: todo, date: date, isDeleted: false)
        var allTodos = try getAllTodos()
        allTodos.append(todo)
        let encodedTodos = try JSONEncoder().encode(allTodos)
        if let userID = authViewModel.currentUser?.id {
            let key = "todos_\(userID)"
            UserDefaults.standard.set(encodedTodos, forKey: key)
        } else {
            print("ユーザーがログインしていません")
            throw NSError(domain: "UserNotLoggedIn", code: 1, userInfo: nil)
        }
    }
    
    // スワイプ削除の処理
    func deleteTodo(at offsets: IndexSet) {
        for index in offsets {
            var todo = currentTodos[index]
            todo.isDeleted = true
            updateTodoInStorage(todo)
        }
        loadTodos()
    }
    
    // Todoを更新する関数
    func updateTodoInStorage(_ todo: Todo) {
        if var allTodos = try? getAllTodos() {
            if let idx = allTodos.firstIndex(where: { $0.id == todo.id }) {
                allTodos[idx] = todo
                saveAllTodos(allTodos)
            }
        }
    }
    
    // 全てのTodoを保存する関数
    func saveAllTodos(_ todosToSave: [Todo]) {
        if let userID = authViewModel.currentUser?.id {
            let key = "todos_\(userID)"
            do {
                let encodedTodos = try JSONEncoder().encode(todosToSave)
                UserDefaults.standard.set(encodedTodos, forKey: key)
            } catch {
                print("データのエンコードに失敗しました: \(error.localizedDescription)")
            }
        }
    }
    
    func getAllTodos() throws -> [Todo] {
        if let userID = authViewModel.currentUser?.id {
            let key = "todos_\(userID)"
            if let data = UserDefaults.standard.data(forKey: key) {
                do {
                    return try JSONDecoder().decode([Todo].self, from: data)
                } catch {
                    print("データのデコードに失敗しました: \(error.localizedDescription)")
                    UserDefaults.standard.removeObject(forKey: key)
                    return []
                }
            } else {
                return []
            }
        } else {
            print("ユーザーがログインしていません")
            throw NSError(domain: "UserNotLoggedIn", code: 1, userInfo: nil)
        }
    }
    
    func getTodos(for date: Date) throws -> [Todo] {
        let allTodos = try getAllTodos()
        let calendar = Calendar.current

        // 目標の日付の年・月・日を取得
        let targetDateComponents = calendar.dateComponents([.year, .month, .day], from: date)

        return allTodos.filter { todo in
            // 削除されていないTodoのみ
            guard let todoDate = todo.date, !todo.isDeleted else {
                return false
            }
            let todoDateComponents = calendar.dateComponents([.year, .month, .day], from: todoDate)
            return todoDateComponents.year == targetDateComponents.year &&
                   todoDateComponents.month == targetDateComponents.month &&
                   todoDateComponents.day == targetDateComponents.day
        }
    }
}

#Preview {
    WalkView()
}
