//
//  AddNoteViewModel.swift
//  NotitApp
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

    /// Drives the "Guardar" button's enabled state so an incomplete note
    /// (no title, or no category — there's no default to fall back to once
    /// the user has none) can't be submitted in the first place, instead of
    /// only failing after the tap.
    var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && selectedCategory != nil
    }

    func makeAddCategoryViewModel() -> AddCategoryViewModel {
        AddCategoryViewModel(useCase: categoryUseCase)
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
            errorMessage = String(localized: "El título no puede estar vacío")
            return
        }
        guard let category = selectedCategory else {
            errorMessage = String(localized: "Elegí una categoría")
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
