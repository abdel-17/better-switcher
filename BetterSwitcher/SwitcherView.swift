import SwiftUI
import UniformTypeIdentifiers

struct SwitcherView<App: SwitcherApp>: View {
	let items: [SwitcherItem<App>]
	@Binding var query: String
	let onActivate: (App) -> Void

	@FocusState private var queryFocused

	var body: some View {
		let results = search(items: items, query: query)
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
						HStack {
							Image(nsImage: result.app.icon ?? NSWorkspace.shared.icon(for: .applicationBundle))
								.resizable()
								.aspectRatio(contentMode: .fit)
								.frame(width: 40, height: 40)

							Text(result.name)
								.font(.system(size: 16, weight: .medium))

							Spacer()

							Text(result.searchHint)
								.font(.system(size: 12).monospaced())
								.padding(.horizontal, 6)
								.padding(.vertical, 3)
								.background(.secondary)
								.clipShape(RoundedRectangle(cornerRadius: 4))
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
	let searchHint: Substring
	let name: AttributedString

	var id: String {
		app.bundleIdentifier!
	}
}

func search<App: SwitcherApp>(items: [SwitcherItem<App>], query: String) -> [SearchResult<App>] {
	var results: [SearchResult<App>] = []
	for item in items {
        var name = AttributedString(item.app.localizedName ?? item.app.bundleIdentifier!)
		if !query.isEmpty {
			let options: String.CompareOptions = [.anchored, .caseInsensitive, .diacriticInsensitive]
			guard let range = name.range(of: query, options: options) else {
				continue
			}
			name[range].foregroundColor = .red
		}
        results.append(SearchResult(app: item.app, searchHint: item.searchHint, name: name))
	}
	return results
}
