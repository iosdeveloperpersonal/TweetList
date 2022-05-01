//
//  WidgetsJsManager.swift
//  TweetList
//
//  Created by iOS Developer on 30/04/22.
//

import Foundation

class WidgetsJsManager: NSObject {
	// MARK: - Properties
	// Public
	static let shared = WidgetsJsManager()
	// Private
	private var content: String?

	// MARK: - Public Methods
	func load() {
		do {
			content = try String(contentsOf: URL(string: "https://platform.twitter.com/widgets.js")!)
		} catch {
			print("Could not load widgets.js script")
		}
	}

	func getScriptContent() -> String? {
		return content
	}
}
