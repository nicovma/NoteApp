//
//  SwiftDataNoteRepository.swift
//  NoteApp
//
//  Created by Nicolas Valentini on 27/8/2026.
//
import Foundation
import SwiftData

@MainActor
final class SwiftDataNoteRepository: NoteRepository {
    func save(_ note: Note) async throws {
        
    }
    
    func delete(_ note: Note) async throws {
        
    }
    
    func fetchAll() async throws -> [Note] {
        return []
    }
    
    func fetch(byCategory category: Category) async throws -> [Note] {
        return []
    }
    
    
}
