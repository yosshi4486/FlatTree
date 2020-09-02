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
    let item: ItemIdentifierType
        
    init(item: ItemIdentifierType, id: UUID = .init()) {
        self.item = item
        self.id = id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Node, rhs: Node) -> Bool {
        return lhs.id == rhs.id
    }
    
}
