//
//  NoteDetailView.swift
//  NoteApp
//
//  Created by Nicolas Valentini on 27/8/2026.
//
import Foundation
import SwiftUI

struct NoteDetailView: View {

    let note: Note
    let onDelete: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section("Nota") {
                Text(note.title).font(.headline)
                Text(note.value)
            }
            Section("Categoría") {
                HStack {
                    Circle()
                        .fill(CategoryColor(rawValue: note.category.color)?.swiftUIColor ?? .gray)
                        .frame(width: 16, height: 16)
                    Text(note.category.name)
                }
            }
            Section {
                Button("Eliminar nota", role: .destructive) {
                    onDelete()
                    dismiss()
                }
            }
        }
        .navigationTitle(note.title)
    }
}

#Preview {
    NavigationStack {
        NoteDetailView(
            note: Note("Supermercado", value: "Comprar leche", category: Category("Compras", color: "RED"), createdAt: .now),
            onDelete: {}
        )
    }
}
