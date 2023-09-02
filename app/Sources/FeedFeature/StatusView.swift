import AppShared
import ComposableArchitecture
import Mastodon
import SwiftUI

public struct StatusView: View {
  public init(store: StoreOf<StatusReducer>) {
    self.store = store
  }

  let store: StoreOf<StatusReducer>

  public var body: some View {
    VStack {
      WithViewStore(store) {
        StatusHeaderView.State($0.displayStatus)
      } content: { viewStore in
        StatusHeaderView(state: viewStore.state)
      }

      WithViewStore(store, observe: \.displayStatus.content) { viewStore in
        HTMLTextView(html: viewStore.state)
      }
      .foregroundStyle(.primary)
      .font(.body)
      .multilineTextAlignment(.leading)
      .frame(maxWidth: .infinity, alignment: .leading)

      IfLetStore(store.scope(
        state: \.displayStatus.card,
        action: { $0 }
      )) { store in
        WithViewStore(store, observe: PreviewCardView.State.init) { viewStore in
          Button {
            store.withState { card in
              _ = store.send(.view(.cardTapped(card)))
            }
          } label: {
            PreviewCardView(state: viewStore.state)
          }
          .buttonStyle(.plain)
        }
      }
    }
    .padding(.bottom)
  }
}

#Preview {
  ScrollView {
    StatusView(store: Store(initialState: StatusReducer.State(
      status: [Status].preview[0]
    )) {
      StatusReducer()
    })
    .padding()
  }
}
