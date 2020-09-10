//
//  FlatTree.swift
//
//
//  Created by seijin4486 on 2020/09/02.
//

import Foundation

/// A flat tree primary aim is providing constant time fast search to configure  single dimensional table structure.
///
/// To implement constant search, both tree structure and hashtable are used. Nodes would't keep their correct index even if there is only hashtable, so the tree is used to keep correct indexes.
/// A flat tree needs to  reindex whenever a mutating operation e.g. append, insert and delete  is executed. Those operations cost O(n).
///
/// It might be called to NativeTree.
public struct FlatTree<ItemIdentifierType> where ItemIdentifierType : Hashable {
    
    final class Group : Hashable {
        
        let id: UUID = .init()
        var index: Int
        var indentationLevel: Int
        var isExpanded: Bool
        var items: [Item]
        
        init(index: Int, indentationLevel: Int, isExpanded: Bool, items: [Item]) {
            self.index = index
            self.indentationLevel = indentationLevel
            self.isExpanded = isExpanded
            self.items = items
        }
        
        func split(after itemIdentifier: ItemIdentifierType) -> Group? {
            guard let index = items.firstIndex(where: { $0.value == itemIdentifier }) else {
                return nil
            }
            
            let group = Group(index: -1,
                              indentationLevel: indentationLevel,
                              isExpanded: isExpanded,
                              items: Array(items[(index+1)...]))
            items.removeSubrange((index+1)...)
            return group
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        static func == (lhs: FlatTree.Group, rhs: FlatTree.Group) -> Bool {
            return lhs.id == rhs.id
        }
        
        var indexForNextGroup: Int {
            return index + items.count
        }

    }
    
    final class Item : Hashable {
        
        let id: UUID = .init()
        var indexInGroup: Int
        var value: ItemIdentifierType
        
        init(indexInGroup: Int, value: ItemIdentifierType) {
            self.indexInGroup = indexInGroup
            self.value = value
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        static func == (lhs: FlatTree.Item, rhs: FlatTree.Item) -> Bool {
            return lhs.id == rhs.id
        }

    }
    
    /// The node acts only as a container that never references its item property. It is useful to traverse the tree.
    private var containerRootNode: Node<ItemIdentifierType> = Node.empty()
    
    /// The hash table for providing constant time search.
    private var hashTable: [ItemIdentifierType : Node<ItemIdentifierType>] = [:]
    
    private var groupTable: [ItemIdentifierType : Group] = [:]
    
    private var groups: [Group] = []
    
    public init() { }
    
    // - MARK: Basic operation of tree. Search, append, insert and delete.
    
    /// Appends children to the given parent. if the `parent` is nil, it becomes a root node.
    ///
    /// - Complexity: O(m) where m is the number of items you pass.
    public mutating func append(_ children: [ItemIdentifierType], to parent: ItemIdentifierType? = nil) {
        
        if let parentItemIdentifier = parent,
           let parentGroup = groupTable[parentItemIdentifier],
           let firstChild = children.first {
            
            if let group = groupTable[firstChild] {
                let startIndex = group.items.count
                group.items.append(contentsOf: children.enumerated().map({ Item(indexInGroup: startIndex + $0, value: $1) }))
            } else {
                let items = children.enumerated().map({ Item(indexInGroup: $0, value: $1) })
                let newGroup = Group(index: -1,
                                  indentationLevel: 0,
                                  isExpanded: false,
                                  items: items)
                
                guard let nextGroup = parentGroup.split(after: parentItemIdentifier) else {
                    fatalError()
                }
                
                guard let parentIndex = groups.firstIndex(of: parentGroup) else {
                    fatalError()
                }
                
                groups.insert(newGroup, at: parentIndex+1)
                groups.insert(nextGroup, at: parentIndex+2)
                
                groupTable.merge(zip(children, Array(repeating: newGroup, count: children.count))) { (_, new) in new }
                
                // Override corresponded group by identifiers.
                groupTable.merge(zip(nextGroup.items.map({ $0.value}), Array(repeating: nextGroup, count: nextGroup.items.count))) { (_, new) in new }
                
                reindex(fromGroupIndex: parentIndex+1)
            }
        } else {
            
            let newIndex: Int = {
                // If no previous group, it is first group.
                if let previousGroup = groups.last {
                    return previousGroup.indexForNextGroup
                } else {
                    return 0
                }
            }()
            
            let items = children.enumerated().map({ Item(indexInGroup: $0, value: $1)} )
            let group = Group(index: newIndex,
                              indentationLevel: 0,
                              isExpanded: false,
                              items: items)
            groups.append(group)
            groupTable.merge(zip(children, Array(repeating: group, count: children.count))) { (_, new) in new }
        }
    }
    
