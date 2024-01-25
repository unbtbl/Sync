import Sync

let a = 17
let b = 25

struct Parent {
    var country: String
    var city: String

    @Sync(
        (\Child.country, to: \Parent.country),
        (\Child.city, to: \Parent.city)
    )
    var child: Child

    init() {
        country = "USA"
        city = "New York"
        _child = Child(country: "USA", city: "New York", street: "Broadway")
    }
}

struct Child {
    var country: String
    var city: String
    var street: String
}

var parent = Parent()
