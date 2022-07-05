// 
//  FESegmentControl.swift
//  breadwallet
//
//  Created by Rok on 05/07/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

struct SegmentControlConfiguration: Configurable {
    var font: UIFont = Fonts.button
    var normal: BackgroundConfiguration = .init(backgroundColor: LightColors.tertiary, tintColor: LightColors.Text.one)
    var selected: BackgroundConfiguration = .init(backgroundColor: LightColors.primary, tintColor: LightColors.Contrast.two)
}

struct SegmentControlViewModel: ViewModel {
    /// Passing 'nil' leaves the control deselected
    var selectedIndex: Int?
}

class FESegmentControl: UISegmentedControl, ViewProtocol {
    
    var config: SegmentControlConfiguration?
    var viewModel: SegmentControlViewModel?
    
    convenience init() {
        let items = [
            // TODO: localize
            "Min",
            "Max"
        ]
        self.init(items: items)
    }
    
    func configure(with config: SegmentControlConfiguration?) {
        guard let config = config else { return }

        backgroundColor = config.normal.backgroundColor
        selectedSegmentTintColor = config.selected.backgroundColor
        
        setTitleTextAttributes([
            .font: config.font,
            .foregroundColor: config.normal.tintColor
        ], for: .normal)
        
        setTitleTextAttributes([
            .font: config.font,
            .foregroundColor: config.selected.tintColor
        ], for: .selected)
    }
    
    func setup(with viewModel: SegmentControlViewModel?) {
        
        guard let index = viewModel?.selectedIndex else {
            selectedSegmentIndex = UISegmentedControl.noSegment
            return
        }
        selectedSegmentIndex = index
    }
}
