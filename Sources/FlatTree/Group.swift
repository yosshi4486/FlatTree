//
//  Group.swift
//  
//
//  Created by seijin4486 on 2020/09/02.
//

import Foundation

/// A group for mechanizm that manages nodes in single dimentional array.
///
/// The most difficult thing treating a tree data structure for tableview is KEEPING correct index. If it is Btree or B+tree, an index is decided by associated record index column, but in this tree for single dimensional table, an index depends on parent+child relationship and left tree indexes. I explain concrete exapmle bellow
///
///  [] is an indentation level.
///
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
///  ------------
///
///  you can see "b" is depends on "a" subtree deepest leaf's index.
///
/// To solve this problem, I introduce a "Group" concept.
struct Group<Content> where Content : Hashable {
    
    /// The nodes that are managed by the group.
    var nodes: [Node<Content>]
    
    /// The indentation level of the group.
    var indentationLevel: Int

    /// The first node index of the nodes.
    var firstNodeIndex: Int
    
    /// The number of nodes in the group.
    var count: Int { nodes.count }
    
    /// Returns the groups immediately that are split by the item.
    ///
    /// - Parameter item: A item for splitting the group.
    /// - Returns: A left includes nodes that start from nodes.first's index to the given item index. A right includes nodes that start from the given item index + 1 to nodes.last's index. If the group doesn't include the given item, `nil` is returned.
    func split(after item: Content) -> (left: Group, right: Group)? {
        
        guard let itemIndex = nodes.firstIndex(where: { $0.item == item }) else {
            return nil
        }
        
        let leftNodes = Array(nodes[0...itemIndex])
        let rightNodes = Array(nodes[(itemIndex+1)...])
        
        return (left: Group(nodes: leftNodes,
                            indentationLevel: self.indentationLevel,
                            firstNodeIndex: firstNodeIndex),
                right: Group(nodes: rightNodes,
                             indentationLevel: self.indentationLevel,
                             firstNodeIndex: firstNodeIndex))
    }
    
    /// Returns the group immediately that is joined to the other group.
    ///
    /// - Parameter other: An other group to join into self.
    /// - Returns: self.indentationLevel and self.firstNode.index is used to create new group.
    /// - Precondition: other.indentationLevel is equal to self.indentationLevel.
    func joined(_ other: Group) -> Group? {
        
        // I suppose the case is a type of simple domain error.
        guard self.indentationLevel == other.indentationLevel else {
            return nil
        }
        
        return Group(nodes: nodes + other.nodes,
                     indentationLevel: self.indentationLevel,
                     firstNodeIndex: self.firstNodeIndex)
    }
    
    /// Returns the index of the item.
    ///
    /// - Parameter item: A valid item that managed by the group.
    /// - Returns: The computed index value. If the group doesn't contain the given item, `nil` is returned.
    func index(of item: Content) -> Int? {
        
        guard let anIndex = nodes.firstIndex(where: { $0.item == item }) else {
            return nil
        }
        
        return firstNodeIndex + anIndex
    }
    
}
