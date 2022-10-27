//
//  UITableView+Extensions.swift
//  Spika
//
//  Created by Nikola Barbarić on 03.04.2022..
//

import UIKit

extension UITableView {
    
    func scrollToBottom(_ type: ScrollToBottomType){
        guard let lastCellIndexPath else { return }
        switch type {
        case .ifLastCellVisible:
            if isCellVisible(at: lastCellIndexPath) {
                self.scrollToRow(at: lastCellIndexPath, at: .bottom, animated: false)
            }
        case .force:
            self.scrollToRow(at: lastCellIndexPath, at: .bottom, animated: false)
        }
    }
    
    func isCellVisible(at indexPath: IndexPath) -> Bool {
        return cellForRow(at: indexPath) != nil
    }
    
    var lastCellIndexPath: IndexPath? {
        let lastSectionIndex = self.numberOfSections - 1
        if lastSectionIndex < 0 { return nil}
        let lastRowIndex = self.numberOfRows(inSection: lastSectionIndex) - 1
        if lastRowIndex < 0 { return nil}
        let lastCellIndexPath = IndexPath(row: lastRowIndex, section: lastSectionIndex)
        return lastCellIndexPath
    }
    
    func reloadPreviousRow(for indexPath: IndexPath) {
        let currentRow = indexPath.row
        guard currentRow > 0 else { return }
        let previousCellIndexPath = IndexPath(row: currentRow - 1, section: indexPath.section)
        UIView.performWithoutAnimation {
            self.reloadRows(at: [previousCellIndexPath], with: .none)
        }
    }
}
