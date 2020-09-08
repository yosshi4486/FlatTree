//
//  GroupTests.swift
//  
//
//  Created by seijin4486 on 2020/09/02.
//

import XCTest
@testable import FlatTree

class GroupTests : XCTestCase {
    
    func testSlice() {
        let group = Group<String>(nodes: [
            Node(item: "a", indentationLevel: 0),
            Node(item: "b", indentationLevel: 0),
            Node(item: "c", indentationLevel: 0),
            Node(item: "d", indentationLevel: 0),
            Node(item: "e", indentationLevel: 0),
        ],
        indentationLevel: 1,
        firstNodeIndex: 4)
        
        let result = group.split(after: "a")!
        
        // Count of nodes
        XCTAssertEqual(result.left.nodes.count, 1)
        XCTAssertEqual(result.right.nodes.count, 4)

        // Item identifiers
        XCTAssertEqual(result.left.nodes[0].item, "a")
        XCTAssertEqual(result.right.nodes[0].item, "b")
        XCTAssertEqual(result.right.nodes[1].item, "c")
        XCTAssertEqual(result.right.nodes[2].item, "d")
        XCTAssertEqual(result.right.nodes[3].item, "e")
        
        // Indentation level
        XCTAssertEqual(result.left.indentationLevel, 1)
        XCTAssertEqual(result.left.indentationLevel, result.right.indentationLevel)
        
        // First node index
        XCTAssertEqual(result.left.firstNodeIndex, 4)
        XCTAssertEqual(result.right.firstNodeIndex, 4)
        
    }
    
    func testCount() {
        let group = Group<String>(nodes: [
            Node(item: "a", indentationLevel: 0),
            Node(item: "b", indentationLevel: 0),
            Node(item: "c", indentationLevel: 0),
            Node(item: "d", indentationLevel: 0),
            Node(item: "e", indentationLevel: 0),
        ],
        indentationLevel: 1,
        firstNodeIndex: 4)
        
        XCTAssertEqual(group.count, 5)
    }
    
    func testIndex() {
        let group = Group<String>(nodes: [
            Node(item: "a", indentationLevel: 0),
            Node(item: "b", indentationLevel: 0),
            Node(item: "c", indentationLevel: 0),
            Node(item: "d", indentationLevel: 0),
            Node(item: "e", indentationLevel: 0),
        ],
        indentationLevel: 1,
        firstNodeIndex: 4)
        
        XCTAssertEqual(group.index(of: "a")!, 4)
        XCTAssertEqual(group.index(of: "b")!, 5)
        XCTAssertEqual(group.index(of: "c")!, 6)
        XCTAssertEqual(group.index(of: "d")!, 7)
        XCTAssertEqual(group.index(of: "e")!, 8)
    }
    
    func testJoin() {
        let group1 = Group<String>(nodes: [
            Node(item: "a", indentationLevel: 0),
            Node(item: "b", indentationLevel: 0),
            Node(item: "c", indentationLevel: 0),
            Node(item: "d", indentationLevel: 0),
            Node(item: "e", indentationLevel: 0),
        ],
        indentationLevel: 1,
        firstNodeIndex: 4)
        
        let group2 = Group<String>(nodes: [
            Node(item: "f", indentationLevel: 0),
            Node(item: "g", indentationLevel: 0),
            Node(item: "h", indentationLevel: 0)
        ],
        indentationLevel: 1,
        firstNodeIndex: 8)
        
        
        let result = group1.joined(group2)!
        XCTAssertEqual(result.nodes[0].item, "a")
        XCTAssertEqual(result.nodes[1].item, "b")
        XCTAssertEqual(result.nodes[2].item, "c")
        XCTAssertEqual(result.nodes[3].item, "d")
        XCTAssertEqual(result.nodes[4].item, "e")
        XCTAssertEqual(result.nodes[5].item, "f")
        XCTAssertEqual(result.nodes[6].item, "g")
        XCTAssertEqual(result.nodes[7].item, "h")
        
        XCTAssertEqual(result.indentationLevel, 1)
        XCTAssertEqual(result.firstNodeIndex, 4)
    }
    
    func testJoinFailure() {
        let group1 = Group<String>(nodes: [
            Node(item: "a", indentationLevel: 0),
            Node(item: "b", indentationLevel: 0),
            Node(item: "c", indentationLevel: 0),
            Node(item: "d", indentationLevel: 0),
            Node(item: "e", indentationLevel: 0),
        ],
        indentationLevel: 1,
        firstNodeIndex: 4)
        
        let group2 = Group<String>(nodes: [
            Node(item: "f", indentationLevel: 0),
            Node(item: "g", indentationLevel: 0),
            Node(item: "h", indentationLevel: 0)
        ],
        indentationLevel: 2,
        firstNodeIndex: 8)
        
        XCTAssertNil(group1.joined(group2))
    }

}