    func reindex(fromGroupIndex index: Int) {
        
        for i in index..<groups.count {
            let previousGroup = groups[i - 1]
            let group = groups[i]
            group.index = previousGroup.indexForNextGroup
        }
        
    }
    
    /// Inserts the given items before the given identifier.
    ///
    /// - Complexity: O(m+c) where m is the number of items you pass, c is the number of siblings of the given identifier.
    public mutating func insert(_ items: [ItemIdentifierType], before identifier: ItemIdentifierType) {
        
        guard let node = hashTable[identifier], let indexInParent = node.indexInParent else {
            return
        }
        
        let newNodes = items.enumerated().map({ Node<ItemIdentifierType>(item: $1,
                                                                         indentationLevel: node.indentationLevel,
                                                                         parent: node.parent)})
        node.parent?.children.insert(contentsOf: newNodes, at: indexInParent)
        hashTable.merge(zip(items, newNodes)) { (_, new) in new }
    }
    
    /// Inserts the given items after the given identifier.
    ///
    /// - Complexity: O(m+c) where m is the number of items you pass, c is the number of siblings of the given identifier.
    public mutating func insert(_ items: [ItemIdentifierType], after identifier: ItemIdentifierType) {
        
        guard let node = hashTable[identifier], let indexInParent = node.indexInParent else {
            return
        }
                                    
        let newNodes = items.enumerated().map({ Node<ItemIdentifierType>(item: $1,
                                                                         indentationLevel: node.indentationLevel,
                                                                         parent: node.parent)})
        node.parent?.children.insert(contentsOf: newNodes, at: indexInParent + 1)
        hashTable.merge(zip(items, newNodes)) { (_, new) in new }
    }
    
    /// Removes the given items.
    ///
    /// - Complexity: O(m) where m is the number of items you pass.
    public mutating func remove(_ items: [ItemIdentifierType]) {
        for item in items {
            hashTable[item]?.removeFromParent()
            hashTable.removeValue(forKey: item)
        }
    }
    
    /// Removes all nodes.
    ///
    /// - Complexity: O(n) where n is the number of nodes in the tree.
    public mutating func removeAll() {
        containerRootNode.children = []
        hashTable.removeAll()
    }
    
    /// Processes append, insert and remove operations as a group.
    ///
    /// Performing `reindex` is expensive therefore this method only call it once.
    /// You should use this method in cases where you want to make multiple changes to the tree whenever possible.
    ///
    /// - Complexity: O(n) where n is the number of nodes in the tree.
    public mutating func performBatchUpdates(_ updates: ((inout FlatTree<ItemIdentifierType>)-> Void)?,
                                      completion: ((Bool) -> Void)? = nil) {
        updates?(&self)
        reindex()
        completion?(true)
    }
    
}

// - MARK: - Computed Properties
extension FlatTree {
    
    // - MARK: Nodes
    public var nodes: [Node<ItemIdentifierType>] {
        return hashTable
            .values
            .sorted(by: { $0.index < $1.index })
    }
    
    public var rootNodes: [Node<ItemIdentifierType>] {
        return containerRootNode.children
    }
    
    public var visibleNodes: [Node<ItemIdentifierType>] {
        return hashTable
            .values
            .filter({ isVisible($0.item) })
            .sorted(by: { $0.index < $1.index })
    }
    
    // - MARK: Items
    
