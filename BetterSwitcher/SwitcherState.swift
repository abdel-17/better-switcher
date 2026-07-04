import AppKit
import Observation

@Observable
final class SwitcherState {
	private(set) var items = getSwitcherItems(apps: getSwitcherApps())
	var query = ""
	@ObservationIgnored private var observation: NSKeyValueObservation?

	init() {
		self.observation = NSWorkspace.shared.observe(\.runningApplications) { [weak self] _, _ in
			self?.items = getSwitcherItems(apps: getSwitcherApps())
		}
	}

	deinit {
		observation?.invalidate()
	}
}

func getSwitcherApps() -> [NSRunningApplication] {
	return NSWorkspace.shared.runningApplications
		.filter { app in
			app.activationPolicy == .regular && app.bundleIdentifier != nil
		}
		.sorted { a, b in
			let x = a.localizedName ?? a.bundleIdentifier!
			let y = b.localizedName ?? b.bundleIdentifier!
			return x.localizedStandardCompare(y) == .orderedAscending
		}
}

protocol SwitcherApp {
	var bundleIdentifier: String? { get }
	var icon: NSImage? { get }
	var localizedName: String? { get }
}

extension NSRunningApplication: SwitcherApp {}

struct SwitcherItem<App: SwitcherApp> {
	let app: App
	let searchHint: Substring
}

func getSwitcherItems<App: SwitcherApp>(apps: [App]) -> [SwitcherItem<App>] {
	var items: [SwitcherItem<App>] = []
	let names = apps.map { app in
		let name = app.localizedName ?? app.bundleIdentifier!
		return name.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil)
	}
	for (i, ni) in names.enumerated() {
		var hint = ni[...]
		outer: for k in ni.indices {
			let potentialHint = ni[...k]
			for (j, nj) in names.enumerated() where i != j {
				if nj.hasPrefix(potentialHint) {
					continue outer
				}
			}
			hint = potentialHint
			break
		}
		hint.replace(" ", with: "⎵")
		items.append(SwitcherItem(app: apps[i], searchHint: hint))
	}
	return items
}
