import AppKit
import Carbon
import SwiftUI

@main
struct BetterSwitcherApp: App {
	let panel = ApplicationSwitcherPanel(applications: Applications())

	init() {
		let target = GetApplicationEventTarget()
		var eventType = EventTypeSpec(
			eventClass: OSType(kEventClassKeyboard),
			eventKind: OSType(kEventHotKeyPressed),
		)
        var eventHandler: OpaquePointer?
        let installStatus = InstallEventHandler(
            target,
            { _, _, userData in
                let panel = Unmanaged<ApplicationSwitcherPanel>.fromOpaque(userData!).takeUnretainedValue()
                panel.center()
                panel.makeKeyAndOrderFront(nil)
                return noErr
            },
            1,
            &eventType,
            Unmanaged.passRetained(panel).toOpaque(),
            &eventHandler
        )
        guard installStatus == noErr else {
            print("failed to install keyboard event handler", installStatus)
            return
        }

        let hotKeyID = EventHotKeyID(signature: 0x42535453, id: 1)
        var hotKey: OpaquePointer?
        let registerStatus = RegisterEventHotKey(
            UInt32(kVK_Tab),
            UInt32(optionKey),
            hotKeyID,
            target,
            0,
            &hotKey
        )
        guard registerStatus == noErr else {
            print("failed to register hotkey", registerStatus)
            return
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
