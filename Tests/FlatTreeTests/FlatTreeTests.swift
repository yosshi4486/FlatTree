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
    
    func testPerformanceAppend() {
        // if the number is bigger than 14948, appendWithParent and insert always crash.
        // but I don't know the reason.
        let inputSize = 14948
        
        // Typically, a dataset should be generated by every test case. but I use class variables for reducing the cost of setting up it.
        var tree = FlatTree<UUID>()
        var allNodes: [UUID] = []
                                            
        var parent = UUID()
        tree.append([parent])
        
        print("Start setup datasources")
        // Unbalanced and deep depth tree.
        for i in 0...inputSize {
            let startDate = Date()
            let node = UUID()
            tree.append([node], to: parent)
            parent = node
            allNodes.append(node)
            
            if i % 500 == 0 {
                print("Current: \(String(format: "%.1f", Double(i) / Double(inputSize) * 100)) %")
                
                let elapsed = (Date().timeIntervalSince(startDate))
                let formatedElapsed = String(format: "%.5f", elapsed)
                
                print("Time: \(formatedElapsed)")
            }
        }
        print("Completed setup datasources")
        
        measure {
            tree.append([UUID()], to: parent)
        }
        
    }


    static var allTests = [
        ("testAppend", testAppend),
    ]
}
