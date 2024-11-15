//
//  Speech_ExplorationApp.swift
//  Speech_Exploration
//
//  Created by Arrick Russell Adinoto on 14/11/24.
//

import SwiftUI

@main
struct Speech_ExplorationApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
