//
//  PageLinksParser.swift
//  NetworkToolbox
//
//  Created by Matteo Matassoni on 17/04/2021.
//

import Foundation

// Inspired by https://github.com/eclipse/egit-github/blob/master/org.eclipse.egit.github.core/src/org/eclipse/egit/github/core/client/PageLinks.java
final class PageLinksParser {
    static func parse(httpHeaders: [AnyHashable: Any]) -> PageLinks {
        if let linkHeader = httpHeaders[GithubConstants.Header.link] as? String {
            let links = linkHeader.split(separator: Self.linksSeparator)
            return parse(from: links)
        } else {
            let next = httpHeaders[GithubConstants.Header.next] as? String
            let last = httpHeaders[GithubConstants.Header.last] as? String
            return PageLinks(
                first: nil,
                last: last,
                next: next,
                prev: nil
            )
        }
    }
}

// MARK: Private APIs

private extension PageLinksParser {
    static let linksSeparator: Character = ","
    static let linkParamSeparator: Character = ";"

    static func parse<S: Sequence>(
        from links: S
    ) -> PageLinks where S.Element: StringProtocol {
        var first: String?
        var last: String?
        var next: String?
        var prev: String?

        for link in links {
            let segments = link.split(separator: Self.linkParamSeparator)
            if segments.count < 2 {
                continue
            }
            var linkPart = segments[0]
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if !linkPart.hasPrefix("<") || !linkPart.hasSuffix(">") {
                continue
            }
            linkPart = String(linkPart.dropFirst().dropLast())
            for i in 1 ..< segments.count {
                let rel = segments[i]
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .split(separator: "=")
                if rel.count < 2 || rel[0] != GithubConstants.Meta.rel {
                    continue
                }

                var relValue = String(rel[1])
                if relValue.hasPrefix("\""), relValue.hasSuffix("\"") {
                    relValue = String(relValue.dropFirst().dropLast())
                }

                switch relValue {
                case GithubConstants.Meta.first:
                    first = linkPart
                case GithubConstants.Meta.last:
                    last = linkPart
                case GithubConstants.Meta.next:
                    next = linkPart
                case GithubConstants.Meta.prev:
                    prev = linkPart
                default:
                    break
                }
            }
        }

        return PageLinks(
            first: first,
            last: last,
            next: next,
            prev: prev
        )
    }
}
