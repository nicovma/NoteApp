//
//  CategoriesListView.swift
//  NotitApp
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

    private static let backdrop: [GlassBackdrop.Blob] = [
        .init(color: LiquidGlass.systemPurple, size: 230, blur: 75, opacity: 0.32, corner: .topLeading, inset: CGPoint(x: 65, y: 45)),
        .init(color: LiquidGlass.systemOrange, size: 270, blur: 85, opacity: 0.28, corner: .topTrailing, inset: CGPoint(x: 65, y: 105)),
        .init(color: LiquidGlass.systemGreen, size: 250, blur: 85, opacity: 0.25, corner: .bottomLeading, inset: CGPoint(x: 45, y: 305)),
        .init(color: LiquidGlass.systemBlue, size: 230, blur: 75, opacity: 0.25, corner: .bottomTrailing, inset: CGPoint(x: 65, y: 45)),
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                GlassBackdrop(blobs: Self.backdrop)

                switch viewModel.state {
                case .idle, .loading:
                    ProgressView()

                case .loaded(let categories):
                    VStack(spacing: 0) {
                        header
                        List {
                            ForEach(categories) { category in
                                CategoryRow(category: category)
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                                    .swipeActions {
                                        Button("Eliminar", role: .destructive) {
                                            Task { await viewModel.deleteCategory(category) }
                                        }
                                    }
                            }
                            Color.clear.frame(height: 90)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 60)

                case .error(let message):
                    Text(message)
                }
            }
            .navigationBarHidden(true)
            .task { await viewModel.fetchCategories() }
        }
    }

    private var header: some View {
        HStack {
            Text("Categorías")
                .font(.system(size: 34, weight: .heavy))
                .foregroundStyle(LiquidGlass.ink)
            Spacer()
            NavigationLink {
                AddCategoryView(root.makeAddCategoryViewModel())
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(LiquidGlass.primary)
                    .glassCircle()
            }
            .accessibilityLabel(Text("Nueva categoría"))
        }
        .padding(.bottom, 24)
    }

}

struct CategoryRow: View {
    let category: Category

    var body: some View {
        let color = CategoryColor(rawValue: category.color)?.swiftUIColor ?? .gray

        HStack(spacing: 14) {
            Circle()
                .fill(RadialGradient(colors: [color.opacity(0.55), color], center: .init(x: 0.3, y: 0.3), startRadius: 0, endRadius: 24))
                .frame(width: 42, height: 42)
                .shadow(color: color.opacity(0.4), radius: 8, x: 0, y: 3)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(category.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(LiquidGlass.ink)
                Text("\(category.notes.count) notas")
                    .font(.system(size: 13))
                    .foregroundStyle(LiquidGlass.inkSecondary)
            }

            Spacer()
        }
        .padding(14)
        .glassSurface(cornerRadius: 22, borderOpacity: 0.7)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    let container = try! ModelContainer(for: Note.self, Category.self, configurations: .init(isStoredInMemoryOnly: true))
    CategoriesListView(
        CategoryListViewModel(useCase: MockCategoryUseCase()),
        root: CompositionRoot(modelContext: container.mainContext)
    )
    .environmentObject(TabBarVisibility())
}
