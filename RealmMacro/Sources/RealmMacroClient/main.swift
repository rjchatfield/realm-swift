import RealmMacro
import RealmSwift
import Foundation

/*
 Example object that ensures all generated code is valid
 */
@CompileTimeSchema
open class FooObject: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var name: String
    @Persisted(indexed: true) internal var key: String
    @Persisted public internal(set) var nestedObject: NestedObject?
    @Persisted private var embeddedObjects: List<NestedObject>

    var computed: String { "" }
    func method() {}

    @CompileTimeSchema
    @objc(ObjcNestedObject)
    public class NestedObject: Object {
        @Persisted(primaryKey: true) var id: String
        @Persisted var name2: String
    }

    @CompileTimeSchema
    @objc(ObjcNestedEmbeddedObject)
    private final class NestedEmbeddedObject: EmbeddedObject {
        @Persisted var name3: String
    }
}
