//
//  Utils.swift
//  SwiftNFA
//
//  Created by Michele De Pascalis on 01/03/15.
//  Copyright (c) 2015 Michele De Pascalis. All rights reserved.
//

public struct Pair<X: Hashable, Y: Hashable>: Hashable {
	let x: X
	let y: Y
	
	init(x: X, y: Y) {
		self.x = x
		self.y = y
	}
	
	public var hashValue: Int {
		return x.hashValue << 32 | (y.hashValue & 0xffffffff)
	}
}

public func == <X: Hashable, Y: Hashable> (lhs: Pair<X, Y>, rhs: Pair<X, Y>) -> Bool {
	return lhs.x == rhs.x && lhs.y == rhs.y
}

/// A Table implementation that does store information about its keys.
public struct Table<X: Hashable, Y: Hashable, V> {
	var stored: [Int: V] = [:]
	var storedKeys: Set<Pair<X, Y>> = []
	
	public var keys: [(x: X, y:Y)] {
		var tmp: [(x: X, y:Y)] = []
		for pair in storedKeys {
			tmp.append((x: pair.x, y: pair.y))
		}
		return tmp
	}
	
	public subscript (x: X, y: Y) -> V? {
		get {
			return stored[Pair(x: x, y: y).hashValue]
		}
		set {
			storedKeys.insert(Pair(x: x, y: y))
			stored[Pair(x: x, y: y).hashValue] = newValue
		}
	}
}