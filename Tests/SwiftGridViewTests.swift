// SwiftGridViewTests.swift
// Copyright (c) 2016 - Present Nathan Lampi (http://nathanlampi.com/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import XCTest
import SwiftGridView

class SwiftGridViewTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
        
        super.tearDown()
    }
    
    
    // MARK: - SwiftGridCell
    
    func testSwiftGridCell() {
        XCTAssert(SwiftGridCell.reuseIdentifier() == "SwiftGridCellReuseId")
        
        let rect:CGRect = CGRect(x: 0, y: 0, width: 125, height: 35)
        let cell:SwiftGridCell = SwiftGridCell(frame: rect)
        
        XCTAssert(cell.frame.equalTo(rect))
        XCTAssert(cell.backgroundColor == UIColor.clear)
        
        //SwiftGridTestNibCell.xib
    }
    
    
    // MARK: - SwiftGridReusableView
    
    func testSwiftGridReusableView() {
        XCTAssert(SwiftGridReusableView.reuseIdentifier() == "SwiftGridReusableViewReuseId")
        
        let rect:CGRect = CGRect(x: 0, y: 0, width: 125, height: 35)
        let view:SwiftGridReusableView = SwiftGridReusableView(frame: rect)
        let redView = UIView()
        redView.backgroundColor = UIColor.red
        view.backgroundView = redView
        let blueView = UIView()
        blueView.backgroundColor = UIColor.blue
        view.selectedBackgroundView = blueView
        
        view.layoutIfNeeded()
        
        XCTAssert(view.frame.equalTo(rect))
        XCTAssert(view.contentView.frame.equalTo(rect))
        XCTAssert(view.backgroundView!.frame.equalTo(rect))
        XCTAssert(view.selectedBackgroundView!.frame.equalTo(rect))
        XCTAssert(view.backgroundColor == UIColor.clear)
        
        view.highlighted = true
        XCTAssert(view.selectedBackgroundView?.isHidden == false)
        view.highlighted = false
        XCTAssert(view.selectedBackgroundView?.isHidden == true)
        view.selected = true
        XCTAssert(view.selectedBackgroundView?.isHidden == false)
        view.selected = false
        XCTAssert(view.selectedBackgroundView?.isHidden == true)
        
        let greenView = UIView()
        greenView.backgroundColor = UIColor.green
        view.backgroundView = greenView
        
        // Verify that the Background is behind the Selected Background
        XCTAssert(view.subviews.firstIndex(of: view.backgroundView!)! < view.subviews.firstIndex(of: view.selectedBackgroundView!)!)
        
        
        view.prepareForReuse()
        XCTAssert(view.highlighted == false)
        XCTAssert(view.selected == false)
        XCTAssert(view.selectedBackgroundView?.isHidden == true)
    }
    
    
    // MARK: - IndexPath+SwiftGridView
    
    func testIndexPathExtension() {
        let indexPath: IndexPath = IndexPath(forSGRow: 3, atColumn: 4, inSection: 2)
        
        XCTAssertEqual(indexPath.sgRow, 3)
        XCTAssertEqual(indexPath.sgColumn, 4)
        XCTAssertEqual(indexPath.sgSection, 2)
    }
    
    func testSelectionHeaderIndexPaths() {
        let mockData = SGMockBasicDataSource()
        let gridView = SwiftGridView()
        gridView.dataSource = mockData
        
        XCTAssertTrue(gridView.selectedHeaderIndexPaths.isEmpty)
        
        let indexA = IndexPath(forSGRow: 0, atColumn: 1, inSection: 1)
        let indexB = IndexPath(forSGRow: 0, atColumn: 5, inSection: 1)
        let indexC = IndexPath(forSGRow: 3 , atColumn: 3, inSection: 1)
        
        gridView.selectHeaderAtIndexPath(indexA)
        gridView.selectHeaderAtIndexPath(indexB)
        gridView.selectHeaderAtIndexPath(indexC)
        
        XCTAssertEqual(Set(gridView.selectedHeaderIndexPaths),
                       Set([indexA, indexB, indexC]))
        
        // bogus index
        gridView.deselectHeaderAtIndexPath(.init(item: 9, section: 9))
        
        XCTAssertEqual(Set(gridView.selectedHeaderIndexPaths),
                       Set([indexA, indexB, indexC]))
        
        gridView.deselectHeaderAtIndexPath(indexC)
        gridView.deselectHeaderAtIndexPath(indexB)
        XCTAssertEqual(gridView.selectedHeaderIndexPaths, [indexA])
        
        gridView.deselectHeaderAtIndexPath(indexA)
        XCTAssertTrue(gridView.selectedHeaderIndexPaths.isEmpty)
        
        gridView.deselectHeaderAtIndexPath(indexA)
        
        XCTAssertTrue(gridView.selectedHeaderIndexPaths.isEmpty)
        
    }
    
    func testSelectColumn() {
        let mockData = SGMockBasicDataSource()
        let gridView = SwiftGridView()
        gridView.dataSource = mockData
        
        XCTAssertTrue(gridView.selectedHeaderIndexPaths.isEmpty)
        XCTAssertTrue((gridView.collectionView.indexPathsForSelectedItems ?? []).isEmpty)
        
        let bogusIndexA = IndexPath(forSGRow: -54, atColumn: 1, inSection: 1)
        
        let indexA = IndexPath(forSGRow: 0, atColumn: 1, inSection: 1)
        let indexB = IndexPath(forSGRow: 0, atColumn: 2, inSection: 1)
        
        let bogusIndexB = IndexPath(forSGRow: 11, atColumn: 1, inSection: 1)
        
        let expectedRowCounts1 = mockData.rowCounts[indexA.sgSection]
        XCTAssertEqual(expectedRowCounts1, 10)
        
        let expectedRowCounts2 = mockData.rowCounts[indexB.sgSection]
        XCTAssertEqual(expectedRowCounts2, 10)
        
        gridView.selectColumnAtIndexPath(bogusIndexA, animated: false)
        
        XCTAssertTrue(gridView.selectedHeaderIndexPaths.isEmpty)
        XCTAssertTrue((gridView.collectionView.indexPathsForSelectedItems ?? []).isEmpty)
        
        gridView.selectColumnAtIndexPath(bogusIndexB, animated: false)
        
        XCTAssertTrue(gridView.selectedHeaderIndexPaths.isEmpty)
        XCTAssertTrue((gridView.collectionView.indexPathsForSelectedItems ?? []).isEmpty)
        
        gridView.selectColumnAtIndexPath(indexA, animated: false)
        
        XCTAssertEqual(gridView.selectedHeaderIndexPaths,
                       [IndexPath(forSGRow: 0,
                                  atColumn: indexA.sgColumn,
                                  inSection: indexA.sgSection)] )

        XCTAssertEqual(gridView.collectionView.indexPathsForSelectedItems?.count, expectedRowCounts1)
        
        let expectedPathsA = (0..<10).map { IndexPath(forSGRow: $0, atColumn: indexA.sgColumn, inSection: indexA.sgSection) }
        
        XCTAssertEqual(Set(gridView.indexPathsForSelectedItems), Set(expectedPathsA))
        
        gridView.selectColumnAtIndexPath(indexB, animated: false, includeHeader: false)
        
        XCTAssertEqual(gridView.selectedHeaderIndexPaths,
                       [IndexPath(forSGRow: 0,
                                  atColumn: indexA.sgColumn,
                                  inSection: indexA.sgSection)] )

        XCTAssertEqual(gridView.collectionView.indexPathsForSelectedItems?.count, expectedRowCounts1 + expectedRowCounts2)
        
        let expectedPathsB = (0..<10).map { IndexPath(forSGRow: $0, atColumn: indexB.sgColumn, inSection: indexB.sgSection) }

        XCTAssertEqual(Set(gridView.indexPathsForSelectedItems), Set(expectedPathsA + expectedPathsB))
        
        gridView.selectColumnAtIndexPath(indexB, animated: false, includeHeader: true)
        
        XCTAssertEqual(Set(gridView.selectedHeaderIndexPaths),
                       Set([IndexPath(forSGRow: 0,
                                  atColumn: indexA.sgColumn,
                                  inSection: indexA.sgSection),
                        IndexPath(forSGRow: 0,
                                   atColumn: indexB.sgColumn,
                                   inSection: indexB.sgSection)
                       ]))
        
        XCTAssertEqual(Set(gridView.indexPathsForSelectedItems), Set(expectedPathsA + expectedPathsB))

        XCTAssertEqual(gridView.collectionView.indexPathsForSelectedItems?.count, expectedRowCounts1 + expectedRowCounts2)
    }
    
    func testSelectRow() {
        let mockData = SGMockBasicDataSource()
        let gridView = SwiftGridView()
        gridView.dataSource = mockData
        
        XCTAssertTrue(gridView.selectedHeaderIndexPaths.isEmpty)
        XCTAssertTrue((gridView.collectionView.indexPathsForSelectedItems ?? []).isEmpty)
        
        let bogusIndexA = IndexPath(forSGRow: -1, atColumn: 1, inSection: 1)
        let indexB = IndexPath(forSGRow: 0, atColumn: 1, inSection: 1)
        let indexC = IndexPath(forSGRow: 1, atColumn: 2, inSection: 1)
        let bogusIndexD = IndexPath(forSGRow: 45, atColumn: 2, inSection: 1)
        
        XCTAssertEqual(mockData.columns, 5)
        
        // NOTE: Collection view `selectItem(at:..) method selects at any given index
        // doesn't matter if that index path exists or not...
        // Extra check were put in manually to prevent bogus selections - SP 5/4/23
        
        gridView.selectRowAtIndexPath(bogusIndexA, animated: false)
        XCTAssertEqual(gridView.collectionView.indexPathsForSelectedItems?.count, 0)
        
        gridView.selectRowAtIndexPath(indexB, animated: false)
        XCTAssertEqual(gridView.collectionView.indexPathsForSelectedItems?.count, 5)
        let expectedPaths1 = (0..<5).map { IndexPath(forSGRow: indexB.sgRow, atColumn: $0, inSection: indexB.sgSection) }
        
        XCTAssertEqual(Set(gridView.indexPathsForSelectedItems), Set(expectedPaths1))
        
        gridView.selectRowAtIndexPath(indexC, animated: false)
        
        let expectedPaths2 = (0..<5).map { IndexPath(forSGRow: indexC.sgRow, atColumn: $0, inSection: indexC.sgSection) }
        XCTAssertEqual(gridView.collectionView.indexPathsForSelectedItems?.count, 10)
        
        XCTAssertEqual(Set(gridView.indexPathsForSelectedItems), Set(expectedPaths1 + expectedPaths2))
        
        gridView.selectRowAtIndexPath(bogusIndexD, animated: false)
        XCTAssertEqual(gridView.collectionView.indexPathsForSelectedItems?.count, 10)
    }
}
