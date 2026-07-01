import Carbon
import SwiftUI

@main
struct BetterSwitcherApp: App {
	private let panel = SwitcherPanel()
	private let hotKey = HotKey()

	init() {
		let userData = Unmanaged.passUnretained(panel).toOpaque()
		let handlerStatus = hotKey.setHandler(userData: userData) { _, _, userData in
			let panel = Unmanaged<SwitcherPanel>.fromOpaque(userData!).takeUnretainedValue()
			panel.center()
			panel.makeKeyAndOrderFront(nil)
			return noErr
		}
		if handlerStatus == noErr {
			let keyStatus = hotKey.setKey(code: kVK_Tab, modifiers: optionKey)
			if keyStatus != noErr {
				print("failed to set key", keyStatus)
			}
		} else {
			print("failed to set handler", handlerStatus)
		}
	}

	var body: some Scene {
		MenuBarExtra("BetterSwitcher", systemImage: "arrow.right.arrow.left") {
			Button("Open Switcher") {
				panel.center()
				panel.makeKeyAndOrderFront(nil)
			}

			Button("Quit") {
				NSApplication.shared.terminate(nil)
			}
		}
	}
}
