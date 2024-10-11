import Vapor
import Fluent

final class Todo: Model {
    static let schema = "tasks"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "title")
    var title: String
    
    @Field(key: "isCompleted")
    var isCompleted: Bool
    
    @Parent(key: "user_id")
    var user: User
    
    init() { }

    init(id: UUID? = nil, title: String, isCompleted: Bool = false, userID: UUID) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.$user.id = userID
    }
}

