//
//  NavigationManager.swift
//  memo
//
//  Created by あなたの名前 on 2024/10/05.
//

import SwiftUI

class NavigationManager: ObservableObject {
    @Binding var navigationPath: NavigationPath

    init(navigationPath: Binding<NavigationPath>) {
        self._navigationPath = navigationPath
    }

    func reset() {
        navigationPath = NavigationPath()
    }

    func push(_ screen: Screen) {
        navigationPath.append(screen)
    }
}
