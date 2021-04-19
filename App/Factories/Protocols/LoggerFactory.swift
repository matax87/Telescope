//
//  LoggerFactory.swift
//  Telescope
//
//  Created by Matteo Matassoni on 19/04/2021.
//

import Foundation
import OSLog

protocol LoggerFactoryFactory {
    func makeNetworkingLogger() -> Logger
}
