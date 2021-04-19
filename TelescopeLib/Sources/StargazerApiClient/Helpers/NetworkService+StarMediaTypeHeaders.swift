//
//  NetworkService+StarMediaTypeHeaders.swift
//  StargazerApiClient
//
//  Created by Matteo Matassoni on 16/04/2021.
//

import NetworkToolbox

extension NetworkService {
    func addingStarMediaTypeHeaders() -> NetworkService {
        HeadersAddingNetworkService(
            wrapped: self,
            headers: [
                "Accept": "application/vnd.github.v3.star+json"
            ]
        )
    }
}
