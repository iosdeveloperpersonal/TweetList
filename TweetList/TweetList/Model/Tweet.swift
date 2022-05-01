//
//  Tweet.swift
//  TweetList
//
//  Created by iOS Developer on 30/04/22.
//

import Foundation
import WebKit

class Tweet: NSObject {
	// MARK: - Properties
	// Public
	let id: String
	let idx: Int
	var height: CGFloat = 1000
	var webView: WKWebView?

	// MARK: - Initializer
	init(id: String, idx: Int) {
		self.id = id
		self.idx = idx
	}

	// MARK: - Public Methods
	func setHeight(_ value: CGFloat) {
		height = value
	}

	func setWebView(_ value: WKWebView) {
		webView = value
	}
}
