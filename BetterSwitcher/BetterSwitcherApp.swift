import Carbon
import ServiceManagement
import SwiftUI

@main
struct BetterSwitcherApp: App {
	private let panel = SwitcherPanel()
	private let hotKey = HotKey()
	@AppStorage("shortcutCode") private var shortcutCode = kVK_Tab
	@AppStorage("shortcutModifiers") private var shortcutModifiers = optionKey
	@State private var isLoginItem = SMAppService.mainApp.status == .enabled

	init() {
		let userData = Unmanaged.passUnretained(panel).toOpaque()
		let handlerStatus = hotKey.setHandler(userData: userData) { _, _, userData in
			let panel = Unmanaged<SwitcherPanel>.fromOpaque(userData!).takeUnretainedValue()
			panel.center()
			panel.makeKeyAndOrderFront(nil)
			return noErr
		}
		if handlerStatus == noErr {
			let keyStatus = hotKey.setKey(code: shortcutCode, modifiers: shortcutModifiers)
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

			SettingsLink()
				.keyboardShortcut(",", modifiers: .command)

			Button("Quit") {
				NSApp.terminate(nil)
			}
			.keyboardShortcut("Q", modifiers: .command)
		}

		Settings {
			SettingsView(
				shortcutCode: shortcutCode,
				shortcutModifiers: shortcutModifiers,
				onShortcutChange: onShortcutChange,
				isLoginItem: $isLoginItem,
			)
			.onChange(of: isLoginItem, onIsLoginItemChange)
		}
	}

	private func onShortcutChange(code: Int, modifiers: Int) {
		let keyStatus = hotKey.setKey(code: code, modifiers: modifiers)
		if keyStatus == noErr {
			shortcutCode = code
			shortcutModifiers = modifiers
		} else {
			print("failed to set key", keyStatus)
		}
	}

	private func onIsLoginItemChange() {
		if isLoginItem {
			do {
				try SMAppService.mainApp.register()
			} catch {
				print("failed to register app as a login item", error)
			}
		} else {
			do {
				try SMAppService.mainApp.unregister()
			} catch {
				print("failed to unregister app as a login item", error)
			}
		}
	}
}
