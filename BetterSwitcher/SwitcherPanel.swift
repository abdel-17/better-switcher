import AppKit
import SwiftUI

final class SwitcherPanel: NSPanel {
	init() {
		super.init(
			contentRect: NSRect(x: 0, y: 0, width: 500, height: 400),
			styleMask: [.nonactivatingPanel],
			backing: .buffered,
			defer: true,
		)
		self.isFloatingPanel = true
		self.level = .floating
		self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
		self.isMovableByWindowBackground = true
		self.backgroundColor = .clear
		self.contentView = NSHostingView(rootView: SwitcherPanelRootView(panel: self))
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

struct SwitcherPanelRootView: View {
	weak let panel: SwitcherPanel?

	private let state = SwitcherState()
	@State private var query = ""

	var body: some View {
		SwitcherView(items: state.items, query: $query) { app in
			if app.activate() {
				query = ""
				panel?.close()
			}
		}
	}
}
