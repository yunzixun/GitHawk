//
//  SegmentedControlSectionController.swift
//  Freetime
//
//  Created by Ryan Nystrom on 5/14/17.
//  Copyright © 2017 Ryan Nystrom. All rights reserved.
//

import UIKit
import IGListKit

protocol SearchBarSectionControllerDelegate: class {
    func didChangeSelection(sectionController: SearchBarSectionController, query: String)
}

final class SearchBarSectionController: ListSectionController, SearchBarCellDelegate {

    private weak var delegate: SearchBarSectionControllerDelegate? = nil
    private let height: CGFloat
    private let placeholder: String

    init(placeholder: String, delegate: SearchBarSectionControllerDelegate?, height: CGFloat) {
        self.delegate = delegate
        self.height = height
        self.placeholder = placeholder
        super.init()
    }

    override func sizeForItem(at index: Int) -> CGSize {
        guard let context = collectionContext else { fatalError("Collection context must be set") }
        // 28 is the default height of UISegmentedControl
        let height = 28 + 2*Styles.Sizes.rowSpacing
        return CGSize(width: context.containerSize.width, height: height)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: SearchBarCell.self, for: self, at: index) as? SearchBarCell
            else { fatalError("Collection context must be set, missing object, or cell incorrect type") }
        cell.delegate = self
        cell.placeholder = placeholder
        return cell
    }

    // MARK: SearchBarSectionControllerDelegate

    func didChangeSearchText(cell: SearchBarCell, query: String) {
        self.delegate?.didChangeSelection(sectionController: self, query: query)
    }
}