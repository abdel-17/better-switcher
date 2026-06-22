import AppKit
import SwiftUI

final class ApplicationSwitcherPanel: NSPanel {
	init(applications: Applications) {
		super.init(
			contentRect: NSRect(x: 0, y: 0, width: 500, height: 300),
			styleMask: [.nonactivatingPanel],
			backing: .buffered,
			defer: true,
		)
		self.isFloatingPanel = true
		self.level = .floating
		self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
		self.isMovableByWindowBackground = true
		self.backgroundColor = .clear
		self.hasShadow = false
		self.contentView = NSHostingView(
			rootView: ApplicationSwitcherView(
				applications: applications,
				onClose: { [weak self] in
					self?.close()
				},
			)
		)
	}

	override var canBecomeKey: Bool {
		return true
	}

	override func cancelOperation(_ sender: Any?) {
		close()
	}

	override func resignKey() {
		super.resignKey()
		close()
	}
}
