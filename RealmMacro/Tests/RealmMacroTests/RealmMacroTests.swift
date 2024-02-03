import MacroTesting
import RealmMacroMacros
import InlineSnapshotTesting
import RealmMacro
import RealmSwift
import XCTest
import CustomDump
import Realm

final class RealmMacroTests: XCTestCase {
    override func invokeTest() {
        withMacroTesting(
//            isRecording: true,
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
            @RealmSchemaDiscovery
            public final class FooObject: Object {
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
            """
        } expansion: {
            """
            public final class FooObject: Object {
                @Persisted(primaryKey: true) var id: String
                @Persisted var name: String
                @Persisted(indexed: true) var key: String
                @Persisted var nestedObject: NestedObject?
                @Persisted var embeddedObjects: List<NestedObject>

                var computed: String { "" }
                func method() {}
                @objc(ObjcNestedObject)
                class NestedObject: Object {
                    @Persisted(primaryKey: true) var id: String
                    @Persisted var name2: String
                }
                @objc(ObjcNestedEmbeddedObject)
                class NestedEmbeddedObject: EmbeddedObject {
                    @Persisted var name3: String
                }
            }

            extension NestedObject: RealmSwift._RealmObjectSchemaDiscoverable {
                static var _realmProperties: [RealmSwift.Property]? {
                    guard RealmMacroConstants.schemaDiscoveryEnabled else {
                        return nil
                    }
                    return [
            			RealmSwift.Property(name: "id", objectType: Self.self, valueType: String.self, primaryKey: true),
            			RealmSwift.Property(name: "name2", objectType: Self.self, valueType: String.self),
                    ]
                }
            }

            extension NestedEmbeddedObject: RealmSwift._RealmObjectSchemaDiscoverable {
                static var _realmProperties: [RealmSwift.Property]? {
                    guard RealmMacroConstants.schemaDiscoveryEnabled else {
                        return nil
                    }
                    return [
            			RealmSwift.Property(name: "name3", objectType: Self.self, valueType: String.self),
                    ]
                }
            }

            extension FooObject: RealmSwift._RealmObjectSchemaDiscoverable {
                public static var _realmProperties: [RealmSwift.Property]? {
                    guard RealmMacroConstants.schemaDiscoveryEnabled else {
                        return nil
                    }
                    return [
            			RealmSwift.Property(name: "id", objectType: Self.self, valueType: String.self, primaryKey: true),
            			RealmSwift.Property(name: "name", objectType: Self.self, valueType: String.self),
            			RealmSwift.Property(name: "key", objectType: Self.self, valueType: String.self, indexed: true),
            			RealmSwift.Property(name: "nestedObject", objectType: Self.self, valueType: NestedObject?.self),
            			RealmSwift.Property(name: "embeddedObjects", objectType: Self.self, valueType: List<NestedObject>.self),
                    ]
                }
            }
            """
        }
    }

    func testSnapshotManualConformance() throws {
        assertMacro {
            """
            @RealmSchemaDiscovery
            public final class FooObject: Object {
                @Persisted(primaryKey: true) var id: String
                @Persisted var name: String
            }
            extension FooObject: RealmSwift._RealmObjectSchemaDiscoverable {
                public static var _realmProperties: [RealmSwift.Property]? { nil }
            }
            """
        } expansion: {
            """
            public final class FooObject: Object {
                @Persisted(primaryKey: true) var id: String
                @Persisted var name: String
            }
            extension FooObject: RealmSwift._RealmObjectSchemaDiscoverable {
                public static var _realmProperties: [RealmSwift.Property]? { nil }
            }

            extension FooObject: RealmSwift._RealmObjectSchemaDiscoverable {
                public static var _realmProperties: [RealmSwift.Property]? {
                    guard RealmMacroConstants.schemaDiscoveryEnabled else {
                        return nil
                    }
                    return [
            			RealmSwift.Property(name: "id", objectType: Self.self, valueType: String.self, primaryKey: true),
            			RealmSwift.Property(name: "name", objectType: Self.self, valueType: String.self),
                    ]
                }
            }
            """
        }
        throw XCTSkip("TODO: No-op macro if Type already manually conforms to _RealmObjectSchemaDiscoverable")
    }

    func testSnapshotNestedExample1() {
        assertMacro {
            """
            @RealmSchemaDiscovery
            class FooObject: Object {
                @Persisted var nestedObject: NestedObject?

                @objc(ObjcNestedObject)
                class NestedObject: Object {
                    @Persisted var name: String
                }
            }
            """
        } expansion: {
            """
            class FooObject: Object {
                @Persisted var nestedObject: NestedObject?

                @objc(ObjcNestedObject)
                class NestedObject: Object {
                    @Persisted var name: String
                }
            }

            extension FooObject: RealmSwift._RealmObjectSchemaDiscoverable {
                static var _realmProperties: [RealmSwift.Property]? {
                    guard RealmMacroConstants.schemaDiscoveryEnabled else {
                        return nil
                    }
                    return [
            			RealmSwift.Property(name: "nestedObject", objectType: Self.self, valueType: NestedObject?.self),
                    ]
                }
            }
            """
        }
    }
    
    func testSnapshotNestedExampleDouble() {
        assertMacro {
            """
            @RealmSchemaDiscovery
            class FooObject: Object {
                @Persisted var nestedObject: NestedObject?

                @objc(ObjcNestedObject)
                class NestedObject: Object {
                    @Persisted var veryNestedObject: String

                    @objc(ObjcVeryNestedObject)
                    class VeryNestedObject: Object {
                        @Persisted var name: String
                    }
                }
            }
            """
        } expansion: {
            """
            class FooObject: Object {
                @Persisted var nestedObject: NestedObject?

                @objc(ObjcNestedObject)
                class NestedObject: Object {
                    @Persisted var veryNestedObject: String

                    @objc(ObjcVeryNestedObject)
                    class VeryNestedObject: Object {
                        @Persisted var name: String
                    }
                }
            }

            extension FooObject: RealmSwift._RealmObjectSchemaDiscoverable {
                static var _realmProperties: [RealmSwift.Property]? {
                    guard RealmMacroConstants.schemaDiscoveryEnabled else {
                        return nil
                    }
                    return [
            			RealmSwift.Property(name: "nestedObject", objectType: Self.self, valueType: NestedObject?.self),
                    ]
                }
            }
            """
        }
    }
    func testSnapshotNestedExampleDoubleAnnotated() {
        assertMacro {
            """
            @RealmSchemaDiscovery
            class FooObject: Object {
                @Persisted var nestedObject: NestedObject?

                @objc(ObjcNestedObject)
                @RealmSchemaDiscovery
                class NestedObject: Object {
                    @Persisted var veryNestedObject: String

                    @objc(ObjcVeryNestedObject)
                    @RealmSchemaDiscovery
                    class VeryNestedObject: Object {
                        @Persisted var name: String
                    }
                }
            }
            """
        } diagnostics: {
            """

            """
        }expansion: {
            """
            class FooObject: Object {
                @Persisted var nestedObject: NestedObject?

                @objc(ObjcNestedObject)
                class NestedObject: Object {
                    @Persisted var veryNestedObject: String

                    @objc(ObjcVeryNestedObject)
                    class VeryNestedObject: Object {
                        @Persisted var name: String
                    }
                }
            }

            extension VeryNestedObject: RealmSwift._RealmObjectSchemaDiscoverable {
                static var _realmProperties: [RealmSwift.Property]? {
                    guard RealmMacroConstants.schemaDiscoveryEnabled else {
                        return nil
                    }
                    return [
            			RealmSwift.Property(name: "name", objectType: Self.self, valueType: String.self),
                    ]
                }
            }

            extension NestedObject: RealmSwift._RealmObjectSchemaDiscoverable {
                static var _realmProperties: [RealmSwift.Property]? {
                    guard RealmMacroConstants.schemaDiscoveryEnabled else {
                        return nil
                    }
                    return [
            			RealmSwift.Property(name: "veryNestedObject", objectType: Self.self, valueType: String.self),
                    ]
                }
            }

            extension FooObject: RealmSwift._RealmObjectSchemaDiscoverable {
                static var _realmProperties: [RealmSwift.Property]? {
                    guard RealmMacroConstants.schemaDiscoveryEnabled else {
                        return nil
                    }
                    return [
            			RealmSwift.Property(name: "nestedObject", objectType: Self.self, valueType: NestedObject?.self),
                    ]
                }
            }
            """
        }
    }

    func testSnapshotNestedExampleAnnotated() {
        assertMacro {
            """
            @RealmSchemaDiscovery
            class FooObject: Object {
                @Persisted var nestedObject: NestedObject?

                @RealmSchemaDiscovery
                @objc(ObjcNestedObject)
                class NestedObject: Object {
                    @Persisted var name: String
                }
            }
            """
        } diagnostics: {
            """

            """
        }expansion: {
            """
            class FooObject: Object {
                @Persisted var nestedObject: NestedObject?
                @objc(ObjcNestedObject)
                class NestedObject: Object {
                    @Persisted var name: String
                }
            }

            extension NestedObject: RealmSwift._RealmObjectSchemaDiscoverable {
                static var _realmProperties: [RealmSwift.Property]? {
                    guard RealmMacroConstants.schemaDiscoveryEnabled else {
                        return nil
                    }
                    return [
            			RealmSwift.Property(name: "name", objectType: Self.self, valueType: String.self),
                    ]
                }
            }

            extension FooObject: RealmSwift._RealmObjectSchemaDiscoverable {
                static var _realmProperties: [RealmSwift.Property]? {
                    guard RealmMacroConstants.schemaDiscoveryEnabled else {
                        return nil
                    }
                    return [
            			RealmSwift.Property(name: "nestedObject", objectType: Self.self, valueType: NestedObject?.self),
                    ]
                }
            }
            """
        }
    }

    func testSnapshotNestedExampleBaseNotAnnotated() {
        assertMacro {
            """
            class FooObject: Object {
                @Persisted var nestedObject: NestedObject?

                @RealmSchemaDiscovery(nestedTypeNames: ["FooObject"])
                @objc(ObjcNestedObject)
                class NestedObject: Object {
                    @Persisted var name1: String
                    @Persisted var name2: String
                }
            }
            """
        } expansion: {
            """
            class FooObject: Object {
                @Persisted var nestedObject: NestedObject?
                @objc(ObjcNestedObject)
                class NestedObject: Object {
                    @Persisted var name1: String
                    @Persisted var name2: String
                }
            }

            extension NestedObject: RealmSwift._RealmObjectSchemaDiscoverable {
                static var _realmProperties: [RealmSwift.Property]? {
                    guard RealmMacroConstants.schemaDiscoveryEnabled else {
                        return nil
                    }
                    return [
            			RealmSwift.Property(name: "name1", objectType: Self.self, valueType: String.self),
            			RealmSwift.Property(name: "name2", objectType: Self.self, valueType: String.self),
                    ]
                }
            }
            """
        }
    }

    func testEquality() throws {
//        InlineSnapshotTesting.isRecording = true
        RealmMacro.RealmMacroConstants.schemaDiscoveryEnabled = true

        let macroGeneratedProperties = try XCTUnwrap(FooObject._realmProperties).map(ObjectiveCSupport.convert(object:))
        let runtimeGeneratedProperties = FooObject._getProperties()
        XCTAssertNoDifference(macroGeneratedProperties, runtimeGeneratedProperties)
        assertInlineSnapshot(of: macroGeneratedProperties, as: .dump) {
            """
            ▿ 5 elements
              - id {
            	type = string;
            	columnName = id;
            	indexed = YES;
            	isPrimary = YES;
            	array = NO;
            	set = NO;
            	dictionary = NO;
            	optional = NO;
            }
              - name {
            	type = string;
            	columnName = name;
            	indexed = NO;
            	isPrimary = NO;
            	array = NO;
            	set = NO;
            	dictionary = NO;
            	optional = NO;
            }
              - key {
            	type = string;
            	columnName = key;
            	indexed = YES;
            	isPrimary = NO;
            	array = NO;
            	set = NO;
            	dictionary = NO;
            	optional = NO;
            }
              - nestedObject {
            	type = object;
            	objectClassName = ObjcNestedObject;
            	linkOriginPropertyName = (null);
            	columnName = nestedObject;
            	indexed = NO;
            	isPrimary = NO;
            	array = NO;
            	set = NO;
            	dictionary = NO;
            	optional = YES;
            }
              - embeddedObjects {
            	type = object;
            	objectClassName = ObjcNestedObject;
            	linkOriginPropertyName = (null);
            	columnName = embeddedObjects;
            	indexed = NO;
            	isPrimary = NO;
            	array = YES;
            	set = NO;
            	dictionary = NO;
            	optional = NO;
            }

            """
        }
        assertInlineSnapshot(of: runtimeGeneratedProperties, as: .dump) {
            """
            ▿ 5 elements
              - id {
            	type = string;
            	columnName = id;
            	indexed = YES;
            	isPrimary = YES;
            	array = NO;
            	set = NO;
            	dictionary = NO;
            	optional = NO;
            }
              - name {
            	type = string;
            	columnName = name;
            	indexed = NO;
            	isPrimary = NO;
            	array = NO;
            	set = NO;
            	dictionary = NO;
            	optional = NO;
            }
              - key {
            	type = string;
            	columnName = key;
            	indexed = YES;
            	isPrimary = NO;
            	array = NO;
            	set = NO;
            	dictionary = NO;
            	optional = NO;
            }
              - nestedObject {
            	type = object;
            	objectClassName = ObjcNestedObject;
            	linkOriginPropertyName = (null);
            	columnName = nestedObject;
            	indexed = NO;
            	isPrimary = NO;
            	array = NO;
            	set = NO;
            	dictionary = NO;
            	optional = YES;
            }
              - embeddedObjects {
            	type = object;
            	objectClassName = ObjcNestedObject;
            	linkOriginPropertyName = (null);
            	columnName = embeddedObjects;
            	indexed = NO;
            	isPrimary = NO;
            	array = YES;
            	set = NO;
            	dictionary = NO;
            	optional = NO;
            }

            """
        }
    }

    func testEqualityNested() throws {
//        InlineSnapshotTesting.isRecording = true
        RealmMacro.RealmMacroConstants.schemaDiscoveryEnabled = true

        let macroGeneratedProperties = try XCTUnwrap(FooObject.NestedObject._realmProperties).map(ObjectiveCSupport.convert(object:))
        let runtimeGeneratedProperties = FooObject.NestedObject._getProperties()
        XCTAssertNoDifference(macroGeneratedProperties, runtimeGeneratedProperties)
        assertInlineSnapshot(of: macroGeneratedProperties, as: .dump) {
            """
            ▿ 2 elements
              - id {
            	type = string;
            	columnName = id;
            	indexed = YES;
            	isPrimary = YES;
            	array = NO;
            	set = NO;
            	dictionary = NO;
            	optional = NO;
            }
              - name2 {
            	type = string;
            	columnName = name2;
            	indexed = NO;
            	isPrimary = NO;
            	array = NO;
            	set = NO;
            	dictionary = NO;
            	optional = NO;
            }

            """
        }
        assertInlineSnapshot(of: runtimeGeneratedProperties, as: .dump) {
            """
            ▿ 2 elements
              - id {
            	type = string;
            	columnName = id;
            	indexed = YES;
            	isPrimary = YES;
            	array = NO;
            	set = NO;
            	dictionary = NO;
            	optional = NO;
            }
              - name2 {
            	type = string;
            	columnName = name2;
            	indexed = NO;
            	isPrimary = NO;
            	array = NO;
            	set = NO;
            	dictionary = NO;
            	optional = NO;
            }

            """
        }
    }

    func testDebugSchema() {
        RealmMacro.RealmMacroConstants.schemaDiscoveryEnabled = false
        let s1 = RLMSchema.shared()
        assertInlineSnapshot(of: s1, as: .dump) {
            """
            - Schema {
            	FooObject {
            		id {
            			type = string;
            			columnName = id;
            			indexed = YES;
            			isPrimary = YES;
            			array = NO;
            			set = NO;
            			dictionary = NO;
            			optional = NO;
            		}
            		name {
            			type = string;
            			columnName = name;
            			indexed = NO;
            			isPrimary = NO;
            			array = NO;
            			set = NO;
            			dictionary = NO;
            			optional = NO;
            		}
            		key {
            			type = string;
            			columnName = key;
            			indexed = YES;
            			isPrimary = NO;
            			array = NO;
            			set = NO;
            			dictionary = NO;
            			optional = NO;
            		}
            		nestedObject {
            			type = object;
            			objectClassName = ObjcNestedObject;
            			linkOriginPropertyName = (null);
            			columnName = nestedObject;
            			indexed = NO;
            			isPrimary = NO;
            			array = NO;
            			set = NO;
            			dictionary = NO;
            			optional = YES;
            		}
            		embeddedObjects {
            			type = object;
            			objectClassName = ObjcNestedObject;
            			linkOriginPropertyName = (null);
            			columnName = embeddedObjects;
            			indexed = NO;
            			isPrimary = NO;
            			array = YES;
            			set = NO;
            			dictionary = NO;
            			optional = NO;
            		}
            	}
            	ObjcNestedEmbeddedObject (embedded) {
            		name3 {
            			type = string;
            			columnName = name3;
            			indexed = NO;
            			isPrimary = NO;
            			array = NO;
            			set = NO;
            			dictionary = NO;
            			optional = NO;
            		}
            	}
            	ObjcNestedObject {
            		id {
            			type = string;
            			columnName = id;
            			indexed = YES;
            			isPrimary = YES;
            			array = NO;
            			set = NO;
            			dictionary = NO;
            			optional = NO;
            		}
            		name2 {
            			type = string;
            			columnName = name2;
            			indexed = NO;
            			isPrimary = NO;
            			array = NO;
            			set = NO;
            			dictionary = NO;
            			optional = NO;
            		}
            	}
            }

            """
        }
    }
}

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

    @RealmSchemaDiscovery(nestedTypeNames: ["FooObject"])
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

//extension FooObject {
//    func foo() {
//        let kp: KeyPath<FooObject, String> = \Self.id
//    }
//}
