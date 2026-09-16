import Testing
@testable import NotitApp

@MainActor
struct AddNoteViewModelTests {

    @Test func loadCategories_populatesListAndDefaultsSelection() async {
        let categoryUseCase = MockCategoryUseCase()
        let sut = AddNoteViewModel(noteUseCase: MockNoteUseCase(), categoryUseCase: categoryUseCase)

        await sut.loadCategories()

        #expect(sut.categories.count == categoryUseCase.categories.count)
        #expect(sut.selectedCategory != nil)
    }

    @Test func createNote_withEmptyTitle_setsErrorAndDoesNotSave() async {
        let noteUseCase = MockNoteUseCase()
        let sut = AddNoteViewModel(noteUseCase: noteUseCase, categoryUseCase: MockCategoryUseCase())
        sut.title = "   "

        await sut.createNote()

        #expect(sut.errorMessage != nil)
        #expect(!noteUseCase.addCalled)
        #expect(!sut.didSave)
    }

    @Test func createNote_withoutSelectedCategory_setsError() async {
        let noteUseCase = MockNoteUseCase()
        let sut = AddNoteViewModel(noteUseCase: noteUseCase, categoryUseCase: MockCategoryUseCase())
        sut.title = "Nueva nota"

        await sut.createNote()

        #expect(sut.errorMessage != nil)
        #expect(!noteUseCase.addCalled)
    }

    @Test func createNote_valid_savesAndMarksDidSave() async {
        let noteUseCase = MockNoteUseCase()
        let sut = AddNoteViewModel(noteUseCase: noteUseCase, categoryUseCase: MockCategoryUseCase())
        await sut.loadCategories()
        sut.title = "Nueva nota"
        sut.value = "Detalle"

        await sut.createNote()

        #expect(noteUseCase.addCalled)
        #expect(sut.didSave)
        #expect(sut.errorMessage == nil)
    }
}
