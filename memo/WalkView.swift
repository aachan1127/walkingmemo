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

    var body: some View {
        NavigationStack {
            VStack (spacing: 0) {
                NavigationLink {
                    SecondView(currentTodos: currentTodos)
                } label: {
                    Text("終了")
                }

                List(currentTodos, id: \.id) { currentTodo in
                    Text(currentTodo.value)
                }

                HStack {
                    TextField("memo", text: $input)
                        .padding()
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius:5))

                    Button("Enter") {
                        do {
                            try saveTodo(todo: input)
                            currentTodos = try getTodos()
                            input = ""
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
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
        }
        .onAppear {
            do {
                currentTodos = try getTodos()
            } catch {
                print(error.localizedDescription)
            }
        }
        .onChange(of: speechRecognizer.recognizedText) { newValue in
            input = newValue
        }
        .onChange(of: authViewModel.currentUser) { _ in
            do {
                currentTodos = try getTodos()
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func saveTodo(todo: String) throws {
        let todo = Todo(id: UUID(), value: todo)
        currentTodos.append(todo)
        let encodedTodos = try JSONEncoder().encode(currentTodos)
        if let userID = authViewModel.currentUser?.id {
            let key = "todos_\(userID)"
            UserDefaults.standard.set(encodedTodos, forKey: key)
        } else {
            print("ユーザーがログインしていません")
        }
    }

    func getTodos() throws -> [Todo] {
        if let userID = authViewModel.currentUser?.id {
            let key = "todos_\(userID)" // ユーザーIDをキーに含める
            if let data = UserDefaults.standard.data(forKey: key) {
                return try JSONDecoder().decode([Todo].self, from: data)
            } else {
                return []
            }
        } else {
            print("ユーザーがログインしていません")
            return []
        }
    }
}

#Preview {
    WalkView()
}
