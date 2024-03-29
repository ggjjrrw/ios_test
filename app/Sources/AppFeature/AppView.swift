import AppShared
import ComposableArchitecture
import ContactFeature
import FeedFeature
import ProjectsFeature
import SwiftUI

@ViewAction(for: AppReducer.self)
public struct AppView: View {
  public init(store: StoreOf<AppReducer>) {
    self.store = store
  }

  public let store: StoreOf<AppReducer>
  @Environment(\.horizontalSizeClass) var horizontalSizeClass
  @State var columnVisibility: NavigationSplitViewVisibility = .all

  public var body: some View {
    Group {
#if os(macOS)
      splitView
        .frame(minHeight: 640)
#elseif os(iOS)
      if horizontalSizeClass == .compact {
        tabsView
      } else {
        splitView
      }
#endif
    }
    .tint(.appTint)
  }

  @MainActor
  var splitView: some View {
    NavigationSplitView(columnVisibility: $columnVisibility) {
      List(selection: Binding(
        get: { store.selectedSection },
        set: { send(.sectionSelected($0), transaction: $1) }
      )) {
        Section {
          ForEach(AppReducer.State.Section.allCases, id: \.hashValue) { section in
            NavigationLink(value: section) {
              sectionLabel(section)
            }
          }
        }
      }
      .listStyle(.sidebar)
      .navigationSplitViewColumnWidth(220)
#if os(iOS)
      .navigationBarTitleDisplayMode(.inline)
#endif
    } detail: {
      sectionView(store.selectedSection)
#if os(macOS)
        .frame(minWidth: 640)
#endif
    }
    .navigationSplitViewStyle(.balanced)
  }

  @MainActor
  var tabsView: some View {
    TabView(selection: Binding(
      get: { store.selectedSection },
      set: { send(.sectionSelected($0), transaction: $1) }
    )) {
      ForEach(AppReducer.State.Section.allCases, id: \.hashValue) { section in
        NavigationStack {
          sectionView(section)
        }
        .tabItem {
          sectionLabel(section)
        }
        .tag(section)
      }
    }
  }

  @ViewBuilder
  func sectionView(_ section: AppReducer.State.Section?) -> some View {
    switch section {
    case .none:
      EmptyView()

    case .feed:
      FeedView(store: store.scope(
        state: \.feed,
        action: \.feed
      ))

    case .projects:
      ProjectsView(store: store.scope(
        state: \.projects,
        action: \.projects
      ))

    case .contact:
      ContactView(store: store.scope(
        state: \.contact,
        action: \.contact
      ))
    }
  }

  @ViewBuilder
  func sectionLabel(_ section: AppReducer.State.Section) -> some View {
    switch section {
    case .feed:
      Label {
        Text("Feed")
      } icon: {
        Image(systemName: "newspaper.fill")
      }

    case .projects:
      Label {
        Text("Projects")
      } icon: {
        Image(systemName: "tray.full.fill")
      }

    case .contact:
      Label {
        Text("Contact")
      } icon: {
        Image(systemName: "person.crop.circle.fill")
      }
    }
  }
}

#Preview {
  AppView(store: Store(initialState: AppReducer.State()) {
    AppReducer()
  })
}
