//
//  AddCategoryView.swift
//  NoteApp
//
//  Created by Nicolas Valentini on 27/8/2026.
//
import Foundation
import SwiftUI

struct AddCategoryView: View {

    @ObservedObject private var viewModel: AddCategoryViewModel
    @Environment(\.dismiss) private var dismiss

    init(_ viewModel: AddCategoryViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        Form {
            Section("Categoría") {
                TextField("Nombre", text: $viewModel.name)
                Picker("Color", selection: $viewModel.selectedColor) {
                    ForEach(CategoryColor.allCases) { color in
                        Text(color.rawValue.capitalized).tag(color)
                    }
                }
            }
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage).foregroundStyle(.red)
            }
        }
        .navigationTitle("Nueva categoría")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Guardar") {
                    Task {
                        await viewModel.createCategory()
                        if viewModel.didSave {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        AddCategoryView(AddCategoryViewModel(useCase: MockCategoryUseCase()))
    }
}
