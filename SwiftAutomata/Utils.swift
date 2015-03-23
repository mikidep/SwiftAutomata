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

/// A 2-dimensional table
public struct Table<X: Hashable, Y: Hashable, V> {
	var stored: [Pair<X,Y>: V] = [:]
	
	public var keys: [(X, Y)] {
		var res: [(X, Y)] = []
		for (pair, _) in stored {
			res.append((pair.x, pair.y))
		}
		return res
	}
	
	public subscript (x: X, y: Y) -> V? {
		get {
			return stored[Pair<X, Y>(x: x, y: y)]
		}
		set {
			stored[Pair<X, Y>(x: x, y: y)] = newValue
		}
	}
}