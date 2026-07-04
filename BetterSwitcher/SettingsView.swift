import AppKit
import Carbon
import SwiftUI

struct SettingsView: View {
	let shortcutCode: Int
	let shortcutModifiers: Int
	let onShortcutChange: (Int, Int) -> Void
	@Binding var isLoginItem: Bool

	@Environment(\.appearsActive) var appearsActive
	@State private var monitor: Any?

	var body: some View {
		Form {
			Toggle("Launch at login", isOn: $isLoginItem)

			LabeledContent("Shortcut") {
				Button {
					if monitor == nil {
						startRecording()
					} else {
						stopRecording()
					}
				} label: {
					let label =
						if monitor == nil {
							formatShortcut(code: shortcutCode, modifiers: shortcutModifiers)
						} else {
							"Recording..."
						}
					Text(label)
						.frame(maxWidth: .infinity)
				}
			}
		}
		.formStyle(.grouped)
		.frame(width: 350)
		.fixedSize()
		.onChange(of: appearsActive) {
			if appearsActive {
				NSApp.arrangeInFront(nil)
			} else {
				stopRecording()
			}
		}
		.onDisappear {
			stopRecording()
		}
	}

	private func startRecording() {
		monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
			let code = Int(event.keyCode)
			if code != kVK_Escape {
				var modifiers = 0
				let flags = event.modifierFlags
				if flags.contains(.shift) { modifiers |= shiftKey }
				if flags.contains(.control) { modifiers |= controlKey }
				if flags.contains(.option) { modifiers |= optionKey }
				if flags.contains(.command) { modifiers |= cmdKey }
				onShortcutChange(code, modifiers)
			}
			stopRecording()
			return nil
		}
	}

	private func stopRecording() {
		if let monitor {
			NSEvent.removeMonitor(monitor)
			self.monitor = nil
		}
	}
}

func formatShortcut(code: Int, modifiers: Int) -> String {
	var keys = ""

	if modifiers & shiftKey != 0 { keys.append("⇧") }
	if modifiers & controlKey != 0 { keys.append("⌃") }
	if modifiers & optionKey != 0 { keys.append("⌥") }
	if modifiers & cmdKey != 0 { keys.append("⌘") }

	var key: String
	switch code {
	case kVK_Tab: key = "⇥"
	case kVK_Return: key = "↩"
	case kVK_Space: key = "⎵"
	case kVK_Delete: key = "⌫"
	case kVK_ForwardDelete: key = "⌦"
	case kVK_Escape: key = "⎋"
	case kVK_LeftArrow: key = "←"
	case kVK_RightArrow: key = "→"
	case kVK_UpArrow: key = "↑"
	case kVK_DownArrow: key = "↓"
	case kVK_PageUp: key = "⇞"
	case kVK_PageDown: key = "⇟"
	case kVK_Home: key = "↖"
	case kVK_End: key = "↘"
	default:
		// https://stackoverflow.com/questions/1918841/how-can-i-convert-an-ascii-character-to-cgkeycode/1971027#1971027
		let inputSource = TISCopyCurrentKeyboardInputSource().takeRetainedValue()
		let layoutData = unsafeBitCast(
			TISGetInputSourceProperty(inputSource, kTISPropertyUnicodeKeyLayoutData),
			to: CFData.self,
		)
		let keyboardLayout = unsafeBitCast(
			CFDataGetBytePtr(layoutData),
			to: UnsafePointer<UCKeyboardLayout>.self,
		)
		var deadKeyState: UInt32 = 0
		var characters = [UniChar](repeating: 0, count: 4)
		var count = 0
		UCKeyTranslate(
			keyboardLayout,
			UInt16(code),
			UInt16(kUCKeyActionDisplay),
			0,
			UInt32(LMGetKbdType()),
			UInt32(kUCKeyTranslateNoDeadKeysBit),
			&deadKeyState,
			characters.count,
			&count,
			&characters,
		)
		key = String(utf16CodeUnits: characters, count: count)
	}
	keys.append(key)

	return keys
}
