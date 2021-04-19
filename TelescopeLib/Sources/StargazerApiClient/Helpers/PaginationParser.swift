//
//  PageLinksParser.swift
//  NetworkToolbox
//
//  Created by Matteo Matassoni on 17/04/2021.
//

import Foundation

final class PaginationParser {
    static func parse(httpHeaders: [AnyHashable: Any]) -> Pagination {
        let pageLinks = PageLinksParser.parse(httpHeaders: httpHeaders)
        return Pagination(
            first: page(from: pageLinks.first),
            last: page(from: pageLinks.last),
            next: page(from: pageLinks.next),
            prev: page(from: pageLinks.prev)
        )
    }
}

// MARK: Private APIs

private extension PaginationParser {
    static func page(from link: String?) -> Int? {
        guard
            let link = link,
            let url = URL(string: link)
        else { return nil }

        guard let urlComponents = URLComponents(
            url: url,
            resolvingAgainstBaseURL: true
        )
        else { return nil }

        guard let queryItems = urlComponents.queryItems
        else { return nil }

        return queryItems
            .first { $0.name == GithubConstants.Param.page }?.value
            .flatMap { Int($0) }
    }
}
