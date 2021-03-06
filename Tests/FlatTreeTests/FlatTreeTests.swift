import XCTest
@testable import FlatTree

final class FlatTreeTests: XCTestCase {
    
    ///  ------------
    ///  [0] a, index:0
    ///  [0] b, index:1
    ///  [0] c, index:2
    ///  ------------
    ///  append("d", to: "a") where a is parent.
    ///  ------------
    ///  [0] a, index:0
    ///    [1]d, index:1
    ///  [0] b, index:2
    ///  [0] c, index:3
    func testAppend() {
        var tree = FlatTree<String>()
        tree.append(["a", "b", "c"], to: nil)
        tree.reindex()
        
        XCTAssertEqual(tree.items.count, 3)
        XCTAssertEqual(tree.items[0], "a")
        XCTAssertEqual(tree.items[1], "b")
        XCTAssertEqual(tree.items[2], "c")
        
        tree.append(["d"], to: "a")
        tree.reindex()

        // Assert Count
        XCTAssertEqual(tree.items.count, 4)

        // Assert Item
        XCTAssertEqual(tree.items[0], "a")
        XCTAssertEqual(tree.items[1], "d")
        XCTAssertEqual(tree.items[2], "b")
        XCTAssertEqual(tree.items[3], "c")
        
    }
    
    /// - Precondition: testAppend is passed
    func testInsertBeforeInChildHierarchy() {
        
        // Given
        var tree = FlatTree<String>()
        tree.append(["a", "b", "c"], to: nil)
        tree.append(["d"], to: "a")
        
        // When
        tree.insert(["x", "y"], before: "d")
        tree.reindex()

        // Then
        // Assert Count
        XCTAssertEqual(tree.items.count, 6)

        // Assert Item
        // dbのindex振りなおしが出来てない。
        XCTAssertEqual(tree.items[0], "a")
        XCTAssertEqual(tree.items[1], "x")
        XCTAssertEqual(tree.items[2], "y")
        XCTAssertEqual(tree.items[3], "d")
        XCTAssertEqual(tree.items[4], "b")
        XCTAssertEqual(tree.items[5], "c")
        
    }
    
    /// - Precondition: testAppend is passed
    func testInsertBeforeInRootHierarchy() {
        
        // Given
        var tree = FlatTree<String>()
        tree.append(["a", "b", "c"], to: nil)
        tree.append(["d"], to: "a")
        
        // When
        tree.insert(["x", "y"], before: "b")
        tree.reindex()

        // Then
        // Assert Count
        XCTAssertEqual(tree.items.count, 6)

        // Assert Item
        XCTAssertEqual(tree.items[0], "a")
        XCTAssertEqual(tree.items[1], "d")
        XCTAssertEqual(tree.items[2], "x")
        XCTAssertEqual(tree.items[3], "y")
        XCTAssertEqual(tree.items[4], "b")
        XCTAssertEqual(tree.items[5], "c")
        
    }

    /// - Precondition: testAppend is passed
    func testInsertAfterInChildHierarchy() {
        
        // Given
        var tree = FlatTree<String>()
        tree.append(["a", "b", "c"], to: nil)
        tree.append(["d"], to: "a")
        
        // When
        tree.insert(["x", "y"], after: "d")
        tree.reindex()

        // Then
        // Assert Count
        XCTAssertEqual(tree.items.count, 6)

        // Assert Item
        XCTAssertEqual(tree.items[0], "a")
        XCTAssertEqual(tree.items[1], "d")
        XCTAssertEqual(tree.items[2], "x")
        XCTAssertEqual(tree.items[3], "y")
        XCTAssertEqual(tree.items[4], "b")
        XCTAssertEqual(tree.items[5], "c")
        
    }
    
    /// - Precondition: testAppend is passed
    func testInsertAfterInRootHierarchy() {
        
        // Given
        var tree = FlatTree<String>()
        tree.append(["a", "b", "c"], to: nil)
        tree.append(["d"], to: "a")
        
        // When
        tree.insert(["x", "y"], after: "a")
        tree.reindex()

        // Then
        // Assert Count
        XCTAssertEqual(tree.items.count, 6)

        // Assert Item
        XCTAssertEqual(tree.items[0], "a")
        XCTAssertEqual(tree.items[1], "d")
        XCTAssertEqual(tree.items[2], "x")
        XCTAssertEqual(tree.items[3], "y")
        XCTAssertEqual(tree.items[4], "b")
        XCTAssertEqual(tree.items[5], "c")
        
    }
    
    func testDeleteItems() {
        // Given
        var tree = FlatTree<String>()
        tree.append(["a", "b", "c"], to: nil)
        tree.append(["d"], to: "a")
        
        // When
        tree.remove(["d", "b"])
        tree.reindex()

        // Then
        // Assert Count
        XCTAssertEqual(tree.items.count, 2)

        // Assert Item
        XCTAssertEqual(tree.items[0], "a")
        XCTAssertEqual(tree.items[1], "c")
    }
    
