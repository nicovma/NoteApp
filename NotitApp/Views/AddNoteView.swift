//
//  AddNoteView.swift
//  NotitApp
//
//  Created by Nicolas Valentini on 27/8/2026.
//
import Foundation
import SwiftUI

struct AddNoteView: View {

    private enum Field {
        case title, body
    }

    // @StateObject, not @ObservedObject: this view model is built inline by
    // the caller (`AddNoteView(root.makeAddNoteViewModel())`) and pushed via
    // a plain NavigationLink destination closure. With @ObservedObject, any
    // re-render of the pushed-from parent re-evaluates that closure and
    // SwiftUI treats it as a brand-new object — silently swapping in a fresh,
    // empty AddNoteViewModel while this screen is still on screen (typed
    // title/body reset, reloaded categories lost). @StateObject keeps the
    // first instance for the life of this view regardless of how many times
    // the parent's body re-evaluates.
    @StateObject private var viewModel: AddNoteViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isAddingCategory = false
    @FocusState private var focusedField: Field?

    init(_ viewModel: AddNoteViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
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
                    .accessibilityLabel(Text("Título"))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .glassSurface(cornerRadius: 18)
                    .padding(.bottom, 16)
                    .focused($focusedField, equals: .title)

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 13))
                        .foregroundStyle(LiquidGlass.systemRed)
                        .padding(.bottom, 8)
                }

                if viewModel.isSuggesting || viewModel.suggestion != nil {
                    SuggestionBanner(
                        isSuggesting: viewModel.isSuggesting,
                        suggestion: viewModel.suggestion,
                        isNewCategory: viewModel.suggestedCategory == nil,
                        onUseTitle: { viewModel.applySuggestedTitle() },
                        onUseCategory: { Task { await viewModel.applySuggestedCategory() } },
                        onRequestAnother: { viewModel.requestAnotherSuggestion() }
                    )
                    .padding(.bottom, 16)
                } else if let reason = viewModel.suggestionUnavailableReason {
                    SuggestionUnavailableHint(reason: reason)
                        .padding(.bottom, 16)
                }

                Text("CATEGORÍA")
                    .font(.system(size: 13, weight: .bold))
                    .tracking(0.5)
                    .foregroundStyle(LiquidGlass.inkSecondary)
                    .accessibilityAddTraits(.isHeader)
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
                        AddCategoryChip { isAddingCategory = true }
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
                            .accessibilityHidden(true)
                    }
                    TextEditor(text: $viewModel.value)
                        .font(.system(size: 16))
                        .scrollContentBackground(.hidden)
                        // The placeholder above is a plain overlay Text, not a
                        // real TextEditor placeholder — VoiceOver never reads
                        // it on its own, so an empty editor would otherwise
                        // announce as "Text Editor, blank" with no hint.
                        .accessibilityLabel(Text("Nota"))
                        .accessibilityHint(viewModel.value.isEmpty ? Text("Escribí tu nota...") : Text(""))
                        .focused($focusedField, equals: .body)
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
        .hidesTabBarWhilePresented()
        .contentShape(Rectangle())
        .onTapGesture { focusedField = nil }
        .task {
            await viewModel.loadCategories()
        }
        .onChange(of: viewModel.value) {
            viewModel.valueDidChange()
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
            Button("Cancelar") {
                focusedField = nil
                dismiss()
            }
                .font(.system(size: 16))
                .foregroundStyle(LiquidGlass.primary)

            Spacer()

            Text("Nueva nota")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(LiquidGlass.ink)

            Spacer()

            Button("Guardar") {
                focusedField = nil
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
                    .accessibilityHidden(true)
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
        .accessibilityElement(children: .combine)
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
        // The dot/checkmark is purely decorative (redundant with the
        // selection trait below) — combine collapses it into the chip's
        // single VoiceOver stop instead of announcing an unlabeled shape.
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

/// Always-present alongside the existing category chips, so creating a new
/// category doesn't require emptying the list first.
struct AddCategoryChip: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(LiquidGlass.inkSecondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(LiquidGlass.inkSecondary.opacity(0.12), in: Capsule())
        }
        .buttonStyle(.plain)
    }
}

/// Tells the user why they aren't seeing AI suggestions on this device,
/// instead of the feature silently seeming to not exist.
struct SuggestionUnavailableHint: View {
    let reason: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "sparkles")
                .font(.system(size: 12))
            Text(reason)
                .font(.system(size: 12))
        }
        .foregroundStyle(LiquidGlass.inkTertiary)
    }
}

/// Shows the AI-generated title/category suggestion as editable chips —
/// nothing here is applied automatically, the user taps to accept each one.
struct SuggestionBanner: View {
    let isSuggesting: Bool
    let suggestion: NoteSuggestion?
    let isNewCategory: Bool
    let onUseTitle: () -> Void
    let onUseCategory: () -> Void
    let onRequestAnother: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.system(size: 12, weight: .bold))
                Text("SUGERENCIA")
                    .font(.system(size: 12, weight: .bold))
                    .tracking(0.5)

                Spacer()

                if suggestion != nil, !isSuggesting {
                    Button(action: onRequestAnother) {
                        Label("Otra sugerencia", systemImage: "arrow.clockwise")
                            .labelStyle(.iconOnly)
                            .font(.system(size: 12, weight: .bold))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(Text("Otra sugerencia"))
                }
            }
            .foregroundStyle(LiquidGlass.systemPurple)

            if isSuggesting {
                HStack(spacing: 8) {
                    ProgressView()
                    Text("Pensando un título y categoría...")
                        .font(.system(size: 13))
                        .foregroundStyle(LiquidGlass.inkSecondary)
                }
            } else if let suggestion {
                VStack(alignment: .leading, spacing: 10) {
                    SuggestionRow(label: "Título") {
                        Button(action: onUseTitle) {
                            Label(suggestion.title, systemImage: "textformat")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .buttonStyle(SuggestionChipStyle())
                    }

                    SuggestionRow(label: "Categoría") {
                        Button(action: onUseCategory) {
                            Label(
                                isNewCategory ? String(format: String(localized: "Crear \"%@\""), suggestion.categoryName) : suggestion.categoryName,
                                systemImage: isNewCategory ? "plus.circle" : "checkmark.circle"
                            )
                            .font(.system(size: 13, weight: .semibold))
                        }
                        .buttonStyle(SuggestionChipStyle())
                    }
                }
            }
        }
        .padding(14)
        .glassSurface(cornerRadius: 16)
    }
}

/// Labels each suggestion chip with what it is ("Título" / "Categoría") so
/// the two don't read as interchangeable options.
private struct SuggestionRow<Content: View>: View {
    let label: String
    @ViewBuilder let content: Content

    var body: some View {
        HStack(spacing: 10) {
            Text(label.uppercased())
                .font(.system(size: 10, weight: .bold))
                .tracking(0.3)
                .foregroundStyle(LiquidGlass.inkTertiary)
                .fixedSize()
                .frame(width: 80, alignment: .leading)
            content
        }
    }
}

private struct SuggestionChipStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(LiquidGlass.systemPurple)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(LiquidGlass.systemPurple.opacity(configuration.isPressed ? 0.24 : 0.14), in: Capsule())
    }
}

#Preview {
    NavigationStack {
        AddNoteView(AddNoteViewModel(noteUseCase: MockNoteUseCase(), categoryUseCase: MockCategoryUseCase(), noteSuggestionUseCase: MockNoteSuggestionUseCase()))
    }
    .environmentObject(TabBarVisibility())
}
