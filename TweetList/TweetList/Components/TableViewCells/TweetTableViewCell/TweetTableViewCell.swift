//
//  TweetTableViewCell.swift
//  TweetList
//
//  Created by iOS Developer on 30/04/22.
//

import UIKit
import WebKit

class TweetTableViewCell: UITableViewCell {
	// MARK: - Interface Builder
	// UILabel
	@IBOutlet weak var viewWebView: UIView!

	override func prepareForReuse() {
		super.prepareForReuse()
		viewWebView.subviews.forEach({ view in
			if view is WKWebView {
				view.removeFromSuperview()
			}
		})
	}

	// MARK: - Public Methods
	func configureCell(_ model: TweetListModel, index: Int) {
		if let webView = model.webView {
			if !viewWebView.subviews.contains(where: { $0 is WKWebView }) {
				viewWebView.addSubview(webView)
				webView.translatesAutoresizingMaskIntoConstraints = false
				viewWebView.addConstraints([
					webView.topAnchor.constraint(equalTo: viewWebView.topAnchor),
					webView.leadingAnchor.constraint(equalTo: viewWebView.leadingAnchor),
					webView.bottomAnchor.constraint(equalTo: viewWebView.bottomAnchor),
					webView.trailingAnchor.constraint(equalTo: viewWebView.trailingAnchor)
				])
			}
		}
	}
}
