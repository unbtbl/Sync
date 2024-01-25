import Sync
import XCTest

final class SyncClientTests: XCTestCase {
    // MARK: - Non-optional struct

    struct ChildStruct {
        var country: String
        var city: String
        var street: String
    }

    struct NonOptional {
        var country: String
        var city: String

        @Sync(
            (\ChildStruct.country, to: \NonOptional.country),
            (\ChildStruct.city, to: \NonOptional.city)
        )
        var child: ChildStruct

        init() {
            country = "USA"
            city = "New York"
            _child = ChildStruct(country: "USA", city: "New York", street: "Broadway")
        }
    }

    func testMacroClient() {
        var parent = NonOptional()
        XCTAssertEqual(parent.country, "USA")
        XCTAssertEqual(parent.city, "New York")
        XCTAssertEqual(parent.child.country, "USA")
        XCTAssertEqual(parent.child.city, "New York")
        XCTAssertEqual(parent.child.street, "Broadway")

        parent.country = "Canada"
        XCTAssertEqual(parent.country, "Canada")
        XCTAssertEqual(parent.city, "New York")
        XCTAssertEqual(parent.child.country, "Canada")
        XCTAssertEqual(parent.child.city, "New York")
        XCTAssertEqual(parent.child.street, "Broadway")

        parent.child.city = "Toronto"
        parent.child.street = "Yonge Street"
        XCTAssertEqual(parent.country, "Canada")
        XCTAssertEqual(parent.city, "Toronto")
        XCTAssertEqual(parent.child.country, "Canada")
        XCTAssertEqual(parent.child.city, "Toronto")
        XCTAssertEqual(parent.child.street, "Yonge Street")
    }

    // MARK: - Optional struct

    struct WithOptionalChild {
        var country: String
        var city: String

        @Sync(
            (\ChildStruct.country, to: \WithOptionalChild.country),
            (\ChildStruct.city, to: \WithOptionalChild.city)
        )
        var child: ChildStruct?

        init() {
            country = "USA"
            city = "New York"
            _child = ChildStruct(country: "USA", city: "New York", street: "Broadway")
        }
    }

    func testMacroClientWithOptionalChild() {
        var parent = WithOptionalChild()
        XCTAssertEqual(parent.country, "USA")
        XCTAssertEqual(parent.city, "New York")
        XCTAssertEqual(parent.child?.country, "USA")
        XCTAssertEqual(parent.child?.city, "New York")
        XCTAssertEqual(parent.child?.street, "Broadway")

        parent.country = "Canada"
        XCTAssertEqual(parent.country, "Canada")
        XCTAssertEqual(parent.city, "New York")
        XCTAssertEqual(parent.child?.country, "Canada")
        XCTAssertEqual(parent.child?.city, "New York")
        XCTAssertEqual(parent.child?.street, "Broadway")

        parent.child?.city = "Toronto"
        parent.child?.street = "Yonge Street"
        XCTAssertEqual(parent.country, "Canada")
        XCTAssertEqual(parent.city, "Toronto")
        XCTAssertEqual(parent.child?.country, "Canada")
        XCTAssertEqual(parent.child?.city, "Toronto")
        XCTAssertEqual(parent.child?.street, "Yonge Street")

        parent.child = nil
        XCTAssertEqual(parent.country, "Canada")
        XCTAssertEqual(parent.city, "Toronto")
        XCTAssertNil(parent.child)
    }
}
