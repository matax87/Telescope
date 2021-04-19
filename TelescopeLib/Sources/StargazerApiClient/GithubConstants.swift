//
//  GithubConstants.swift
//  GithubConstants
//
//  Created by Matteo Matassoni on 15/04/2021.
//

import Foundation

enum GithubConstants {
    enum Host {
        static let api = "api.github.com"
    }

    enum Header {
        static let link = "Link"
        static let next = "X-Next"
        static let last = "X-Last"
    }

    enum Meta {
        static let rel = "rel"
        static let last = "last"
        static let next = "next"
        static let first = "first"
        static let prev = "prev"
    }

    enum Param {
        static let page = "page"
        static let perPage = "per_page"
    }
}
