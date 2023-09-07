import ComposableArchitecture
import XCTest
@testable import ProjectsFeature

@MainActor
final class ProjectsReducerTests: XCTestCase {
  func testFetchProjects() async {
    let store = TestStore(initialState: ProjectsReducer.State()) {
      ProjectsReducer()
    } withDependencies: {
      $0.projectsProvider.fetch = { .preview }
    }

    await store.send(.fetchProjects) {
      $0.isLoading = true
    }
    await store.receive(.fetchProjectsResult(.success(.preview))) {
      $0.isLoading = false
      $0.groups = .init(groupingByYear: .init(uniqueElements: [Project].preview))
    }
  }

  func testFetchProjectsFailure() async {
    let error = NSError(domain: "test", code: 1234)
    let store = TestStore(initialState: ProjectsReducer.State()) {
      ProjectsReducer()
    } withDependencies: {
      $0.projectsProvider.fetch = { throw error }
    }

    await store.send(.fetchProjects) {
      $0.isLoading = true
    }
    await store.receive(.fetchProjectsResult(.failure(error))) {
      $0.isLoading = false
    }
  }

  func testViewRefreshButtonTapped() async {
    let store = TestStore(initialState: ProjectsReducer.State()) {
      ProjectsReducer()
    } withDependencies: {
      $0.projectsProvider.fetch = { .preview }
    }
    store.exhaustivity = .off

    await store.send(.view(.refreshButtonTapped))
    await store.receive(.fetchProjects)
  }

  func testViewRefreshTask() async {
    let store = TestStore(initialState: ProjectsReducer.State()) {
      ProjectsReducer()
    } withDependencies: {
      $0.projectsProvider.fetch = { .preview }
    }
    store.exhaustivity = .off

    await store.send(.view(.refreshTask))
    await store.receive(.fetchProjects)
  }

  func testViewTask() async {
    let store = TestStore(initialState: ProjectsReducer.State()) {
      ProjectsReducer()
    } withDependencies: {
      $0.projectsProvider.fetch = { .preview }
    }
    store.exhaustivity = .off

    await store.send(.view(.task))
    await store.receive(.fetchProjects)
  }

  func testViewProjectCardTapped() async {
    let didOpenURL = ActorIsolated<[URL]>([])
    let projects = IdentifiedArray(uniqueElements: [Project].preview)
    let project = projects.first { $0.url != nil }!
    let store = TestStore(initialState: ProjectsReducer.State(
      groups: .init(groupingByYear: projects)
    )) {
      ProjectsReducer()
    } withDependencies: {
      $0.openURL = .init { url in
        await didOpenURL.withValue { $0.append(url) }
        return true
      }
    }

    await store.send(.view(.projectCardTapped(project.id)))
    await didOpenURL.withValue {
      XCTAssertNoDifference($0, [project.url!])
    }
  }
}
