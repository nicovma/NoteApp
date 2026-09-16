//
//  CategoriesListView.swift
//  NoteApp
//
//  Created by Nicolas Valentini on 27/8/2026.
//
import Foundation
import SwiftUI
import SwiftData

struct CategoriesListView: View {

    @StateObject private var viewModel: CategoryListViewModel
    private let root: CompositionRoot

    init(_ viewModel: CategoryListViewModel, root: CompositionRoot) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.root = root
    }

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .idle, .loading:
                    ProgressView()
                case .loaded(let categories):
                    List(categories) { category in
                        HStack {
                            Text(category.name)
                            Circle()
                                .fill(CategoryColor(rawValue: category.color)?.swiftUIColor ?? .gray)
                                .frame(width: 24, height: 24)
                            Spacer()
                            Button("X") {
                                Task {
                                    await viewModel.deleteCategory(category)
                                }
                            }
                        }
                    }
                case .error(let message):
                    Text(message)
                }
            }
            .task { await viewModel.fetchCategories() }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        AddCategoryView(root.makeAddCategoryViewModel())
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationTitle("My categories")
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: Note.self, Category.self, configurations: .init(isStoredInMemoryOnly: true))
    CategoriesListView(
        CategoryListViewModel(useCase: MockCategoryUseCase()),
        root: CompositionRoot(modelContext: container.mainContext)
    )
}