    /// - Complexity: O(n log n)
    public var items: [ItemIdentifierType] {
        groups.reduce(into: [ItemIdentifierType]()) { $0.append(contentsOf: $1.items.map({ $0.value })) }
    }
    
    public var rootItems: [ItemIdentifierType] {
        return rootNodes.map { $0.item }
    }
    
    public var visibleItems: [ItemIdentifierType] {
        return visibleNodes
            .map({ $0.item })
    }
    
}

// - MARK: Reindex
extension FlatTree {
    
    /// You must call the method after calling mutating methods if you don't execute it in `performBatchUpdates(_:completion:)`
    ///
    /// - Complexity: O(n) where n is the number of nodes in the tree.
    public func reindex() {
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

// - MARK: Constant Time Methods
extension FlatTree {
    
    /// Returns a level of the given item.
    public func level(of item: ItemIdentifierType) -> Int? {
        return hashTable[item]?.indentationLevel
    }
    
    /// Returns a index of the given item.
    public func index(of item: ItemIdentifierType) -> Int? {
        return hashTable[item]?.index
    }
    
    /// Returns a parent of the given item.
    public func parent(of item: ItemIdentifierType) -> ItemIdentifierType? {
        let node = hashTable[item]
        
        // Eliminate the container node.
        if node?.parent == containerRootNode {
            return nil
        } else {
            return node?.parent?.item
        }
    }
    
    /// Returns a value whether the tree contains the given item.
    public func contains(_ item: ItemIdentifierType) -> Bool {
        return hashTable[item] != nil
    }
    
    /// Returns a value whether the item is expanded.
    public func isExpanded(_ item: ItemIdentifierType) -> Bool {
        return hashTable[item]?.isExpanded ?? false
    }
    
    /// Returns a value whether the item is visible on screen.
    public func isVisible(_ item: ItemIdentifierType) -> Bool {
        return hashTable[item]?.parent?.isExpanded ?? false
    }
    
}

// - MARK: Expand and Collapse
extension FlatTree {
    
    /// Expands the given items.
    ///
    /// - Precondition: The parent of the specified item shoud be expanded. If it doesn't, the program shoud be modified.
    public func expand(_ items: [ItemIdentifierType]) {
        for item in items {
            guard let node = hashTable[item] else {
                return
            }
            
            precondition(node.parent?.isExpanded == true, "The parent shoud be expanded.")
            node.isExpanded = true
        }
        
    }
    
    /// Collapses the given items.
    ///
    /// - Precondition: The parent of the specified item shoud be expanded. If it doesn't, the program shoud be modified.
    public func collapse(_ items: [ItemIdentifierType]) {
        for item in items {
            guard let node = hashTable[item] else {
                return
            }
            
            precondition(node.parent?.isExpanded == true, "The parent shoud be expanded.")
            node.isExpanded = false
        }
    }
    
}

// - MARK: Optional Node's Operations
extension FlatTree {
    
    /// Returns a node that stores the specified item.
    public func node(of item: ItemIdentifierType) -> Node<ItemIdentifierType>? {
        return hashTable[item]
    }
    
    /// Inserts the given nodes before the given node.
    ///
    /// - Complexity: O(m+c) where m is the number of items you pass, c is the number of siblings of the given identifier.
    public mutating func insert(_ nodes: [Node<ItemIdentifierType>], before node: Node<ItemIdentifierType>) {
        guard let indexInParent = node.indexInParent else {
            return
        }
        
        node.parent?.children.insert(contentsOf: nodes, at: indexInParent)
        hashTable.merge(zip(nodes.map({ $0.item }), nodes)) { (_, new) in new }
    }
    
    /// Inserts the given nodes after the given node.
    ///
    /// - Complexity: O(m+c) where m is the number of items you pass, c is the number of siblings of the given identifier.
    public mutating func insert(_ nodes: [Node<ItemIdentifierType>], after node: Node<ItemIdentifierType>) {
        guard let indexInParent = node.indexInParent else {
            return
        }
        
        node.parent?.children.insert(contentsOf: nodes, at: indexInParent + 1)
        hashTable.merge(zip(nodes.map({ $0.item }), nodes)) { (_, new) in new }
    }

    
}
