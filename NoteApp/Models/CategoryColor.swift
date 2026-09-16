//
//  CategoryColor.swift
//  NoteApp
//
//  Created by Nicolas Valentini on 27/8/2026.
//
import Foundation
import SwiftUICore

enum CategoryColor: String, CaseIterable, Identifiable {
    case red = "RED"
    case blue = "BLUE"
    case green = "GREEN"
    case orange = "ORANGE"
    case purple = "PURPLE"

    var id: String { rawValue }

    var swiftUIColor: Color {
        switch self {
        case .red: .red
        case .blue: .blue
        case .green: .green
        case .orange: .orange
        case .purple: .purple
        }
    }
}
