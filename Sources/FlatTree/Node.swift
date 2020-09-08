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
    var index: Int = 0
    
    /// The indentation level of the node.
    var indentationLevel: Int
    
    /// The parrent of the node.
    weak var parent: Node<ItemIdentifierType>?
    
    /// The children of the node.
    var children: [Node<ItemIdentifierType>] = []
                    
    init(item: ItemIdentifierType,
         indentationLevel: Int,
         id: UUID = .init(),
         parent: Node<ItemIdentifierType>? = nil,
         children: [Node<ItemIdentifierType>] = []) {
        self.item = item
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
