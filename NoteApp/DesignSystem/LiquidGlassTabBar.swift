//
//  LiquidGlassTabBar.swift
//  NoteApp
//
import SwiftUI

enum AppTab {
    case notes
    case categories
}

/// The floating glass tab bar shared by both top-level tabs. Lives once at
/// the `RootTabView` level, overlaid on top of a real `TabView` — the
/// screens themselves don't own it, so switching tabs never re-triggers
/// their `.task`/fetch (a `NavigationLink` push, the previous approach, was
/// creating a fresh `CategoriesListView` — and re-fetching — on every tap).
struct LiquidGlassTabBar: View {
    @Binding var selection: AppTab

    var body: some View {
        HStack(spacing: 0) {
            tabButton(.notes, icon: "note.text", title: "Notas")
            tabButton(.categories, icon: "heart.text.square", title: "Categorías")
        }
        .padding(.horizontal, 5)
        .frame(height: 50)
        .glassSurface(cornerRadius: 25, borderOpacity: 0.75)
    }

    private func tabButton(_ tab: AppTab, icon: String, title: String) -> some View {
        let isSelected = selection == tab
        return Button {
            selection = tab
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 13))
                Text(title).font(.system(size: 12, weight: isSelected ? .bold : .semibold))
            }
            .foregroundStyle(isSelected ? LiquidGlass.primary : LiquidGlass.inkSecondary)
            .padding(.vertical, 5)
            .frame(maxWidth: .infinity)
            .background(isSelected ? LiquidGlass.primary.opacity(0.14) : Color.clear, in: Capsule())
        }
        .buttonStyle(.plain)
    }
}
