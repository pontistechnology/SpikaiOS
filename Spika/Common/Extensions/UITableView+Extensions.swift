//
//  UITableView+Extensions.swift
//  Spika
//
//  Created by Nikola Barbarić on 03.04.2022..
//

import UIKit

extension UITableView {
    func scrollToBottom(){
        guard let lastCellIndexPath else { return }
        if !isCompletlyVisibleCell(at: lastCellIndexPath) {
            print("Tableview scrollToBottom executed.")
            self.scrollToRow(at: lastCellIndexPath, at: .bottom, animated: false)
        }
    }
    
    func isCompletlyVisibleCell(at indexPath: IndexPath) -> Bool {
        return self.bounds.contains(self.rectForRow(at: indexPath))
    }
    
    var lastCellIndexPath: IndexPath? {
        let lastSectionIndex = self.numberOfSections - 1
        if lastSectionIndex < 0 { return nil}
        let lastRowIndex = self.numberOfRows(inSection: lastSectionIndex) - 1
        if lastRowIndex < 0 { return nil}
        let lastCellIndexPath = IndexPath(row: lastRowIndex, section: lastSectionIndex)
        return lastCellIndexPath
    }
}
