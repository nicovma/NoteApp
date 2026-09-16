//
//  AddCategoryView.swift
//  NotitApp
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

    private static let backdrop: [GlassBackdrop.Blob] = [
        .init(color: LiquidGlass.systemPurple, size: 230, blur: 75, opacity: 0.32, corner: .topLeading, inset: CGPoint(x: 65, y: 45)),
        .init(color: LiquidGlass.systemBlue, size: 270, blur: 85, opacity: 0.22, corner: .topTrailing, inset: CGPoint(x: 65, y: 105)),
        .init(color: LiquidGlass.systemGreen, size: 230, blur: 75, opacity: 0.20, corner: .bottomTrailing, inset: CGPoint(x: 65, y: 45)),
    ]

    var body: some View {
        ZStack {
            GlassBackdrop(blobs: Self.backdrop)

            VStack(alignment: .leading, spacing: 0) {
                topBar
                    .padding(.bottom, 26)

                Text("NOMBRE")
                    .font(.system(size: 13, weight: .bold))
                    .tracking(0.5)
                    .foregroundStyle(LiquidGlass.inkSecondary)
                    .padding(.bottom, 10)

                TextField("Nombre", text: $viewModel.name)
                    .font(.system(size: 17, weight: .semibold))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .glassSurface(cornerRadius: 18)
                    .padding(.bottom, 20)

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 13))
                        .foregroundStyle(LiquidGlass.systemRed)
                        .padding(.bottom, 12)
                }

                Text("COLOR")
                    .font(.system(size: 13, weight: .bold))
                    .tracking(0.5)
                    .foregroundStyle(LiquidGlass.inkSecondary)
                    .padding(.bottom, 14)

                HStack(spacing: 16) {
                    ForEach(CategoryColor.allCases) { color in
                        ColorSwatch(
                            color: color.swiftUIColor,
                            isSelected: viewModel.selectedColor == color
                        ) {
                            viewModel.selectedColor = color
                        }
                    }
                }
                .padding(.bottom, 32)

                Text("VISTA PREVIA")
                    .font(.system(size: 13, weight: .bold))
                    .tracking(0.5)
                    .foregroundStyle(LiquidGlass.inkSecondary)
                    .padding(.bottom, 10)

                HStack(spacing: 14) {
                    Circle()
                        .fill(RadialGradient(
                            colors: [viewModel.selectedColor.swiftUIColor.opacity(0.55), viewModel.selectedColor.swiftUIColor],
                            center: .init(x: 0.3, y: 0.3), startRadius: 0, endRadius: 24
                        ))
                        .frame(width: 42, height: 42)
                        .shadow(color: viewModel.selectedColor.swiftUIColor.opacity(0.4), radius: 8, x: 0, y: 3)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(viewModel.name.isEmpty ? "Nombre" : viewModel.name)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(LiquidGlass.ink)
                        Text("0 notas")
                            .font(.system(size: 13))
                            .foregroundStyle(LiquidGlass.inkSecondary)
                    }
                    Spacer()
                }
                .padding(14)
                .glassSurface(cornerRadius: 22, borderOpacity: 0.7)

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
            .padding(.bottom, 40)
        }
        .navigationBarHidden(true)
        .onChange(of: viewModel.didSave) {
            if viewModel.didSave { dismiss() }
        }
    }

    private var topBar: some View {
        HStack {
            Button("Cancelar") { dismiss() }
                .font(.system(size: 16))
                .foregroundStyle(LiquidGlass.primary)

            Spacer()

            Text("Nueva categoría")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(LiquidGlass.ink)

            Spacer()

            Button("Guardar") {
                Task { await viewModel.createCategory() }
            }
            .buttonStyle(GradientPillButtonStyle(tint: LiquidGlass.primary))
        }
    }
}

private struct ColorSwatch: View {
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(RadialGradient(
                        colors: [color.opacity(0.55), color],
                        center: .init(x: 0.3, y: 0.3), startRadius: 0, endRadius: 25
                    ))
                    .frame(width: isSelected ? 50 : 44, height: isSelected ? 50 : 44)
                    .shadow(color: color.opacity(0.45), radius: isSelected ? 10 : 6, x: 0, y: 3)
                    .overlay(
                        Circle().strokeBorder(.white, lineWidth: isSelected ? 3 : 0)
                    )
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        AddCategoryView(AddCategoryViewModel(useCase: MockCategoryUseCase()))
    }
}
