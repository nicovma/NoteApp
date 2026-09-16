//
//  CategoryColor.swift
//  NoteApp
//
//  Created by Nicolas Valentini on 27/8/2026.
//
import Foundation
import SwiftUI

enum CategoryColor: String, CaseIterable, Identifiable {
    case red = "RED"
    case blue = "BLUE"
    case green = "GREEN"
    case orange = "ORANGE"
    case purple = "PURPLE"

    var id: String { rawValue }

    var swiftUIColor: Color {
        switch self {
        case .red: LiquidGlass.systemRed
        case .blue: LiquidGlass.systemBlue
        case .green: LiquidGlass.systemGreen
        case .orange: LiquidGlass.systemOrange
        case .purple: LiquidGlass.systemPurple
        }
    }
}
