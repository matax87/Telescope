//
//  Endpoint+Stargazer.swift
//  StargazerApiClient
//
//  Created by Matteo Matassoni on 14/04/2021.
//

import Foundation
import NetworkToolbox

extension Endpoint {
    static func listStargazers(
        ofRepositoryWithOwner owner: String,
        name: String,
        page pageOrNil: Int? = nil,
        pageSize pageSizeOrNil: Int? = nil
    ) -> Self {
        var queryItems: [URLQueryItem] = []
        if let page = pageOrNil {
            queryItems.append(URLQueryItem(
                name: GithubConstants.Param.page,
                value: String(page)
            ))
        }
        if let pageSize = pageSizeOrNil {
            queryItems.append(URLQueryItem(
                name: GithubConstants.Param.perPage,
                value: String(pageSize)
            ))
        }

        return Endpoint(
            path: "repos/\(owner)/\(name)/stargazers",
            queryItems: queryItems
        )
    }
}
