//
//  AddNoteViewModel.swift
//  NoteApp
//
//  Created by Nicolas Valentini on 27/8/2026.
//
import Foundation

final class AddNoteListViewModel: ObservableObject {
    
    @Published private(set) var state: ViewModelState<[Note]> = .idle
    @Published var categories: [Category] = []
    
    
    func createNote() {
        
    }
    
}
