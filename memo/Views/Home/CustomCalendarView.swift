//
//  CustomCalendarView.swift
//  memo
//
//  Created by 山本明音 on 2024/10/03.
//

import SwiftUI
import UIKit

struct CustomCalendarView: UIViewRepresentable {
    @Binding var selectedDate: Date
    var todosByDate: [Date: [Todo]]

    func makeUIView(context: Context) -> UICalendarView {
        let calendarView = UICalendarView()
        calendarView.delegate = context.coordinator
        calendarView.selectionBehavior = UICalendarSelectionSingleDate(delegate: context.coordinator)
        return calendarView
    }

    func updateUIView(_ uiView: UICalendarView, context: Context) {
        // カレンダーのデコレーションを更新
        let dates = todosByDate.keys.map { date -> DateComponents in
            Calendar.current.dateComponents([.year, .month, .day], from: date)
        }
        uiView.reloadDecorations(forDateComponents: dates, animated: true)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
        var parent: CustomCalendarView

        init(_ parent: CustomCalendarView) {
            self.parent = parent
        }

        // 日付の装飾を設定
        func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
            guard let date = dateComponents.date else { return nil }
            let startOfDay = Calendar.current.startOfDay(for: date)
            if let todos = parent.todosByDate[startOfDay], !todos.isEmpty {
                // Todoがある場合、ドットを表示
                return .default(color: .systemBlue, size: .small)
            }
            return nil
        }

        // 日付が選択されたときに呼ばれる
        func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
            if let date = dateComponents?.date {
                parent.selectedDate = date
            }
        }
    }
}
