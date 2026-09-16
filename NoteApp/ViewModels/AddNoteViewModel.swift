//
//  AddNoteViewModel.swift
//  NoteApp
//
//  Created by Nicolas Valentini on 27/8/2026.
//
import Foundation

@MainActor
final class AddNoteViewModel: ObservableObject {

    @Published private(set) var categories: [Category] = []
    @Published var title: String = ""
    @Published var value: String = ""
    @Published var selectedCategory: Category?
    @Published private(set) var errorMessage: String?
    @Published private(set) var didSave = false

    private let noteUseCase: NoteUseCase
    private let categoryUseCase: CategoryUseCase

    init(noteUseCase: NoteUseCase, categoryUseCase: CategoryUseCase) {
        self.noteUseCase = noteUseCase
        self.categoryUseCase = categoryUseCase
    }

    func loadCategories() async {
        do {
            categories = try await categoryUseCase.fetch()
            selectedCategory = selectedCategory ?? categories.first
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func createNote() async {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "El título no puede estar vacío"
            return
        }
        guard let category = selectedCategory else {
            errorMessage = "Elegí una categoría"
            return
        }
        let note = Note(title, value: value, category: category, createdAt: .now)
        do {
            try await noteUseCase.add(note)
            didSave = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
