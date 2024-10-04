//
//  BacklogView.swift
//  memo
//
//  Created by 山本明音 on 2024/10/04.

import SwiftUI

struct BacklogView: View {
    @State private var selectedDate: Date = Date()
    @State private var showAilogView = false

    var body: some View {
        VStack {
            Text("過去の記録を見る")
                .font(.largeTitle)
                .padding()

            CustomCalendarView(selectedDate: $selectedDate, todosByDate: [:]) // データは後で設定
                .frame(height: 400)
                .padding()

            Button("選択した日の記録を見る") {
                showAilogView = true
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .sheet(isPresented: $showAilogView) {
                AilogView(selectedDate: selectedDate)
            }
        }
    }
}

#Preview {
    BacklogView()
}
