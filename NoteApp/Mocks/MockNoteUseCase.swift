//
//  MockNoteUseCase.swift
//  NoteApp
//
//  Created by Nicolas Valentini on 27/8/2026.
//
import Foundation

#if DEBUG
final class MockNoteUseCase: NoteUseCase {
    var notes: [Note]
    private(set) var addCalled = false
    private(set) var deleteCalled = false
    
    init(notes: [Note] = []) {
        self.notes = notes
        if notes.count == 0 {
            let sampleCategory = Category("Compras", color: "RED")
            self.notes = [
                Note("Supermercado", value: "Comprar leche", category: sampleCategory, createdAt: .now)
            ]
        }
    }

    func add(_ note: Note) async throws {
        addCalled = true
        notes.append(note)
    }

    func delete(_ note: Note) async throws {
        deleteCalled = true
        notes.removeAll { $0.id == note.id }
    }

    func fetch() async throws -> [Note] {
        return  notes
    }
}
#endif
