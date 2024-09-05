//
//  CaleyApp.swift
//  Caley
//
//  Created by Rigels H on 2024-09-05.
//

import SwiftUI

@main
struct CaleyApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
