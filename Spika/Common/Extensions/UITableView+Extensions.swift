//
//  UITableView+Extensions.swift
//  Spika
//
//  Created by Nikola Barbarić on 03.04.2022..
//

import UIKit

extension UITableView {
    func scrollToBottom(){
        let lastSectionIndex = self.numberOfSections - 1
        if lastSectionIndex < 0 { return }
        let lastRowIndex = self.numberOfRows(inSection: lastSectionIndex) - 1
        if lastRowIndex < 0 { return }
        let lastCellIndexPath = IndexPath(row: lastRowIndex, section: lastSectionIndex)
        let cellRect = self.rectForRow(at: lastCellIndexPath)
        let completelyVisible = self.bounds.contains(cellRect)
        if !completelyVisible {
            print("Tableview scrollToBottom executed.")
            self.scrollToRow(at: lastCellIndexPath, at: .bottom, animated: false)
        }
    }
}
