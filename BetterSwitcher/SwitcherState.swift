import AppKit
import Observation

@Observable
final class SwitcherState {
	private(set) var apps: [NSRunningApplication]
	@ObservationIgnored private var observation: NSKeyValueObservation?

	init() {
		self.apps = NSWorkspace.shared.runningApplications.filter(appPredicate).sorted(by: appComparator)
		self.observation = NSWorkspace.shared.observe(\.runningApplications) { [weak self] _, _ in
			self?.apps = NSWorkspace.shared.runningApplications.filter(appPredicate).sorted(by: appComparator)
		}
	}

	deinit {
		observation?.invalidate()
	}
}

private func appPredicate(_ app: NSRunningApplication) -> Bool {
	return app.activationPolicy == .regular && app.bundleIdentifier != nil
}

private func appComparator(_ a: NSRunningApplication, _ b: NSRunningApplication) -> Bool {
	let x = a.localizedName ?? a.bundleIdentifier!
	let y = b.localizedName ?? b.bundleIdentifier!
	return x.localizedStandardCompare(y) == .orderedAscending
}
