//
//  TweetListViewModel.swift
//  TweetList
//
//  Created by iOS Developer on 30/04/22.
//

import UIKit

class TweetListViewModel: NSObject {
	// MARK: - Properties
	// Private
	private let jsonFileName = "TweetList"
	private let jsonFileExtension = "json"
	// Public
	let defaultCellHeightForTweet: CGFloat = 1000
	let defaultCellHeightForOthers: CGFloat = 20
	let tweetPadding: CGFloat = 20
	let htmlTemplate =  "<html><head><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'></head><body><div id='wrapper'></div></body></html>"
	let heightCallback = "heightCallback"
	let clickCallback = "clickCallback"
	var list: [TweetListModel] = []

	override init() {
		super.init()
		getTweetList()
	}

	// MARK: - Public Methods
	func getTweetList() {
		guard let url = Bundle.main.url(forResource: jsonFileName,
										withExtension: jsonFileExtension) else { return }
		do {
			let data = try Data(contentsOf: url)
			let jsonDecoder = JSONDecoder()
			list = try jsonDecoder.decode([TweetListModel].self, from: data)
			for (index, model) in list.enumerated() {
				var model = model
				if model.webview.first?.isTwitter == true {
					model.setHeight(defaultCellHeightForTweet)
				} else {
					model.setHeight(defaultCellHeightForOthers)
				}
				list[index] = model
			}
		} catch {
			print("Error reading JSON file ==== \(error.localizedDescription)")
		}
	}

	func getModelAt(_ index: Int) -> TweetListModel? {
		if list.indices.contains(index) {
			return list[index]
		}
		return nil
	}

	func updateModelAt(_ model: TweetListModel, index: Int) {
		if list.indices.contains(index) {
			list[index] = model
		}
	}

	func getUpdatedHtml(_ string: String) -> String {
		return "<html><head><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'></head><body><div id='wrapper'>" + string + "</div></body></html>"
	}
}
