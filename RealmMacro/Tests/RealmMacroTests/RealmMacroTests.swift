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

                //@RealmSchemaDiscovery
                @objc(NestedObject)
                class NestedObject: Object {
                    @Persisted(primaryKey: true) var id: String
                    @Persisted var name2: String
                }

                //@RealmSchemaDiscovery
                @objc(NestedEmbeddedObject)
                class NestedEmbeddedObject: EmbeddedObject {
                    @Persisted var name3: String
                }
            }
            """
        } expansion: {
            #"""
            public final class FooObject: Object {
                @Persisted(primaryKey: true) var id: String
                @Persisted var name: String
                @Persisted(indexed: true) var key: String
                @Persisted var nestedObject: NestedObject?
                @Persisted var embeddedObjects: List<NestedObject>

                var computed: String { "" }
                func method() {}

                //@RealmSchemaDiscovery
                @objc(NestedObject)
                class NestedObject: Object {
                    @Persisted(primaryKey: true) var id: String
                    @Persisted var name2: String
                }

                //@RealmSchemaDiscovery
                @objc(NestedEmbeddedObject)
                class NestedEmbeddedObject: EmbeddedObject {
                    @Persisted var name3: String
                }
            }

            extension FooObject: RealmSwift._RealmObjectSchemaDiscoverable {
                public static var _realmProperties: [RealmSwift.Property]? {
                    guard RealmMacroConstants.schemaDiscoveryEnabled else {
                        return nil
                    }
                    return [
            			RealmSwift.Property(name: "id", type: String.self, keyPath: \FooObject.id, primaryKey: true),
            			RealmSwift.Property(name: "name", type: String.self, keyPath: \FooObject.name),
            			RealmSwift.Property(name: "key", type: String.self, keyPath: \FooObject.key, indexed: true),
            			RealmSwift.Property(name: "nestedObject", type: NestedObject?.self, keyPath: \FooObject.nestedObject),
            			RealmSwift.Property(name: "embeddedObjects", type: List<NestedObject>.self, keyPath: \FooObject.embeddedObjects),
                    ]
                }
            }
            """#
        }
    }

    func testEquality() {
//        InlineSnapshotTesting.isRecording = true
        RealmMacro.RealmMacroConstants.schemaDiscoveryEnabled = true

        let macroGeneratedProperties = FooObject._realmProperties!.map(ObjectiveCSupport.convert(object:))
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
            	objectClassName = NestedObject;
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
            	objectClassName = NestedObject;
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
            	objectClassName = NestedObject;
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
            	objectClassName = NestedObject;
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
            			objectClassName = NestedObject;
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
            			objectClassName = NestedObject;
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
            	NestedEmbeddedObject (embedded) {
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
            	NestedObject {
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

//    @RealmSchemaDiscovery
    @objc(NestedObject)
    class NestedObject: Object {
        @Persisted(primaryKey: true) var id: String
        @Persisted var name2: String
    }

//    @RealmSchemaDiscovery
    @objc(NestedEmbeddedObject)
    class NestedEmbeddedObject: EmbeddedObject {
        @Persisted var name3: String
    }
}
