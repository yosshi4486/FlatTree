//
//  Node.swift
//  
//
//  Created by seijin4486 on 2020/09/02.
//

import Foundation

/// A node of tree. It can behave as a subtree.
public final class Node<ItemIdentifierType> : Hashable where ItemIdentifierType : Hashable {
   
    /// The identifier that identifies itself.
    public let id: UUID
    
    /// The actual content
    public let item: ItemIdentifierType!
    
    /// The index in tree.
    public var index: Int = 0
    
    /// The indentation level of the node.
    public var indentationLevel: Int
    
    /// The value whether the node is expanded or collapsed.
    public var isExpanded: Bool = false
    
    /// The parrent of the node.
    public weak var parent: Node<ItemIdentifierType>?
    
    /// The children of the node.
    public var children: [Node<ItemIdentifierType>] = []
                    
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
        self.isExpanded = true
        self.id = UUID()
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: Node, rhs: Node) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func empty() -> Node<ItemIdentifierType> {
        return self.init()
    }
    
}

extension Node {
    
    /// Returns an index in the parent.
    public var indexInParent: Int? {
        guard let aParent = parent else {
            return nil
        }
        
        return aParent.children.firstIndex(of: self)
    }
    
    /// Removes self from the parent.
    public func removeFromParent() {
        guard let index = indexInParent else {
            return
        }
        
        parent?.children.remove(at: index)
    }
    
}
