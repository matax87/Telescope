//
//  NTBAnyCancellable.swift
//  NetworkToolbox
//
//  Created by Matteo Matassoni on 17/04/2021.
//

import Foundation

public final class NTBAnyCancellable: NTBCancellable {
    private let cancelHandler: (() -> Void)?

    public init(_ cancel: @escaping () -> Void) {
        cancelHandler = cancel
    }

    public init<C: NTBCancellable>(_ cancellable: C) {
        cancelHandler = cancellable.cancel
    }

    public func cancel() {
        cancelHandler?()
    }
}
