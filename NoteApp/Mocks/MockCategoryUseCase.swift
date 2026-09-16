//
//  MockCategoryUseCase.swift
//  NoteApp
//
//  Created by Nicolas Valentini on 27/8/2026.
//
import Foundation

#if DEBUG
final class MockCategoryUseCase: CategoryUseCase {
    var categories: [Category] = [Category("Compras", color: "RED"),Category("Viajes", color: "BLUE")]
    
    private(set) var addCalled = false
    private(set) var deleteCalled = false

    func add(_ category: Category) async throws {
        addCalled = true
        categories.append(category)
    }

    func delete(_ category: Category) async throws {
        deleteCalled = true
        categories.removeAll { $0.id == category.id }
    }

    func fetch() async throws -> [Category] {
        return  categories
    }
}
#endif
