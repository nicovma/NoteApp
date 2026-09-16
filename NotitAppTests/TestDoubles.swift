@testable import NotitApp

struct StubError: Error {}

final class ThrowingNoteUseCase: NoteUseCase {
    func add(_ category: Note) async throws { throw StubError() }
    func update(_ note: Note) async throws { throw StubError() }
    func delete(_ note: Note) async throws { throw StubError() }
    func fetch() async throws -> [Note] { throw StubError() }
}

final class ThrowingCategoryUseCase: CategoryUseCase {
    func add(_ category: NotitApp.Category) async throws { throw StubError() }
    func delete(_ category: NotitApp.Category) async throws { throw StubError() }
    func fetch() async throws -> [NotitApp.Category] { throw StubError() }
}
