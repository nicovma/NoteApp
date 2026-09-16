//
//  AddNoteView.swift
//  NotitApp
//
//  Created by Nicolas Valentini on 27/8/2026.
//
import Foundation
import SwiftUI

struct AddNoteView: View {

    @ObservedObject private var viewModel: AddNoteViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isAddingCategory = false

    init(_ viewModel: AddNoteViewModel) {
        self.viewModel = viewModel
    }

    private static let backdrop: [GlassBackdrop.Blob] = [
        .init(color: LiquidGlass.systemBlue, size: 230, blur: 75, opacity: 0.30, corner: .topLeading, inset: CGPoint(x: 65, y: 45)),
        .init(color: LiquidGlass.systemOrange, size: 270, blur: 85, opacity: 0.22, corner: .topTrailing, inset: CGPoint(x: 65, y: 105)),
        .init(color: LiquidGlass.systemPurple, size: 230, blur: 75, opacity: 0.20, corner: .bottomTrailing, inset: CGPoint(x: 65, y: 45)),
    ]

    var body: some View {
        ZStack {
            GlassBackdrop(blobs: Self.backdrop)

            VStack(alignment: .leading, spacing: 0) {
                topBar
                    .padding(.bottom, 22)

                TextField("Título", text: $viewModel.title)
                    .font(.system(size: 19, weight: .bold))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .glassSurface(cornerRadius: 18)
                    .padding(.bottom, 16)

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 13))
                        .foregroundStyle(LiquidGlass.systemRed)
                        .padding(.bottom, 8)
                }

                Text("CATEGORÍA")
                    .font(.system(size: 13, weight: .bold))
                    .tracking(0.5)
                    .foregroundStyle(LiquidGlass.inkSecondary)
                    .padding(.bottom, 10)

                if viewModel.categories.isEmpty {
                    NoCategoriesPrompt { isAddingCategory = true }
                        .padding(.bottom, 18)
                } else {
                    FlowLayout(spacing: 8) {
                        ForEach(viewModel.categories) { category in
                            CategoryChip(
                                category: category,
                                isSelected: viewModel.selectedCategory == category
                            ) {
                                viewModel.selectedCategory = category
                            }
                        }
                    }
                    .padding(.bottom, 18)
                }

                ZStack(alignment: .topLeading) {
                    if viewModel.value.isEmpty {
                        Text("Escribí tu nota...")
                            .font(.system(size: 16))
                            .foregroundStyle(LiquidGlass.inkTertiary)
                            .padding(.top, 8)
                            .padding(.leading, 5)
                    }
                    TextEditor(text: $viewModel.value)
                        .font(.system(size: 16))
                        .scrollContentBackground(.hidden)
                }
                .padding(16)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .glassSurface(cornerRadius: 24)
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
            .padding(.bottom, 40)
        }
        .navigationBarHidden(true)
        .task {
            await viewModel.loadCategories()
        }
        .onChange(of: viewModel.didSave) {
            if viewModel.didSave { dismiss() }
        }
        .sheet(isPresented: $isAddingCategory) {
            NavigationStack {
                AddCategoryView(viewModel.makeAddCategoryViewModel())
            }
        }
        .onChange(of: isAddingCategory) {
            if !isAddingCategory {
                Task { await viewModel.loadCategories() }
            }
        }
    }

    private var topBar: some View {
        HStack {
            Button("Cancelar") { dismiss() }
                .font(.system(size: 16))
                .foregroundStyle(LiquidGlass.primary)

            Spacer()

            Text("Nueva nota")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(LiquidGlass.ink)

            Spacer()

            Button("Guardar") {
                Task { await viewModel.createNote() }
            }
            .buttonStyle(GradientPillButtonStyle(tint: LiquidGlass.primary))
            .disabled(!viewModel.canSave)
            .opacity(viewModel.canSave ? 1 : 0.4)
        }
    }
}

/// Blocks the note from being saved without one by replacing the chip
/// picker with a direct path to create the first category, instead of
/// just disabling "Guardar" with no way out.
struct NoCategoriesPrompt: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 16))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Todavía no tenés categorías")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Creá una para poder guardar la nota")
                        .font(.system(size: 12))
                        .foregroundStyle(LiquidGlass.inkSecondary)
                }
                Spacer()
            }
            .foregroundStyle(LiquidGlass.primary)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .glassSurface(cornerRadius: 16)
        }
        .buttonStyle(.plain)
    }
}

struct CategoryChip: View {
    let category: Category
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        let color = CategoryColor(rawValue: category.color)?.swiftUIColor ?? .gray

        Button(action: action) {
            HStack(spacing: 6) {
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                } else {
                    Circle().fill(color).frame(width: 7, height: 7)
                }
                Text(category.name)
                    .font(.system(size: 13, weight: isSelected ? .bold : .semibold))
            }
            .foregroundStyle(color)
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(color.opacity(0.14), in: Capsule())
            .overlay(
                Capsule().strokeBorder(color, lineWidth: isSelected ? 2 : 0)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        AddNoteView(AddNoteViewModel(noteUseCase: MockNoteUseCase(), categoryUseCase: MockCategoryUseCase()))
    }
}
