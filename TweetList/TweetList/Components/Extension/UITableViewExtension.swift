//
//  UITableViewExtension.swift
//  TweetList
//
//  Created by iOS Developer on 30/04/22.
//

import UIKit

extension UITableView {
	func reloadRowWithoutAnimation(_ indexPath: IndexPath) {
		let lastScrollOffset = contentOffset
		UIView.performWithoutAnimation {
			reloadRows(at: [indexPath], with: .none)
		}
		setContentOffset(lastScrollOffset, animated: false)
	}
}
