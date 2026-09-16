//
//  NotesListView.swift
//  NoteApp
//
//  Created by Nicolas Valentini on 27/8/2026.
//
import Foundation
import SwiftUI
import SwiftData

struct NotesListView: View {

    @StateObject private var viewModel: NoteListViewModel
    private let root: CompositionRoot

    init(_ vm: NoteListViewModel, root: CompositionRoot) {
        _viewModel = StateObject(wrappedValue: vm)
        self.root = root
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
                            CategoriesListView(root.makeCategoryListViewModel(), root: root)
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
                            .swipeActions {
                                Button("Eliminar", role: .destructive) {
                                    Task { await viewModel.delete(note) }
                                }
                            }
                        }
                        .navigationDestination(for: Note.self) { note in
                            NoteDetailView(note: note) {
                                Task { await viewModel.delete(note) }
                            }
                        }
                    }
                case .error(let messageError):
                    Text(messageError)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        AddNoteView(root.makeAddNoteViewModel())
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
    let container = try! ModelContainer(for: Note.self, Category.self, configurations: .init(isStoredInMemoryOnly: true))
    NotesListView(
        NoteListViewModel(useCase: MockNoteUseCase()),
        root: CompositionRoot(modelContext: container.mainContext)
    )
}
