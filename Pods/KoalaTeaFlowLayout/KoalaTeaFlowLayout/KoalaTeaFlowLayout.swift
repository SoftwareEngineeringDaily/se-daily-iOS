//
//  KoalaTeaFlowLayout.swift
//  museum-ios
//
//  Created by Craig Holliday on 3/8/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

// *** This is a piece of Koala Tea code. Check us out at KoalaTea.io ***

import UIKit

public class KoalaTeaFlowLayout: UICollectionViewFlowLayout {
    
    fileprivate var ratio: CGFloat = 1.0
    fileprivate var topBottomMargin: CGFloat = 0
    fileprivate var leftRightMargin: CGFloat = 0
    fileprivate var cellsAcross: CGFloat = 1
    fileprivate var cellsDown: CGFloat = 1
    fileprivate var cellSpacing: CGFloat = 0
    fileprivate var collectionViewWidth: CGFloat = UIScreen.main.bounds.width
    fileprivate var collectionViewHeight: CGFloat = UIScreen.main.bounds.height
    fileprivate var marginOfError: CGFloat = 0
    
    override public init() {
        super.init()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupLayout() {
        let spaceBetweenCells = cellSpacing * (cellsAcross - marginOfError)
        let width = (collectionViewWidth - (leftRightMargin * 2) - spaceBetweenCells) / cellsAcross - marginOfError
        let height = width * ratio
        let calculatedItemSize = CGSize(width: width, height: height)
        
        itemSize = calculatedItemSize
        
        sectionInset = UIEdgeInsets(top: topBottomMargin, left: leftRightMargin, bottom: topBottomMargin, right: leftRightMargin)
        minimumInteritemSpacing = cellSpacing
        minimumLineSpacing = cellSpacing
    }
    
    func setupHorizontalLayout() {
        let spaceBetweenCells = cellSpacing * (cellsDown - marginOfError)
        let height = (collectionViewHeight - (topBottomMargin * 2) - spaceBetweenCells) / cellsDown - marginOfError
        let width = height * ratio
        let calculatedItemSize = CGSize(width: width, height: height)
        
        itemSize = calculatedItemSize
        
        sectionInset = UIEdgeInsets(top: topBottomMargin, left: leftRightMargin, bottom: topBottomMargin, right: leftRightMargin)
        minimumInteritemSpacing = cellSpacing
        minimumLineSpacing = cellSpacing
    }
    
    func setupFullLayout() {
        let height = collectionViewHeight / cellsDown
        let width = collectionViewWidth / cellsAcross
        let calculatedItemSize = CGSize(width: width, height: height)
        
        itemSize = calculatedItemSize
        
        sectionInset = UIEdgeInsets(top: topBottomMargin, left: leftRightMargin, bottom: topBottomMargin, right: leftRightMargin)
        minimumInteritemSpacing = cellSpacing
        minimumLineSpacing = cellSpacing
    }
    
    override public func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        return collectionView!.contentOffset
    }
}

extension KoalaTeaFlowLayout {
    // Convenience Methods
    
    // Vertical - All
    convenience public init(ratio: CGFloat, topBottomMargin: CGFloat, leftRightMargin: CGFloat, cellsAcross: CGFloat, cellSpacing: CGFloat, collectionViewWidth: CGFloat) {
        self.init()
        self.scrollDirection = .vertical
        
        self.ratio = ratio
        self.topBottomMargin = topBottomMargin
        self.leftRightMargin = leftRightMargin
        self.cellsAcross = cellsAcross
        self.cellSpacing = cellSpacing
        self.collectionViewWidth = collectionViewWidth
        
        setupLayout()
    }
    
    // Horizontal - All
    convenience public init(ratio: CGFloat, topBottomMargin: CGFloat, leftRightMargin: CGFloat, cellsDown: CGFloat, cellSpacing: CGFloat, collectionViewHeight: CGFloat) {
        self.init()
        self.scrollDirection = .horizontal
        
        self.ratio = ratio
        self.topBottomMargin = topBottomMargin
        self.leftRightMargin = leftRightMargin
        self.cellsDown = cellsDown
        self.cellSpacing = cellSpacing
        self.collectionViewHeight = collectionViewHeight
        
        setupHorizontalLayout()
    }
    
    // Vertical - With Margins
    convenience public init(ratio: CGFloat, topBottomMargin: CGFloat, leftRightMargin: CGFloat, cellsAcross: CGFloat, cellSpacing: CGFloat) {
        self.init()
        self.scrollDirection = .vertical
        
        self.ratio = ratio
        self.topBottomMargin = topBottomMargin
        self.leftRightMargin = leftRightMargin
        self.cellsAcross = cellsAcross
        self.cellSpacing = cellSpacing
        
        setupLayout()
    }
    
    // Horizontal - With Margins
    convenience public init(ratio: CGFloat, topBottomMargin: CGFloat, leftRightMargin: CGFloat, cellsDown: CGFloat, cellSpacing: CGFloat) {
        self.init()
        self.scrollDirection = .horizontal
        
        self.ratio = ratio
        self.topBottomMargin = topBottomMargin
        self.leftRightMargin = leftRightMargin
        self.cellsDown = cellsDown
        self.cellSpacing = cellSpacing
        
        setupHorizontalLayout()
    }
    
    // Vertical - minimum
    convenience public init(ratio: CGFloat, cellsAcross: CGFloat, cellSpacing: CGFloat) {
        self.init()
        self.scrollDirection = .vertical
        
        self.ratio = ratio
        self.cellsAcross = cellsAcross
        self.cellSpacing = cellSpacing
        
        setupLayout()
    }
    
    // Horizontal - minimum
    convenience public init(ratio: CGFloat, cellsDown: CGFloat, cellSpacing: CGFloat) {
        self.init()
        self.ratio = ratio
        self.cellsDown = cellsDown
        self.cellSpacing = cellSpacing
        
        self.scrollDirection = .horizontal
        setupHorizontalLayout()
    }
    
    // Full
    
    convenience public init(cellsAcross: CGFloat, cellsDown: CGFloat, collectionViewWidth: CGFloat, collectionViewHeight: CGFloat) {
        self.init()
        
        self.cellsAcross = cellsAcross
        self.cellsDown = cellsDown
        self.collectionViewWidth = collectionViewWidth
        self.collectionViewHeight = collectionViewHeight
        
        setupFullLayout()
    }
}
