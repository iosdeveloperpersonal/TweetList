//
//  ViewController.swift
//  TweetList
//
//  Created by iOS Developer on 30/04/22.
//

import UIKit
import WebKit
import SafariServices

class ViewController: UIViewController {
	// MARK: - Interface Builder
	// UITableView
	@IBOutlet weak var tableView: UITableView!

	// UIActivityIndicatorView
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!

		// MARK: - Properties
	// Private
	private let viewModel = TweetListViewModel()
	private let widgetsJsManager = WidgetsJsManager.shared

	// MARK: - Lifecycle Methods
	override func viewDidLoad() {
		super.viewDidLoad()
		setUpViewController()
	}

	// MARK: - Private Methods
	private func setUpViewController() {
		widgetsJsManager.load()
		preloadWebviews()
		setUpTableView()
		activityIndicator.startAnimating()
		activityIndicator.isHidden = false
	}

	private func setUpTableView() {
		tableView.delegate = self
		tableView.dataSource = self
		tableView.allowsSelection = false
		tableView.estimatedRowHeight = viewModel.defaultCellHeightForTweet
		tableView.separatorStyle = .none
		let nibCell = UINib(nibName: TweetTableViewCell.className,
							bundle: .main)
		tableView.register(nibCell,
						   forCellReuseIdentifier: TweetTableViewCell.className)
		let refreshControl = UIRefreshControl(frame: tableView.bounds)
		refreshControl.addTarget(self,
								 action: #selector(refreshControlCalled(_:)),
								 for: .valueChanged)
		tableView.refreshControl = refreshControl
		tableView.reloadData()
	}

	private func preloadWebviews() {
		viewModel.list.enumerated().forEach { (index, item) in
			var item = item
			item.setWebView(createWebView(idx: index, item: item))
			viewModel.list[index] = item
		}
	}

	private func createWebView(idx: Int, item: TweetListModel) -> WKWebView {
		let configuration = WKWebViewConfiguration()
		let webView = WKWebView(frame: .zero, configuration: configuration)
		webView.navigationDelegate = self
		webView.uiDelegate = self
		webView.configuration.userContentController.add(self,
														name: viewModel.clickCallback)
		webView.configuration.userContentController.add(self,
														name: viewModel.heightCallback)
		webView.tag = idx
		if item.webview.first?.isTwitter == false {
			webView.frame = CGRect(x: 0,
								   y: 0,
								   width: view.bounds.width,
								   height: CGFloat(viewModel.defaultCellHeightForOthers))
		} else {
			webView.frame = CGRect(x: 0,
								   y: 0,
								   width: view.bounds.width,
								   height: CGFloat(viewModel.defaultCellHeightForTweet))
		}
		webView.scrollView.isScrollEnabled = false
		webView.loadHTMLString(viewModel.htmlTemplate, baseURL: nil)
		return webView
	}

	private func openInSafarViewController(_ url: URL) {
		let safariViewController = SFSafariViewController(url: url)
		showDetailViewController(safariViewController, sender: self)
	}

	@objc private func refreshControlCalled(_ control: UIRefreshControl) {
		viewModel.getTweetList()
		preloadWebviews()
		tableView.reloadData()
		activityIndicator.startAnimating()
		activityIndicator.isHidden = false
		control.endRefreshing()
	}
}

// MARK: - UITableViewDataSource Methods
extension ViewController: UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView,
				   numberOfRowsInSection section: Int) -> Int {
		return viewModel.list.count
	}

	func tableView(_ tableView: UITableView,
				   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: TweetTableViewCell.className,
												 for: indexPath) as! TweetTableViewCell
		guard let model = viewModel.getModelAt(indexPath.row) else {
			return cell
		}
		cell.configureCell(model, index: indexPath.row)
		return cell
	}
}

// MARK: - UITableViewDelegate Methods
extension ViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView,
				   willDisplay cell: UITableViewCell,
				   forRowAt indexPath: IndexPath) {
		guard let cell = cell as? TweetTableViewCell,
				let model = viewModel.getModelAt(indexPath.row) else {
			return
		}
		cell.configureCell(model, index: indexPath.row)
	}

	func tableView(_ tableView: UITableView,
				   didEndDisplaying cell: UITableViewCell,
				   forRowAt indexPath: IndexPath) {
		guard let cell = cell as? TweetTableViewCell else { return }
		cell.viewWebView.subviews.forEach({ view in
			if view is WKWebView {
				view.removeFromSuperview()
			}
		})
	}

	func tableView(_ tableView: UITableView,
				   heightForRowAt indexPath: IndexPath) -> CGFloat {
		guard let model = viewModel.getModelAt(indexPath.row) else {
			return viewModel.defaultCellHeightForTweet
		}
		return model.height
	}
}

