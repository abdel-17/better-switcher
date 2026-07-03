import AppKit
import SwiftUI

final class SwitcherPanel: NSPanel {
	init() {
		super.init(
			contentRect: NSRect(x: 0, y: 0, width: 400, height: 0),
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

	@Bindable private var state = SwitcherState()

	var body: some View {
		SwitcherView(items: state.items, query: $state.query) { app in
			if app.activate() {
				state.query = ""
				panel?.close()
			}
		}
	}
}
