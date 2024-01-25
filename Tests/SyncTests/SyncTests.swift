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
        withMacroTesting(isRecording: true, macros: testMacros) {
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
                    return _syncToChild(
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

            /// The backing storage for the ``foo: Int`` property.
            /// - Note: The value of this property is not synchronized with the parent. Use the ``foo: Int`` property instead.
            private var _foo: Int
            """#
        }
    }

    func testMacroWithOptionalChild() throws {
        assertMacro {
            #"""
            @Sync(
                (\ExampleChild.country, to: \ExampleParent.country),
                (\ExampleChild.city, to: \ExampleParent.city)
            )
            var foo: Int?
            """#
        } expansion: {
            #"""
            var foo: Int? {
                get {
                    guard let _foo else {
                        return nil
                    }
                    return _syncToChild(
                            parent: self,
                            child: _foo,
                            (\ExampleChild.country, to: \ExampleParent.country),
                                (\ExampleChild.city, to: \ExampleParent.city)
                        )
                }
                set {
                    guard let newValue else {
                        _foo = nil
                        return
                    }
                    _foo = _syncToParent(
                            parent: &self,
                            child: newValue,
                            (\ExampleChild.country, to: \ExampleParent.country),
                                (\ExampleChild.city, to: \ExampleParent.city)
                        )
                }
            }

            /// The backing storage for the ``foo: Int?`` property.
            /// - Note: The value of this property is not synchronized with the parent. Use the ``foo: Int?`` property instead.
            private var _foo: Int?
            """#
        }
    }
}
