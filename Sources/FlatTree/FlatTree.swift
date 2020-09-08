//
//  FlatTree.swift
//
//
//  Created by seijin4486 on 2020/09/02.
//

/// A flat tree primary aim is providing constant time fast search to configure efficient single dimensional table structure.
///
/// To implement constant search, both tree structure and hashtable are used. Nodes would't keep their correct index even if there is only hashtable, so the tree is used to keep correct indexes.
/// A flat tree needs to  reindex whenever a mutating operation e.g. append, insert and delete  is executed. Those operations cost O(n).
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
            
            reindex()
            
        } else {
            let newNodes = children.enumerated().map({ Node<ItemIdentifierType>(item: $1,
                                                                                indentationLevel: 0 )} )
            containerRootNode.children.append(contentsOf: newNodes)
            hashTable.merge(zip(children, newNodes)) { (_, new) in new }
            
            reindex()
        }
    }
    
    mutating func insert(_ items: [ItemIdentifierType], before identifier: ItemIdentifierType) {
        
        guard let node = hashTable[identifier] else {
            return
        }
        
        if let parentNode = node.parent, let indexInParent = parentNode.children.firstIndex(of: node) {
                                    
            let newNodes = items.enumerated().map({ Node<ItemIdentifierType>(item: $1,
                                                                             indentationLevel: node.indentationLevel,
                                                                             parent: parentNode)})
            parentNode.children.insert(contentsOf: newNodes, at: indexInParent)
            hashTable.merge(zip(items, newNodes)) { (_, new) in new }
            
            reindex()

        } else if let indexInRoot = containerRootNode.children.firstIndex(of: node) {
                        
            let newNodes = items.enumerated().map({ Node<ItemIdentifierType>(item: $1,
                                                                             indentationLevel: node.indentationLevel )})
            containerRootNode.children.insert(contentsOf: newNodes, at: indexInRoot)
            hashTable.merge(zip(items, newNodes)) { (_, new) in new }

            reindex()

        }
        
    }
    
    mutating func insert(_ items: [ItemIdentifierType], after identifier: ItemIdentifierType) {
        
        guard let node = hashTable[identifier] else {
            return
        }
        
        if let parentNode = node.parent, let indexInParent = parentNode.children.firstIndex(of: node) {
                                    
            let newNodes = items.enumerated().map({ Node<ItemIdentifierType>(item: $1,
                                                                             indentationLevel: node.indentationLevel,
                                                                             parent: parentNode)})
            parentNode.children.insert(contentsOf: newNodes, at: indexInParent + 1)
            hashTable.merge(zip(items, newNodes)) { (_, new) in new }
            
            reindex()

        } else if let indexInRoot = containerRootNode.children.firstIndex(of: node) {
                                    
            let newNodes = items.enumerated().map({ Node<ItemIdentifierType>(item: $1,
                                                                             indentationLevel: node.indentationLevel )})
            containerRootNode.children.insert(contentsOf: newNodes, at: indexInRoot + 1)
            hashTable.merge(zip(items, newNodes)) { (_, new) in new }

            reindex()
        }
        
    }
    
    mutating func remove(_ items: [ItemIdentifierType]) {
        for item in items {
            
            guard let aNode = hashTable[item] else {
                return
            }
            
            let aParent: Node<ItemIdentifierType> = {
                if let parent = aNode.parent {
                    return parent
                } else {
                    return containerRootNode
                }
            }()
            
            guard let index = aParent.children.firstIndex(of: aNode) else {
                return
            }
                        
            aParent.children.remove(at: index)
            hashTable.removeValue(forKey: item)
        }
        
        reindex()
    }
    
    mutating func removeAll() {
        containerRootNode.children = []
        hashTable.removeAll()
    }
    
}

// - MARK: - Computed Properties
extension FlatTree {
    
    /// - Complexity: O(n)
    var nodes: [Node<ItemIdentifierType>] { hashTable.sorted(by: { $0.value.index < $1.value.index }).map { $0.value } }

}

// - MARK: Reindex
extension FlatTree {
    
    /// For implement reindex,  we adopt 'marking' path nodes from changed node to root node, then do reindexing right subtrees.
    ///
    /// - Complexity: always O(n)
    func reindex() {
        var index: Int = 0
        
        func traverseDFSPreOrder(node: Node<ItemIdentifierType>) {
            if node != containerRootNode {
                node.index = index
                index += 1
            }
            
            node.children.forEach { traverseDFSPreOrder(node: $0) }
        }
        
        traverseDFSPreOrder(node: containerRootNode)
    }
    
}
