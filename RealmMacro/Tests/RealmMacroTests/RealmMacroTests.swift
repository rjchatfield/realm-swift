import MacroTesting
import RealmMacroMacros
import XCTest

final class RealmMacroTests: XCTestCase {
    override func invokeTest() {
        withMacroTesting(
            isRecording: true,
            macros: [
                "RealmSchemaDiscovery": RealmSchemaDiscoveryImpl.self,
            ]
        ) {
            super.invokeTest()
        }
    }

    func testSnapshot() {
        assertMacro {
            """
            @RealmSchemaDiscovery final class FooObject: Object {
                @Persisted(primaryKey: true) var id: String
                @Persisted var name: String
                @Persisted(indexed: true) var key: String

                var computed: String { "" }
                func method() {}
            }
            """
        } expansion: {
            #"""
            final class FooObject: Object {
                @Persisted(primaryKey: true) var id: String
                @Persisted var name: String
                @Persisted(indexed: true) var key: String

                var computed: String { "" }
                func method() {}

                static var _realmProperties: [RLMProperty] {
                    return [
                		RLMProperty(name: "id", type: String.self, keyPath: \FooObject.id, primaryKey: true),
                		RLMProperty(name: "name", type: String.self, keyPath: \FooObject.name),
                		RLMProperty(name: "key", type: String.self, keyPath: \FooObject.key, indexed: true),
                    ]
                }
            }
            """#
        }
    }
}
