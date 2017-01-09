//
//  ExampleCollectionViewLayout.swift
//  WaterfallFlowLayoutExample
//
//  Created by Crazy on 2017/1/8.
//  Copyright © 2017年 Crazy. All rights reserved.
//

import UIKit

fileprivate struct Common {
  static let Margin: CGFloat = 8
  static let Column: Int = 3
  static let Insets: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
}

class ExampleCollectionViewLayout: UICollectionViewLayout {

  // MARK: - Property
  
  fileprivate var attrs: [UICollectionViewLayoutAttributes] = []
  /*
   每列的高度
   */
  fileprivate var columnHeights: [CGFloat] = []
  /*
   高度最大的列的高度
   */
  fileprivate var maxY: CGFloat!
  
  /*
   返回index位置下的item的高度 required
   */
  var waterfallLayoutClosure: ((_ waterfallLayout: ExampleCollectionViewLayout, _ index: Int, _ width: CGFloat) -> CGFloat)!
  /*
   返回瀑布流显示的列数
   */
  var columnCountOfWaterfallLayoutClosure: ((_ waterfallLayout: ExampleCollectionViewLayout) -> Int)?
  /*
   return row margin
   */
  var rowMarginOfWaterfallLayoutClosure: ((_ waterfallLayout: ExampleCollectionViewLayout) -> CGFloat)?
  /*
   return column margin
   */
  var columnMarginOfWaterfallLayoutClosure: ((_ waterfallLayout: ExampleCollectionViewLayout) -> CGFloat)?
  /*
   return insets
   */
  var edgeInsetsOfWaterfallLayoutClosure: ((_ waterfallLayout: ExampleCollectionViewLayout) -> UIEdgeInsets)?
  
  // MARK: - Override
  
  /*
   Tells the layout object to update the current layout.
   CollectionView第一次布局的时候和失效的时候会调用该方法.
   */
  override func prepare() {
    super.prepare()
    columnHeights.removeAll(keepingCapacity: false)
    attrs.removeAll(keepingCapacity: false)
    
    for _ in 0..<_columnCount() {
      columnHeights.append(_edgeInsets().top)
    }
    
    if let collectionView = collectionView {
      let count = collectionView.numberOfItems(inSection: 0)
      for i in 0..<count {
        let attr = layoutAttributesForItem(at: IndexPath(item: i, section: 0))
        attrs.append(attr!)
      }
    }
    
    var temp: CGFloat = 0
    for (_, value) in columnHeights.enumerated() {
      if value > temp {
        temp = value
      }
    }
    self.maxY = temp
  }
  
  /*
   Returns the layout attributes for all of the cells and views in the specified rectangle.
   返回rect范围内所有元素的布局属性的数组
   */
  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    return attrs
  }
  
  /*
   Returns the layout attributes for the item at the specified index path.
   返回indexPath位置上的元素的布局属性
   */
  override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    guard let collectionView = collectionView else { return nil }
//    创建布局属性
    let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
//    宽度
    let itemWidth = (collectionView.frame.size.width - _edgeInsets().left - _edgeInsets().right - (CGFloat(_columnCount()) - 1) * _columnMargin()) / CGFloat(_columnCount())
//    计算当前item应该摆放在第几列(计算哪一列高度最短)
    var minColumn = 0 // 默认第0列
    var minHeight = CGFloat(MAXFLOAT) // 高度最小的列的高度
    for (index, value) in columnHeights.enumerated() {
      if minHeight > value {
        minHeight = value
        minColumn = index
      }
    }
    
    let x = _edgeInsets().left + CGFloat(minColumn) * (_columnMargin() + itemWidth)
    let y = minHeight + _rowMargin()
    
    let itemHeight = waterfallLayoutClosure(self, indexPath.item, itemWidth)
    
    attributes.frame = CGRect(origin: CGPoint(x: x, y: y), size: CGSize(width: itemWidth, height: itemHeight))
    
//    更新数组中的最短列的高度
    columnHeights[minColumn] = y + itemHeight
    
    return attributes
  }
  
  /*
   返回collectionView的滚动范围
   */
  override var collectionViewContentSize: CGSize {
    guard let collectionView = collectionView else { return .zero }
    return CGSize(width: collectionView.frame.size.width,
                  height: self.maxY)
  }
  
}

extension ExampleCollectionViewLayout {
  
  fileprivate func _columnCount() -> Int {
    return columnCountOfWaterfallLayoutClosure != nil ? columnCountOfWaterfallLayoutClosure!(self) : Common.Column
  }
  
  fileprivate func _rowMargin() -> CGFloat {
    return rowMarginOfWaterfallLayoutClosure != nil ? rowMarginOfWaterfallLayoutClosure!(self) : Common.Margin
  }
  
  fileprivate func _columnMargin() -> CGFloat {
    return columnMarginOfWaterfallLayoutClosure != nil ? columnMarginOfWaterfallLayoutClosure!(self) : Common.Margin
  }
  
  fileprivate func _edgeInsets() -> UIEdgeInsets {
    return edgeInsetsOfWaterfallLayoutClosure != nil ? edgeInsetsOfWaterfallLayoutClosure!(self) : Common.Insets
  }
  
}
