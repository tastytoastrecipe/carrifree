//
//  ExUICollectionViewController.swift
//  CarrifreeStorage
//
//  Created by plattics-kwon on 2021/09/14.
//

import Foundation
import UIKit

extension UICollectionView {
    func getAllCells() -> [UICollectionViewCell] {
        
        var cells = [UICollectionViewCell]()
        // assuming tableView is your self.tableView defined somewhere
        
        for i in 0...self.numberOfSections-1
        {
            for j in 0...self.numberOfItems(inSection: i) - 1
            {
                if let cell = self.cellForItem(at: NSIndexPath(row: j, section: i) as IndexPath) {
                    
                    cells.append(cell)
                }
                
            }
        }
        return cells
    }

}

