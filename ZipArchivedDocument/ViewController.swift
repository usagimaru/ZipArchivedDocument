//
//  ViewController.swift
//  ZipArchivedDocument
//
//  Created by usagimaru on 2022/03/29.
//

import Cocoa

class ViewController: NSViewController {

	private lazy var markChangeButton: NSButton = {
		let button = NSButton(
			title: String(localized: "Mark as Changed"),
			target: self,
			action: #selector(markDocumentChanged(_:))
		)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()

	override func viewDidLoad() {
		super.viewDidLoad()

		view.addSubview(markChangeButton)
		NSLayoutConstraint.activate([
			markChangeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			markChangeButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
		])
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}

	// MARK: - Actions

	// 明示的なオートセーブを実行
	// オートセーブ先は document.autosavedContentsFileURL で取得可能
	@objc private func markDocumentChanged(_ sender: Any?) {
		guard let document = view.window?.windowController?.document as? Document else {
			return
		}
		document.updateChangeCount(.changeDone)
		print("updateChangeCount(.changeDone)")
		document.autosave(withImplicitCancellability: false) { error in
			if let error {
				print("Autosave failed: \(error)")
				return
			}
			print("Autosave succeeded")
			if let url = document.autosavedContentsFileURL {
				print("  \(String(describing: url.absoluteString))")
			}
		}
	}

}

