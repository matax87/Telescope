//
//  SelectRepositoryViewModel.swift
//  ViewModels
//
//  Created by Matteo Matassoni on 17/04/2021.
//

import Foundation
import Combine

public final class SelectRepositoryViewModel {
    @Published public var searchedText: String?

    @Published public private(set) var error: Error?

    @Published public var selectedRepository: Repository?

    private var subscriptions: Set<AnyCancellable> = []

    public init() {
        setupBindings()
    }
}

// MARK: Private APIs
private extension SelectRepositoryViewModel {
    func setupBindings() {
        $searchedText
            .sink { [weak self] in
                self?.handle(searchedText: $0)
            }
            .store(in: &subscriptions)
    }

    func handle(searchedText: String?) {
        guard searchedText != nil,
              !searchedText!.isEmpty
        else { return }

        do {
            selectedRepository = try Repository(value: searchedText!)
        } catch {
            self.error = error
        }
    }
}
