import AppKit
import SwiftUI

@main
struct BetterSwitcherApp: App {
	let panel = ApplicationSwitcherPanel(applications: Applications())

	var body: some Scene {
		MenuBarExtra("BetterSwitcher", systemImage: "arrow.right.arrow.left") {
			Button("Open Switcher", action: openSwitcher)
			Button("Quit", action: quit)
		}
	}

	func openSwitcher() {
		panel.center()
		panel.makeKeyAndOrderFront(nil)
	}

	func quit() {
		NSApplication.shared.terminate(nil)
	}
}
