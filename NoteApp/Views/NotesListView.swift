//
//  NotesListView.swift
//  NoteApp
//
//  Created by Nicolas Valentini on 27/8/2026.
//
import Foundation
import SwiftUI

struct NotesListView: View {
    
    @StateObject private var viewModel: NoteListViewModel
    
    init(_ vm: NoteListViewModel) {
        _viewModel = StateObject(wrappedValue:vm)
    }
    
    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .idle, .loading:
                    ProgressView()
                    
                case .loaded(let notes):
                    VStack {
                        NavigationLink {
                            CategoriesListView(CategoryListViewModel(useCase: MockCategoryUseCase()))
                        } label: {
                            Text("Ver categorias")
                        }
                        .padding()
                        
                        List(notes) { note in
                            NavigationLink(value: note) {
                                Text(note.title)
                            }

                            .listRowBackground(
                                CategoryColor(rawValue: note.category.color)?.swiftUIColor ?? .gray
                            )

                        }
                        .navigationDestination(for: Note.self) { note in
                            NoteDetailView()
                        }
                    }
                case .error(let messageError):
                    Text(messageError)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        AddNoteView()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationTitle("My notes")
            .task {
                await viewModel.fetchNotes()
            }
        }

    }
}

#Preview {
    NotesListView(NoteListViewModel(useCase: MockNoteUseCase()))
}
