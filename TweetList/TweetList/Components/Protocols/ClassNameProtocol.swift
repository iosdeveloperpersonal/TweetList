//
//  ClassNameProtocol.swift
//  TweetList
//
//  Created by iOS Developer on 30/04/22.
//

import Foundation

import UIKit

public protocol ClassNameProtocol {
	static var className: String { get }
	var className: String { get }
}

public extension ClassNameProtocol {
	static var className: String {
		return String(describing: self)
	}

	var className: String {
		return type(of: self).className
	}
}

extension NSObject: ClassNameProtocol {}
