//
//  CategoriesListView.swift
//  NoteApp
//
//  Created by Nicolas Valentini on 27/8/2026.
//
import Foundation
import SwiftUI

struct CategoriesListView: View {
    
    @StateObject private var viewModel: CategoryListViewModel
    
    init(_ viewModel: CategoryListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
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
                        AddCategoryView()
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
    CategoriesListView(CategoryListViewModel(useCase: MockCategoryUseCase()))
}
