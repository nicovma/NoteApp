//
//  RootTabView.swift
//  NoteApp
//
import SwiftUI

struct RootTabView: View {
    let root: CompositionRoot
    @State private var selection: AppTab = .notes

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selection) {
                NotesListView(root.makeNoteListViewModel(), root: root)
                    .tag(AppTab.notes)
                    .toolbar(.hidden, for: .tabBar)

                CategoriesListView(root.makeCategoryListViewModel(), root: root)
                    .tag(AppTab.categories)
                    .toolbar(.hidden, for: .tabBar)
            }

            LiquidGlassTabBar(selection: $selection)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
        }
    }
}
