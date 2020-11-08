//
//  main.swift
//  LinkedList
//
//  Created by David Perez on 07/11/20.
//

import Foundation

func example(of: String, block: () -> Void){
    print("-- Example \(of) --")
    block()
}

example(of: "Adding nodes to linked list") {
    typealias PrintThis = (_ str: String) -> Void
    var list = LinkedList<PrintThis>()
    let hello: PrintThis = {str in print(str)}
    list.push(hello)
    print(list)
}

public class Node<Value> {
    public var value: Value
    public var next: Node?
    
    public init (value: Value, next:Node? = nil){
        self.value = value
        self.next = next
    }
}

extension Node: CustomStringConvertible{
    public var description: String {
        guard let next = next else {
            return "\(value)"
        }
        return "\(value) -> " + String(describing: next) + "\n"
    }
}

public struct LinkedList<Value>{
    
    public var head: Node<Value>?
    public var tail: Node<Value>?
    
    public init(){}
    public var isEmpty: Bool {
        return head == nil
    }
}

extension LinkedList: CustomStringConvertible {
    
    public var description: String {
        guard let head = head else {
            return "Empty List"
        }
        return String(describing: head)
    }
}

// MARK: - Functions
extension LinkedList {
    public mutating func push(_ value: Value){
        head = Node(value: value, next: head)
        if tail == nil {
            tail = head
        }
    }
}


// MARK: - Collection Extension

extension LinkedList: Collection{
    
    public struct Index: Comparable{
        public var node: Node<Value>?
        static public func == (lhs:Index, rhs:Index) -> Bool {
            switch (lhs.node, rhs.node) {
            case let (left?, right?):
                return left.next === right.next
            case (nil, nil):
                return true
            default:
                return false
            }
        }
        static public func <(lhs:Index, rhs:Index) -> Bool {
            guard lhs != rhs else {
                return false
            }
            let nodes = sequence(first: lhs.node) { $0?.next }
            return nodes.contains { $0 === rhs.node}
        }
    }
    public var startIndex: Index {
        return Index(node: head)
    }
    
    public var endIndex: Index {
        return Index(node: tail?.next)
    }
    public func index(after i: Index) -> Index {
        return Index(node: i.node?.next)
    }
    public subscript(position: Index) -> Value {
        return position.node!.value
    }
}

// MARK: - Implementing COW

extension LinkedList {
    private mutating func copyNodes(){
        guard !isKnownUniquelyReferenced(&head) else {
            return
        }
        guard var oldNode = head else {
            return
        }
        head = Node(value: oldNode.value)
        var newNode = head
        while let nextOldNode = oldNode.next {
            newNode!.next = Node(value: nextOldNode.value)
            newNode = newNode!.next
            
            oldNode = nextOldNode
        }
        tail = newNode
    }
}
