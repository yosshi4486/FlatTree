//
//  FlatTree.swift
//
//
//  Created by seijin4486 on 2020/09/02.
//

/// A flat tree primary aim is providing constant time fast search to configure  single dimensional table structure.
///
/// To implement constant search, both tree structure and hashtable are used. Nodes would't keep their correct index even if there is only hashtable, so the tree is used to keep correct indexes.
/// A flat tree needs to  reindex whenever a mutating operation e.g. append, insert and delete  is executed. Those operations cost O(n).
///
/// It might be called to NativeTree.
struct FlatTree<ItemIdentifierType> where ItemIdentifierType : Hashable {
        
    /// The node acts only as a container that never references its item property. It is useful to traverse the tree.
    private var containerRootNode: Node<ItemIdentifierType> = Node.empty()
    
    /// The hash table for providing constant time search.
    private var hashTable: [ItemIdentifierType : Node<ItemIdentifierType>] = [:]
    
    // - MARK: Basic operation of tree. Search, append, insert and delete.
    
    mutating func append(_ children: [ItemIdentifierType], to parent: ItemIdentifierType? = nil) {
        
        if let aParent = parent, let parentNode = hashTable[aParent] {
            
            let newNodes = children.enumerated().map({ Node<ItemIdentifierType>(item: $1,
                                                                                indentationLevel: parentNode.indentationLevel + 1,
                                                                                parent: parentNode) })
            parentNode.children.append(contentsOf: newNodes)
            hashTable.merge(zip(children, newNodes)) { (_, new) in new }
        } else {
            let newNodes = children.enumerated().map({ Node<ItemIdentifierType>(item: $1,
                                                                                indentationLevel: 0,
                                                                                parent: containerRootNode)} )
            containerRootNode.children.append(contentsOf: newNodes)
            hashTable.merge(zip(children, newNodes)) { (_, new) in new }
        }
    }
    
    mutating func insert(_ items: [ItemIdentifierType], before identifier: ItemIdentifierType) {
        
        guard let node = hashTable[identifier], let indexInParent = node.indexInParent else {
            return
        }
        
        let newNodes = items.enumerated().map({ Node<ItemIdentifierType>(item: $1,
                                                                         indentationLevel: node.indentationLevel,
                                                                         parent: node.parent)})
        node.parent?.children.insert(contentsOf: newNodes, at: indexInParent)
        hashTable.merge(zip(items, newNodes)) { (_, new) in new }
    }
    
    mutating func insert(_ items: [ItemIdentifierType], after identifier: ItemIdentifierType) {
        
        guard let node = hashTable[identifier], let indexInParent = node.indexInParent else {
            return
        }
                                    
        let newNodes = items.enumerated().map({ Node<ItemIdentifierType>(item: $1,
                                                                         indentationLevel: node.indentationLevel,
                                                                         parent: node.parent)})
        node.parent?.children.insert(contentsOf: newNodes, at: indexInParent + 1)
        hashTable.merge(zip(items, newNodes)) { (_, new) in new }
    }
    
    mutating func remove(_ items: [ItemIdentifierType]) {
        for item in items {
            hashTable[item]?.removeFromParent()
            hashTable.removeValue(forKey: item)
        }
    }
    
    mutating func removeAll() {
        containerRootNode.children = []
        hashTable.removeAll()
    }
    
    mutating func performBatchUpdates(_ updates: ((inout FlatTree<ItemIdentifierType>)-> Void)?, completion: ((Bool) -> Void)? = nil) {
        updates?(&self)
        reindex()
        completion?(true)
    }
    
}

// - MARK: - Computed Properties
extension FlatTree {
    
    /// - Complexity: O(n log n)
    var nodes: [Node<ItemIdentifierType>] { hashTable.sorted(by: { $0.value.index < $1.value.index }).map { $0.value } }

}

// - MARK: Reindex
extension FlatTree {
    
    /// Must call the method after calling a mutating methods if it isn't executed in `performBatchUpdates(_:completion:)`
    ///
    /// - Complexity: always O(V+E) where V is a number of vertexes, E is a number of edges.
    func reindex() {
        var index: Int = 0
        traverseDFSPreOrder(node: containerRootNode, index: &index)
    }
    
    private func traverseDFSPreOrder(node: Node<ItemIdentifierType>, index: inout Int) {
        if node != containerRootNode {
            node.index = index
            index += 1
        }
        
        for child in node.children {
            traverseDFSPreOrder(node: child, index: &index)
        }
    }

    
}
