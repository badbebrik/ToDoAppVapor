import Fluent
import Vapor


struct TodoDTO: Content {
    var id: UUID?
    var title: String
    var isCompleted: Bool

    init(id: UUID? = nil, title: String, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
    }
}
