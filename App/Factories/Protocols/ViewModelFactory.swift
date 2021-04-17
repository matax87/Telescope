//
//  ViewModelFactory.swift
//  Federcoop Merchant
//
//  Created by Matteo Matassoni on 16/04/2021.
//

import Foundation
import ViewModels

protocol ViewModelFactory {
    func makeMainViewModel() -> MainViewModel
}
