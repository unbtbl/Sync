import MacroTesting
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import SyncMacros
import XCTest

let testMacros: [String: Macro.Type] = [
    "Sync": SyncMacro.self
]

final class SyncTests: XCTestCase {
    override func invokeTest() {
        withMacroTesting(isRecording: false, macros: testMacros) {
            super.invokeTest()
        }
    }

    func testMacro() throws {
        assertMacro {
            #"""
            @Sync(
                (\ExampleChild.country, to: \ExampleParent.country),
                (\ExampleChild.city, to: \ExampleParent.city)
            )
            var foo: Int
            """#
        } expansion: {
            #"""
            var foo: Int {
                get {
                    _syncToChild(
                        parent: self,
                        child: _foo,
                        (\ExampleChild.country, to: \ExampleParent.country),
                            (\ExampleChild.city, to: \ExampleParent.city)
                    )
                }
                set {
                    _foo = _syncToParent(
                        parent: &self,
                        child: newValue,
                        (\ExampleChild.country, to: \ExampleParent.country),
                            (\ExampleChild.city, to: \ExampleParent.city)
                    )
                }
            }

            private var _foo: Int
            """#
        }
    }
}
