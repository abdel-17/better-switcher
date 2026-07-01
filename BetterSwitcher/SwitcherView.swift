import SwiftUI
import UniformTypeIdentifiers

protocol SwitcherApp {
	var bundleIdentifier: String? { get }
	var icon: NSImage? { get }
	var localizedName: String? { get }
}

extension NSRunningApplication: SwitcherApp {}

struct SwitcherView<App: SwitcherApp>: View {
	let apps: [App]
	@Binding var query: String
	let onActivate: (App) -> Void

	@FocusState private var queryFocused

	var body: some View {
		let results = search(apps: apps, query: query)
		VStack(alignment: .leading, spacing: 0) {
			TextField("Application name", text: $query, prompt: Text(""))
				.textFieldStyle(.plain)
				.font(.system(size: 14))
				.padding(.horizontal, 16)
				.padding(.vertical, 10)
				.focused($queryFocused)
				.onAppear {
					queryFocused = true
				}
				.onChange(of: query) {
					if results.count == 1 {
						onActivate(results[0].app)
					}
				}

			Divider()

			ScrollView {
				VStack(alignment: .leading) {
					ForEach(results) { result in
						let name = result.app.localizedName ?? result.app.bundleIdentifier!
						let icon = result.app.icon ?? NSWorkspace.shared.icon(for: .applicationBundle)
						HStack {
							Image(nsImage: icon)
								.resizable()
								.aspectRatio(contentMode: .fit)
								.frame(width: 40, height: 40)

							Text(name)
								.font(.system(size: 16, weight: .medium))
						}
					}
				}
				.frame(maxWidth: .infinity, alignment: .leading)
				.padding(.horizontal, 12)
				.padding(.vertical, 6)
			}
		}
		.glassEffect(.regular, in: .rect)
	}
}

struct SearchResult<App: SwitcherApp>: Identifiable {
	let app: App
	let range: Range<String.Index>?

	var id: String {
		app.bundleIdentifier!
	}
}

func search<App: SwitcherApp>(apps: [App], query: String) -> [SearchResult<App>] {
	var results: [SearchResult<App>] = []
	for app in apps {
		let name = app.localizedName ?? app.bundleIdentifier!
		if query.isEmpty {
			let result = SearchResult(app: app, range: nil)
			results.append(result)
		} else if let range = name.localizedStandardRange(of: query), range.lowerBound == name.startIndex {
			let result = SearchResult(app: app, range: range)
			results.append(result)
		}
	}
	return results
}
