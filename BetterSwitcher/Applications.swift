import Cocoa
import Observation
import UniformTypeIdentifiers

@Observable
final class Applications {
	var running = NSWorkspace.shared.runningApplications.filter(shouldIncludeApplication).sorted(by: applicationComparator)

	init() {
		let nc = NSWorkspace.shared.notificationCenter
		nc.addObserver(
			forName: NSWorkspace.didLaunchApplicationNotification,
			object: nil,
			queue: nil,
			using: self.didLaunchApplication,
		)
		nc.addObserver(
			forName: NSWorkspace.didTerminateApplicationNotification,
			object: nil,
			queue: nil,
			using: self.didTerminateApplication,
		)
	}

	func didLaunchApplication(notification: Notification) {
		guard let application = getApplication(from: notification) else { return }
		guard shouldIncludeApplication(application) else { return }
		let exists = running.contains { $0.bundleIdentifier == application.bundleIdentifier }
		if !exists {
			running.append(application)
			running.sort(by: applicationComparator)
		}
	}

	func didTerminateApplication(notification: Notification) {
		guard let application = getApplication(from: notification) else { return }
		let index = running.firstIndex { $0.bundleIdentifier == application.bundleIdentifier }
		if let index {
			running.remove(at: index)
		}
	}
}

func shouldIncludeApplication(_ application: NSRunningApplication) -> Bool {
	return application.activationPolicy == .regular && application.bundleIdentifier != nil
}

func getApplication(from notification: Notification) -> NSRunningApplication? {
	return notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
}

func getApplicationIcon(_ application: NSRunningApplication) -> NSImage {
	return application.icon ?? NSWorkspace.shared.icon(for: .applicationBundle)
}

func getApplicationName(_ application: NSRunningApplication) -> String {
	return application.localizedName ?? application.bundleIdentifier!
}

func applicationComparator(_ a: NSRunningApplication, _ b: NSRunningApplication) -> Bool {
	let x = getApplicationName(a)
	let y = getApplicationName(b)
	return x.localizedStandardCompare(y) == .orderedAscending
}

func searchApplications(_ applications: [NSRunningApplication], _ query: String) -> [NSRunningApplication] {
	if query.isEmpty {
		return applications
	}
	return applications.filter {
		let name = getApplicationName($0)
		guard let range = name.localizedStandardRange(of: query) else {
			return false
		}
		return range.lowerBound == name.startIndex
	}
}
