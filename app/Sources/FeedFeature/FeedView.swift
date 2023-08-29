import ComposableArchitecture
import SwiftUI

public struct FeedView: View {
  public init(store: StoreOf<FeedReducer>) {
    self.store = store
  }

  let store: StoreOf<FeedReducer>

  public var body: some View {
    Text("FeedView")
  }
}

#Preview {
  FeedView(store: Store(initialState: FeedReducer.State()) {
    FeedReducer()
  })
}
