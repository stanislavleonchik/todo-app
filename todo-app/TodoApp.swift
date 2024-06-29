//
//  todo_appApp.swift
//  todo-app
//
//  Created by Stanislav Leonchik on 18.06.2024.
//

import SwiftUI

@main
struct todo_appApp: App {
    var body: some Scene {
        WindowGroup {
            // TODO: router - environment (NavigationStack)
            TodoView()
        }
    }
}