    func testRemoveAll() {
        // Given
        var tree = FlatTree<String>()
        tree.append(["a", "b", "c"], to: nil)
        tree.append(["d"], to: "a")
        
        XCTAssertEqual(tree.items.count, 4)
        
        // When
        tree.removeAll()
        
        // Then
        XCTAssertTrue(tree.items.isEmpty)
    }
    
    
//    func testPerformanceAppendWithPerReindex() {
//        let inputSize = 14948
//
//        var tree = FlatTree<UUID>()
//        var allitems: [UUID] = []
//
//        var parent = UUID()
//        tree.append([parent])
//
//        print("Start setup datasources")
//        // Unbalanced and deep depth tree.
//        for i in 0...inputSize {
//            let startDate = Date()
//            let node = UUID()
//            tree.append([node], to: parent)
//            tree.reindex()
//
//            parent = node
//            allitems.append(node)
//
//            if i % 500 == 0 {
//                print("Current: \(String(format: "%.1f", Double(i) / Double(inputSize) * 100)) %")
//
//                let elapsed = (Date().timeIntervalSince(startDate))
//                let formatedElapsed = String(format: "%.5f", elapsed)
//
//                print("Time: \(formatedElapsed)")
//            }
//        }
//        print("Completed setup datasources")
//
//        // average: 0.008sec
//        measure {
//            tree.append([UUID()], to: parent)
//        }
//
//    }
    
    func testPerformanceAppendWithBatchUpdate() {
        
        let inputSize = 14948
        
        measure {
            var tree = FlatTree<UUID>()
            var allitems: [UUID] = []
                                                
            var parent = UUID()
            tree.append([parent])
            tree.performBatchUpdates({ passedTree in
                // Unbalanced and deep depth tree.
                for _ in 0...inputSize {
                    let item = UUID()
                    passedTree.append([item], to: parent)

                    parent = item
                    allitems.append(item)
                }
            })
        }
        
    }
    
    func testLevel() {
        var tree = FlatTree<String>()
        tree.performBatchUpdates({ (tree) in
            tree.append(["a", "b", "c"], to: nil)
            tree.append(["d"], to: "a")
            tree.append(["f"], to: "d")
        })

        XCTAssertEqual(tree.items.count, 5)
        
        XCTAssertEqual(tree.level(of: "a"), 0)
        XCTAssertEqual(tree.level(of: "d"), 1)
        XCTAssertEqual(tree.level(of: "f"), 2)
        XCTAssertEqual(tree.level(of: "b"), 0)
        XCTAssertEqual(tree.level(of: "c"), 0)

    }
    
    func testIndex() {
        var tree = FlatTree<String>()
        tree.performBatchUpdates({ (tree) in
            tree.append(["a", "b", "c"], to: nil)
            tree.append(["d"], to: "a")
            tree.append(["f"], to: "d")
        })
                
        XCTAssertEqual(tree.items.count, 5)
                
        // Then
        XCTAssertEqual(tree.index(of: "a"), 0)
        XCTAssertEqual(tree.index(of: "d"), 1)
        XCTAssertEqual(tree.index(of: "f"), 2)
        XCTAssertEqual(tree.index(of: "b"), 3)
        XCTAssertEqual(tree.index(of: "c"), 4)

    }
    
    func testParent() {
        var tree = FlatTree<String>()
        tree.performBatchUpdates({ (tree) in
            tree.append(["a", "b", "c"], to: nil)
            tree.append(["d"], to: "a")
            tree.append(["f"], to: "d")
        })
                
        XCTAssertEqual(tree.items.count, 5)
                
        // Then
        XCTAssertEqual(tree.parent(of: "a"), nil)
        XCTAssertEqual(tree.parent(of: "d"), "a")
        XCTAssertEqual(tree.parent(of: "f"), "d")
        XCTAssertEqual(tree.parent(of: "b"), nil)
        XCTAssertEqual(tree.parent(of: "c"), nil)
    }
    
    func testContains() {
        var tree = FlatTree<String>()
        tree.performBatchUpdates({ (tree) in
            tree.append(["a", "b", "c"], to: nil)
            tree.append(["d"], to: "a")
            tree.append(["f"], to: "d")
        })
                
        XCTAssertEqual(tree.items.count, 5)
                
        // Then
        XCTAssertTrue(tree.contains("f"))
        XCTAssertFalse(tree.contains("z"))
    }
    
    func testExpandAndCollapse() {
        var tree = FlatTree<String>()
        tree.performBatchUpdates({ (tree) in
            tree.append(["a", "b", "c"], to: nil)
            tree.append(["d"], to: "a")
            tree.append(["f"], to: "d")
        })
                
        XCTAssertEqual(tree.items.count, 5)
        
        // Expand
        tree.expand(["a", "b"])
        XCTAssertTrue(tree.isExpanded("a"))
        XCTAssertFalse(tree.isExpanded("d"))
        XCTAssertFalse(tree.isExpanded("f"))
        XCTAssertTrue(tree.isExpanded("b"))
        XCTAssertFalse(tree.isExpanded("c"))
        
        // Collapse
        tree.collapse(["a"])
        XCTAssertFalse(tree.isExpanded("a"))

    }
    
    func testVisible() {
        var tree = FlatTree<String>()
        tree.performBatchUpdates({ (tree) in
            tree.append(["a", "b", "c"], to: nil)
            tree.append(["d"], to: "a")
            tree.append(["f"], to: "d")
        })
                
        XCTAssertEqual(tree.items.count, 5)
        
        tree.expand(["a"])
        XCTAssertTrue(tree.isVisible("a"))
        XCTAssertTrue(tree.isVisible("d"))
        XCTAssertFalse(tree.isVisible("f"))
        XCTAssertTrue(tree.isVisible("b"))
        XCTAssertTrue(tree.isVisible("c"))
    }
        
    static var allTests = [
        ("testAppend", testAppend),
    ]
}
