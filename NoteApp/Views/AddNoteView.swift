//
//  AddNoteView.swift
//  NoteApp
//
//  Created by Nicolas Valentini on 27/8/2026.
//
import Foundation
import SwiftUI

struct AddNoteView: View {

    @ObservedObject private var viewModel: AddNoteViewModel
    @Environment(\.dismiss) private var dismiss

    init(_ viewModel: AddNoteViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        Form {
            Section("Nota") {
                TextField("Título", text: $viewModel.title)
                TextField("Detalle", text: $viewModel.value, axis: .vertical)
                    .lineLimit(3...6)
            }
            Section("Categoría") {
                Picker("Categoría", selection: $viewModel.selectedCategory) {
                    ForEach(viewModel.categories) { category in
                        Text(category.name).tag(Optional(category))
                    }
                }
            }
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage).foregroundStyle(.red)
            }
        }
        .navigationTitle("Nueva nota")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Guardar") {
                    Task {
                        await viewModel.createNote()
                        if viewModel.didSave {
                            dismiss()
                        }
                    }
                }
            }
        }
        .task {
            await viewModel.loadCategories()
        }
    }
}

#Preview {
    NavigationStack {
        AddNoteView(AddNoteViewModel(noteUseCase: MockNoteUseCase(), categoryUseCase: MockCategoryUseCase()))
    }
}
