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
        let lastRowIndex = self.numberOfRows(inSection: lastSectionIndex) - 1
        self.scrollToRow(at: IndexPath(row: lastRowIndex, section: lastSectionIndex), at: .bottom, animated: true)
    }
}
