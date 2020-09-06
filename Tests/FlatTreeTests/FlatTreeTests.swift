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
        
        XCTAssertEqual(tree.nodes.count, 3)
        XCTAssertEqual(tree.nodes[0].item, "a")
        XCTAssertEqual(tree.nodes[1].item, "b")
        XCTAssertEqual(tree.nodes[2].item, "c")
        
        tree.append(["d"], to: "a")
        
        // Assert Count
        XCTAssertEqual(tree.nodes.count, 4)

        // Assert Item
        XCTAssertEqual(tree.nodes[0].item, "a")
        XCTAssertEqual(tree.nodes[1].item, "d")
        XCTAssertEqual(tree.nodes[2].item, "b")
        XCTAssertEqual(tree.nodes[3].item, "c")
        
        // Assert Index
        for (index, node) in tree.nodes.enumerated() {
            XCTAssertEqual(node.index, index)
        }
    }
    
    /// - Precondition: testAppend is passed
    func testInsertBeforeInChildHierarchy() {
        
        // Given
        var tree = FlatTree<String>()
        tree.append(["a", "b", "c"], to: nil)
        tree.append(["d"], to: "a")
        
        // When
        tree.insert(["x", "y"], before: "d")
                
        // Then
        // Assert Count
        XCTAssertEqual(tree.nodes.count, 6)

        // Assert Item
        // dbのindex振りなおしが出来てない。
        XCTAssertEqual(tree.nodes[0].item, "a")
        XCTAssertEqual(tree.nodes[1].item, "x")
        XCTAssertEqual(tree.nodes[2].item, "y")
        XCTAssertEqual(tree.nodes[3].item, "d")
        XCTAssertEqual(tree.nodes[4].item, "b")
        XCTAssertEqual(tree.nodes[5].item, "c")
        
        // Assert Index
        for (index, node) in tree.nodes.enumerated() {
            XCTAssertEqual(node.index, index)
        }
    }
    
    /// - Precondition: testAppend is passed
    func testInsertBeforeInRootHierarchy() {
        
        // Given
        var tree = FlatTree<String>()
        tree.append(["a", "b", "c"], to: nil)
        tree.append(["d"], to: "a")
        
        // When
        tree.insert(["x", "y"], before: "b")
        
        // Then
        // Assert Count
        XCTAssertEqual(tree.nodes.count, 6)

        // Assert Item
        XCTAssertEqual(tree.nodes[0].item, "a")
        XCTAssertEqual(tree.nodes[1].item, "d")
        XCTAssertEqual(tree.nodes[2].item, "x")
        XCTAssertEqual(tree.nodes[3].item, "y")
        XCTAssertEqual(tree.nodes[4].item, "b")
        XCTAssertEqual(tree.nodes[5].item, "c")
        
        // Assert Index
        for (index, node) in tree.nodes.enumerated() {
            XCTAssertEqual(node.index, index)
        }
    }

    /// - Precondition: testAppend is passed
    func testInsertAfterInChildHierarchy() {
        
        // Given
        var tree = FlatTree<String>()
        tree.append(["a", "b", "c"], to: nil)
        tree.append(["d"], to: "a")
        
        // When
        tree.insert(["x", "y"], after: "d")
        
        // Then
        // Assert Count
        XCTAssertEqual(tree.nodes.count, 6)

        // Assert Item
        XCTAssertEqual(tree.nodes[0].item, "a")
        XCTAssertEqual(tree.nodes[1].item, "d")
        XCTAssertEqual(tree.nodes[2].item, "x")
        XCTAssertEqual(tree.nodes[3].item, "y")
        XCTAssertEqual(tree.nodes[4].item, "b")
        XCTAssertEqual(tree.nodes[5].item, "c")
        
        // Assert Index
        for (index, node) in tree.nodes.enumerated() {
            XCTAssertEqual(node.index, index)
        }
    }
    
    /// - Precondition: testAppend is passed
    func testInsertAfterInRootHierarchy() {
        
        // Given
        var tree = FlatTree<String>()
        tree.append(["a", "b", "c"], to: nil)
        tree.append(["d"], to: "a")
        
        // When
        tree.insert(["x", "y"], after: "a")
        
        // Then
        // Assert Count
        XCTAssertEqual(tree.nodes.count, 6)

        // Assert Item
        XCTAssertEqual(tree.nodes[0].item, "a")
        XCTAssertEqual(tree.nodes[1].item, "d")
        XCTAssertEqual(tree.nodes[2].item, "x")
        XCTAssertEqual(tree.nodes[3].item, "y")
        XCTAssertEqual(tree.nodes[4].item, "b")
        XCTAssertEqual(tree.nodes[5].item, "c")
        
        // Assert Index
        for (index, node) in tree.nodes.enumerated() {
            XCTAssertEqual(node.index, index)
        }
    }
    
    func testDeleteItems() {
        // Given
        var tree = FlatTree<String>()
        tree.append(["a", "b", "c"], to: nil)
        tree.append(["d"], to: "a")
        
        // When
        tree.remove(["d", "b"])
        
        // Then
        // Assert Count
        XCTAssertEqual(tree.nodes.count, 2)

        // Assert Item
        XCTAssertEqual(tree.nodes[0].item, "a")
        XCTAssertEqual(tree.nodes[1].item, "c")
        
        // Assert Index
        for (index, node) in tree.nodes.enumerated() {
            XCTAssertEqual(node.index, index)
        }

    }
    
    func testRemoveAll() {
        // Given
        var tree = FlatTree<String>()
        tree.append(["a", "b", "c"], to: nil)
        tree.append(["d"], to: "a")
        
        XCTAssertEqual(tree.nodes.count, 4)
        
        // When
        tree.removeAll()
        
        // Then
        XCTAssertTrue(tree.nodes.isEmpty)
    }


    static var allTests = [
        ("testAppend", testAppend),
    ]
}
