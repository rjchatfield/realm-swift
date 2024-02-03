import RealmMacro
import RealmSwift
import Foundation

/*
 Example object that ensures all generated code is valid
 */
@RealmSchemaDiscovery
final class FooObject: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var name: String
    @Persisted(indexed: true) var key: String
    @Persisted var nestedObject: NestedObject?
    @Persisted var embeddedObjects: List<NestedObject>

    var computed: String { "" }
    func method() {}

    @RealmSchemaDiscovery
    @objc(ObjcNestedObject)
    class NestedObject: Object {
        @Persisted(primaryKey: true) var id: String
        @Persisted var name2: String
    }

    @RealmSchemaDiscovery
    @objc(ObjcNestedEmbeddedObject)
    class NestedEmbeddedObject: EmbeddedObject {
        @Persisted var name3: String
    }
}
