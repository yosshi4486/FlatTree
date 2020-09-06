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
            
            // 1. Append nodes to parent
            let startIndexForChildNodes = parentNode.index + parentNode.children.count + 1
            let newNodes = children.enumerated().map({ Node<ItemIdentifierType>(item: $1,
                                                                                index: $0 + startIndexForChildNodes,
                                                                                indentationLevel: parentNode.indentationLevel + 1,
                                                                                parent: parentNode) })
            parentNode.children.append(contentsOf: newNodes)
            hashTable.merge(zip(children, newNodes)) { (_, new) in new }
            
            // 2. Reindexing
            newNodes.last?.setNeedsReindexing()
            reindex(stride: children.count, in: containerRootNode)
            
        } else {
            // 1. Append nodes to root
            let startIndexForChildNodes = containerRootNode.children.count
            
            let newNodes = children.enumerated().map({ Node<ItemIdentifierType>(item: $1,
                                                                                index: $0 + startIndexForChildNodes,
                                                                                indentationLevel: 0 )} )
            containerRootNode.children.append(contentsOf: newNodes)
            hashTable.merge(zip(children, newNodes)) { (_, new) in new }
        }
    }
    
    mutating func insert(_ items: [ItemIdentifierType], before identifier: ItemIdentifierType) {
        
        guard let node = hashTable[identifier] else {
            return
        }
        
        if let parentNode = node.parent, let indexInParent = parentNode.children.firstIndex(of: node) {
            
            // 1. Keep index
            let startIndexForChildNodes = node.index
                        
            // 2. Insert nodes before
            let newNodes = items.enumerated().map({ Node<ItemIdentifierType>(item: $1,
                                                                             index: $0 + startIndexForChildNodes,
                                                                             indentationLevel: node.indentationLevel,
                                                                             parent: parentNode)})
            parentNode.children.insert(contentsOf: newNodes, at: indexInParent)
            hashTable.merge(zip(items, newNodes)) { (_, new) in new }
            
            // 3. Reindex
            newNodes.last?.setNeedsReindexing()
            reindex(stride: items.count, in: containerRootNode)

        } else if let indexInRoot = containerRootNode.children.firstIndex(of: node) {
            
            // 1. Keep index
            let startIndexForChildNodes = node.index
            
            // 2. Insert nodes before
            let newNodes = items.enumerated().map({ Node<ItemIdentifierType>(item: $1,
                                                                             index: $0 + startIndexForChildNodes,
                                                                             indentationLevel: node.indentationLevel )})
            containerRootNode.children.insert(contentsOf: newNodes, at: indexInRoot)
            hashTable.merge(zip(items, newNodes)) { (_, new) in new }

            // 2. Reindex
            newNodes.last?.setNeedsReindexing()
            reindex(stride: items.count, in: containerRootNode)

        }
        
    }
    
    mutating func insert(_ items: [ItemIdentifierType], after identifier: ItemIdentifierType) {
        
        guard let node = hashTable[identifier] else {
            return
        }
        
        if let parentNode = node.parent, let indexInParent = parentNode.children.firstIndex(of: node) {
            
            // 1. Keep index
            let startIndexForChildNode = node.lastIndexOfSubtree + 1
                        
            // 2. Insert nodes after
            let newNodes = items.enumerated().map({ Node<ItemIdentifierType>(item: $1,
                                                                             index: $0 + startIndexForChildNode,
                                                                             indentationLevel: node.indentationLevel,
                                                                             parent: parentNode)})
            parentNode.children.insert(contentsOf: newNodes, at: indexInParent + 1)
            hashTable.merge(zip(items, newNodes)) { (_, new) in new }
            
            // 3. Reindex
            newNodes.last?.setNeedsReindexing()
            reindex(stride: items.count, in: containerRootNode)

        } else if let indexInRoot = containerRootNode.children.firstIndex(of: node) {
            
            // 1. Keep index
            let startIndexForChildNode = node.lastIndexOfSubtree + 1
                        
            // 2. Insert nodes after
            let newNodes = items.enumerated().map({ Node<ItemIdentifierType>(item: $1,
                                                                             index: $0 + startIndexForChildNode,
                                                                             indentationLevel: node.indentationLevel )})
            containerRootNode.children.insert(contentsOf: newNodes, at: indexInRoot + 1)
            hashTable.merge(zip(items, newNodes)) { (_, new) in new }

            // 3. Reindex
            newNodes.last?.setNeedsReindexing()
            reindex(stride: items.count, in: containerRootNode)
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
            
            // To keep marked node, reindex is pre-processed.
            
            // 1. Reindex
            aNode.setNeedsReindexing()
            reindex(stride: -1, in: containerRootNode)
            
            // 2. Remove
            aParent.children.remove(at: index)
            hashTable.removeValue(forKey: item)
        }
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
    private func reindex(stride: Int, in node: Node<ItemIdentifierType>) {
        
        // Pruning that skips unnecessary left nodes.
        guard let markedNodeIndex = node.children.firstIndex(where: { $0.needsReindexing }) else {
            return
        }
        
        for child in node.children[markedNodeIndex...(node.children.count-1)] {
            
            let isMarkedAndLeadingChildNode = child.needsReindexing
            if isMarkedAndLeadingChildNode {
                child.needsReindexing = false
                
                // If the node is marked, it will try to find next mark in the children.
                reindex(stride: stride, in: child)
            } else {
                
                // If nodes are located on right of a marked node, they should reindex.
                reindexAll(stride: stride, in: child)
            }
        }
    }
    
    /// Reindex right nodes of maked node.
    private func reindexAll(stride: Int, in node: Node<ItemIdentifierType>) {
        node.index += stride

        for child in node.children {
            reindexAll(stride: stride, in: child)
        }
    }

}
