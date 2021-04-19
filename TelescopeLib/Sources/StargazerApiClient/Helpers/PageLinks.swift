//
//  PageLinks.swift
//  Model
//
//  Created by Matteo Matassoni on 15/04/2021.
//

import Foundation

// https://docs.github.com/en/rest/overview/resources-in-the-rest-api#pagination
// https://docs.github.com/en/rest/guides/traversing-with-pagination
struct PageLinks {
    var first: String?
    var last: String?
    var next: String?
    var prev: String?
}