// MARK: - WKNavigationDelegate Methods
extension ViewController: WKNavigationDelegate {
	func webView(_ webView: WKWebView,
				 decidePolicyFor navigationAction: WKNavigationAction,
				 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
		if let url = navigationAction.request.url,
		   navigationAction.navigationType == .linkActivated,
		   let twitterAppUrl = URL(string:"twitter://") {
			if UIApplication.shared.canOpenURL(twitterAppUrl) {
				UIApplication.shared.open(url)
			} else {
				openInSafarViewController(url)
			}
			decisionHandler(.cancel)
		} else {
			decisionHandler(.allow)
		}
	}

	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		if let model = viewModel.getModelAt(webView.tag) {
			if !model.isLoaded {
				loadTweetInWebView(webView)
			} else if model.webview.first?.isTwitter == false {
				webView.evaluateJavaScript("(function() {var i = 1, result = 0; while(true){result = document.body.children[document.body.children.length - i].offsetTop + document.body.children[document.body.children.length - i].offsetHeight; if (result > 0) return result; i++}})()", completionHandler: { [weak self] (height, error) in
					if let height = height as? CGFloat {
						self?.updateHeight(idx: webView.tag,
										   height: String(format: "%d", Int(height)))
					} else {
						webView.evaluateJavaScript("document.readyState", completionHandler: { [weak self] (complete, error) in
							if complete != nil {
								webView.evaluateJavaScript("document.getElementById('wrapper').scrollHeight", completionHandler: { [weak self] (height, error) in
									if let height = height as? CGFloat {
										self?.updateHeight(idx: webView.tag,
														   height: String(format: "%d", Int(height)))
									} else {
										self?.updateHeight(idx: webView.tag,
														   height: String(format: "%d", webView.scrollView.contentSize.height))
									}
								})
							}
						})
					}
				})
			}
		}
	}

	private func loadTweetInWebView(_ webView: WKWebView) {
		if let widgetsJsScript = widgetsJsManager.getScriptContent(),
		   let model = viewModel.getModelAt(webView.tag),
		   let webviewModel = model.webview.first {
			if webviewModel.isTwitter {
				webView.evaluateJavaScript(widgetsJsScript)
				webView.evaluateJavaScript("twttr.widgets.load();")
				webView.evaluateJavaScript("""
					twttr.widgets.createTweet(
						'\(model.webview.first?.twitterId ?? "")',
						document.getElementById('wrapper'),
						{ align: 'center' }
					).then(el => {
						window.webkit.messageHandlers.heightCallback.postMessage(el.offsetHeight.toString())
					});
				""")
			} else {
				let htmlString = viewModel.getUpdatedHtml(webviewModel.webview)
				webView.loadHTMLString(htmlString, baseURL: nil)
				webView.evaluateJavaScript("document.readyState") { [weak self] (complete, error) in
					if complete != nil {
						if var model = self?.viewModel.getModelAt(webView.tag) {
							model.isLoaded = true
							self?.viewModel.updateModelAt(model, index: webView.tag)
						}
					}
				}
			}
		}
	}
}

// MARK: - WKUIDelegate Methods
extension ViewController: WKUIDelegate {
	func webView(_ webView: WKWebView,
				 createWebViewWith configuration: WKWebViewConfiguration,
				 for navigationAction: WKNavigationAction,
				 windowFeatures: WKWindowFeatures) -> WKWebView? {
		if let url = navigationAction.request.url,
		   navigationAction.targetFrame == nil {
			openInSafarViewController(url)
		}
		return nil
	}
}

// MARK: - WKScriptMessageHandler Methods
extension ViewController: WKScriptMessageHandler {
	func userContentController(_ userContentController: WKUserContentController,
							   didReceive message: WKScriptMessage) {
		switch message.name {
		case viewModel.heightCallback:
			let index = message.webView!.tag
			if var model = viewModel.getModelAt(index) {
				model.isLoaded = true
				viewModel.updateModelAt(model,
										index: index)
			}
			updateHeight(idx: index,
						 height: message.body as! String)
		default:
			print("==== Unhandled callback")
		}
	}

	private func stringToCGFloat(_ s: String) -> CGFloat {
		if let intHeight = Int(s) {
			return CGFloat(integerLiteral: intHeight)
		}
		return viewModel.defaultCellHeightForTweet
	}

	private func updateHeight(idx: Int,
							  height: String) {
		if var model = viewModel.getModelAt(idx) {
			func updateHeight() {
				model.setHeight(stringToCGFloat(height) + viewModel.tweetPadding)
				viewModel.updateModelAt(model, index: idx)
				tableView.reloadRowWithoutAnimation(IndexPath(row: idx,
															  section: 0))
				if activityIndicator.isAnimating {
					activityIndicator.stopAnimating()
					activityIndicator.isHidden = true
				}
			}
			if model.webview.first?.isTwitter == true &&
				model.height == viewModel.defaultCellHeightForTweet {
				updateHeight()
			} else if model.height == viewModel.defaultCellHeightForOthers {
				updateHeight()
			}
		}
	}
}
