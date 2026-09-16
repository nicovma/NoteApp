@testable import NoteApp

struct StubError: Error {}

final class ThrowingNoteUseCase: NoteUseCase {
    func add(_ category: Note) async throws { throw StubError() }
    func delete(_ note: Note) async throws { throw StubError() }
    func fetch() async throws -> [Note] { throw StubError() }
}

final class ThrowingCategoryUseCase: CategoryUseCase {
    func add(_ category: NoteApp.Category) async throws { throw StubError() }
    func delete(_ category: NoteApp.Category) async throws { throw StubError() }
    func fetch() async throws -> [NoteApp.Category] { throw StubError() }
}
