//
//  Stargazer.swift
//  Model
//
//  Created by Matteo Matassoni on 14/04/2021.
//

import Foundation

extension Stargazer {
    public struct User {
        public let login: String
        public let id: Int
        public let nodeId: String
        public let avatarUrl: String
        public let gravatarId: String
        public let url: String
        public let htmlUrl: String
        public let followersUrl: String
        public let followingUrl: String
        public let gistsUrl: String
        public let starredUrl: String
        public let subscriptionsUrl: String
        public let organizationsUrl: String
        public let reposUrl: String
        public let eventsUrl: String
        public let receivedEventsUrl: String
        public let type: String
        public let siteAdmin: Bool
    }
}

// MARK: Equatable
extension Stargazer.User: Equatable {}

// MARK: Hashable
extension Stargazer.User: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: Decodable
extension Stargazer.User: Decodable {}
