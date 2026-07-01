import Carbon

final class HotKey {
	private var handlerRef: EventHandlerRef?
	private var hotKeyRef: EventHotKeyRef?

	func setHandler(userData: UnsafeMutableRawPointer?, handler: EventHandlerUPP) -> OSStatus {
		RemoveEventHandler(handlerRef)
		let target = GetApplicationEventTarget()
		var eventType = EventTypeSpec(
			eventClass: OSType(kEventClassKeyboard),
			eventKind: OSType(kEventHotKeyPressed),
		)
		return InstallEventHandler(target, handler, 1, &eventType, userData, &handlerRef)
	}

	func setKey(code: Int, modifiers: Int) -> OSStatus {
		UnregisterEventHotKey(hotKeyRef)
		let target = GetApplicationEventTarget()
		let hotKeyID = EventHotKeyID(signature: 0x4253_5453, id: 1)
		return RegisterEventHotKey(UInt32(code), UInt32(modifiers), hotKeyID, target, 0, &hotKeyRef)
	}

	deinit {
		UnregisterEventHotKey(hotKeyRef)
		RemoveEventHandler(handlerRef)
	}
}
