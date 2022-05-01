//
//  TweetManager.swift
//  TweetList
//
//  Created by iOS Developer on 30/04/22.
//

import Foundation

class TweetsManager: NSObject {
	// MARK: - Properties
	// Public
	static let shared = TweetsManager()
	// Private
	private var tweets: [Tweet] = []

	// MARK: - Public Methods
	func initializeWithTweetIds(_ tweetIds: [String]) {
		tweets = buildIndexedTweets(tweetIds)
	}

	func count() -> Int {
		return tweets.count
	}

	func all() -> [Tweet] {
		return tweets
	}

	func getByIdx(_ idx: Int) -> Tweet? {
		return tweets.first { $0.idx == idx }
	}

	// MARK: - Private Methods
	private func buildIndexedTweets(_ tweetIds: [String]) -> [Tweet] {
		return tweetIds.enumerated().map { (idx, id) in
			return Tweet(id: id, idx: idx)
		}
	}
}
