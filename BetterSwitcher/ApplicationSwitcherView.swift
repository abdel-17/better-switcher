import SwiftUI

struct ApplicationSwitcherView: View {
	let applications: Applications
	weak let panel: NSPanel?

	@State var query = ""
	@FocusState var queryFocused

	var body: some View {
		let matchingApplications = searchApplications(applications.running, query)
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
					onQueryChange(matchingApplications: matchingApplications)
				}

			Divider()

			ScrollView {
				VStack(alignment: .leading) {
					ForEach(matchingApplications, id: \.bundleIdentifier) { application in
						let name = getApplicationName(application)
						let icon = getApplicationIcon(application)
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

	func onActivated() {
		query = ""
		panel?.close()
	}

	func onQueryChange(matchingApplications: [NSRunningApplication]) {
		if matchingApplications.count == 1 && matchingApplications[0].activate() {
			onActivated()
		}
	}
}
