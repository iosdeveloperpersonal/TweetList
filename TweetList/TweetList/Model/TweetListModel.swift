//
//  TweetListModel.swift
//  TweetList
//
//  Created by iOS Developer on 30/04/22.
//

import UIKit
import WebKit

struct TweetListModel: Codable {
	// MARK: - Properties
	// Public
	let title: String
	let webview: [TweetListWebviewModel]
	var isLoaded = false
	var height: CGFloat = 1000
	var webView: WKWebView?

	// MARK: - Enum
	enum CodingKeys: String, CodingKey {
		case title
		case webview
	}

	// MARK: - Public Methods
	mutating func setHeight(_ value: CGFloat) {
		height = value
	}

	mutating func setWebView(_ value: WKWebView) {
		webView = value
	}
}

struct TweetListWebviewModel: Codable {
	// MARK: - Properties
	// Public
	let isTwitter: Bool
	let webview: String
	let twitterUrl: String
	var twitterId: String {
		return twitterUrl.components(separatedBy: "/").last ?? ""
	}

	// MARK: - Enum
	enum CodingKeys: String, CodingKey {
		case isTwitter
		case webview
		case twitterUrl
	}
}
