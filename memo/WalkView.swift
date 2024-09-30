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

    // 権限をリクエスト（音声認識を使ってもいいかの許可をとる）
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

    // 録音を開始
    func startRecording() {
        // 既存のタスクがある場合はキャンセル
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }

        //マイクから音声を録音するためのリクエスト
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

        guard let recognitionRequest = recognitionRequest else {
            fatalError("音声認識リクエストの作成に失敗しました")
        }

        //マイクから音声データを取得
        let inputNode = audioEngine.inputNode

        // マイク入力が利用可能かどうかを確認
        guard inputNode.inputFormat(forBus: 0).channelCount > 0 else {
            fatalError("マイク入力が利用できません")
        }

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        //installTap メソッドで、マイクの音声を「バッファー」という単位で処理し、それを音声認識に送信
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
            recognitionRequest.append(buffer)
        }

        audioEngine.prepare()

        do {
            try audioEngine.start()
        } catch {
            fatalError("オーディオエンジンの開始に失敗しました: \(error.localizedDescription)")
        }

        //speechRecognizer?.recognitionTask は、音声をリアルタイムで認識
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                //その結果（テキスト）を self.recognizedText に反映
                self.recognizedText = result.bestTranscription.formattedString
            }

            if error != nil || result?.isFinal == true {
                self.stopRecording()
            }
        }
    }

    // 録音を停止（録音を止めて、マイクのタップを解除）
    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
    }
}


struct WalkView: View {
    @State var currentTodos: [Todo] = []
    @AppStorage("todos") var todosData: Data = Data()
    
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @State var input = ""
    @State var isRecording = false // 録音中かどうかを管理する状態変数

    var body: some View {
        NavigationStack {
            VStack (spacing: 0) {
                NavigationLink {
                    SecondView(currentTodos: currentTodos) //画面の遷移先(リストデータを渡す）
                } label: {
                    //ボタンの見た目👇ここの画面遷移の形ボタンにしたい
                    Text("終了")
                }

                
                // リストの表示
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
                            input = "" // 入力をクリア
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                    .padding()
                    .foregroundStyle(.white)
                    .background(.blue)
                    .clipShape(RoundedRectangle(cornerRadius:5))
                    .padding()

                    // 録音状態に応じて、音声入力を開始/停止する
                    Button(action: {
                        if isRecording {
                            speechRecognizer.stopRecording() // 録音を停止
                        } else {
                            speechRecognizer.startRecording() // 録音を開始
                        }
                        isRecording.toggle() // 録音状態を反転
                    }) {
                        Text(isRecording ? "音声入力停止" : "音声入力開始") // ボタンのテキストを変更
                            .padding()
                            .background(isRecording ? Color.red : Color.green)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                    }
                    .padding()
                }
                .padding(.horizontal)
                .background(.yellow)

                // 音声認識結果をリアルタイムで反映
                Text(speechRecognizer.recognizedText)
                    .padding()
                    .background(.gray)
            }
            //ナビゲーションができてるかの確認（画面のタイトル）
            .navigationTitle("画面１")
            
            
        }
        .onAppear {
            do {
                currentTodos = try getTodos()
            } catch {
                print(error.localizedDescription)
            }
        }
        // 音声認識結果を`input`に反映させる（iOS 17対応）
        .onChange(of: speechRecognizer.recognizedText) {
            input = speechRecognizer.recognizedText
        }
    }

    func saveTodo(todo: String) throws {
        let todo = Todo(id: UUID(), value: todo)
        currentTodos.append(todo)
        let encodedTodos = try JSONEncoder().encode(currentTodos)
        todosData = encodedTodos
    }

    func getTodos() throws -> [Todo] {
        try JSONDecoder().decode([Todo].self, from: todosData)
    }
}

#Preview {
    WalkView()
}
