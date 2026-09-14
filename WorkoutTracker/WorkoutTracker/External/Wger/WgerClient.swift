//
//  WgerClient.swift
//  WorkoutTracker
//

import Foundation

/// Abstraction `ExerciseEditorModel` depends on, so tests can substitute a fake without a live network
/// call (see unit-testing-standards.md).
nonisolated protocol WgerExerciseSearching: Sendable {
    func searchExercises(matching query: String) async throws -> [WgerExerciseInfoDTO]
}

nonisolated struct WgerClient: WgerExerciseSearching {
    private let apiClient: APIClient

    init(apiClient: APIClient = APIClient()) {
        self.apiClient = apiClient
    }

    func searchExercises(matching query: String) async throws -> [WgerExerciseInfoDTO] {
        let response: WgerSearchResponseDTO = try await apiClient.send(WgerEndpoint.searchExercises(query: query))
        return response.results
    }
}
