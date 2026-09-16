//
//  NoteAppApp.swift
//  NoteApp
//
//  Created by Nicolas Valentini on 27/8/2026.
//

import SwiftUI
import SwiftData

@main
struct NoteAppApp: App {

    private let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(for: Note.self, Category.self)
        } catch {
            fatalError("No se pudo inicializar SwiftData: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            let root = CompositionRoot(modelContext: modelContainer.mainContext)
            RootTabView(root: root)
                // The Liquid Glass design is light-only by intent (pastel
                // background, hardcoded ink colors) — forcing light mode
                // here keeps every pushed screen legible regardless of the
                // system appearance, instead of patching adaptive colors
                // screen by screen.
                .preferredColorScheme(.light)
        }
    }
}
