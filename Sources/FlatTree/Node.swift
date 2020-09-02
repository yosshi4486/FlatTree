//
//  Node.swift
//  
//
//  Created by seijin4486 on 2020/09/02.
//

import Foundation

/// A node of tree. It can behave as a subtree.
final class Node<ItemIdentifierType> : Hashable where ItemIdentifierType : Hashable {
   
    /// The identifier that identifies itself.
    let id: UUID
    
    /// The actual content
    let item: ItemIdentifierType!
    
    /// The index in tree.
    var index: Int
    
    /// The indentation level of the node.
    var indentationLevel: Int
    
    /// The parrent of the node.
    weak var parent: Node<ItemIdentifierType>?
    
    /// The children of the node.
    var children: [Node<ItemIdentifierType>] = []
    
    /// The value that indicates where the node needs reindexing.
    var needsReindexing = false
    
    /// The last index of the substree.
    var lastIndexOfSubtree: Int {
        var result = index
        
        func traverse(node: Node<ItemIdentifierType>?) {
            guard let aNode = node else {
                return
            }
            result = aNode.index
            traverse(node: aNode.children.last)
        }
        // O(d) where d is depth of the subtree.
        traverse(node: children.last)
        
        return result
    }
    
    /// The functions marks node to indicate needs like a `setNeedsDisplay` and `setNeedsLayout`
    func setNeedsReindexing() {
        needsReindexing = true
        
        func setNeedesReindexingToRoot(node: Node<ItemIdentifierType>?) {
            guard let aNode = node, aNode.index != -1 else { // -1 is container node.
                return
            }
            aNode.needsReindexing = true
            setNeedesReindexingToRoot(node: aNode.parent)
        }
        setNeedesReindexingToRoot(node: parent)
    }
            
    init(item: ItemIdentifierType,
         index: Int,
         indentationLevel: Int,
         id: UUID = .init(),
         parent: Node<ItemIdentifierType>? = nil,
         children: [Node<ItemIdentifierType>] = []) {
        self.item = item
        self.index = index
        self.indentationLevel = indentationLevel
        self.id = id
        self.parent = parent
        self.children = children
    }
    
    private init() {
        // if it is the root node of the tree, the item is not referenced from anywhere.
        self.item = nil
        self.index = -1
        self.indentationLevel = -1
        self.id = UUID()
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Node, rhs: Node) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func empty() -> Node<ItemIdentifierType> {
        return self.init()
    }
    
}
