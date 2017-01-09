//
//  ExampleViewController.swift
//  WaterfallFlowLayoutExample
//
//  Created by Crazy on 2017/1/9.
//  Copyright © 2017年 Crazy. All rights reserved.
//

import UIKit

class ExampleViewController: UIViewController {

  var collectionView: UICollectionView!
  
  fileprivate var _heights: [CGFloat] = []
  fileprivate var _imgs: [String] = []
  fileprivate var _prices: [String] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    
    _setupApperance()
    _setupDataSource()
  }

}

extension ExampleViewController {
  
  fileprivate func _setupApperance() {
    let layout = ExampleCollectionViewLayout()
    layout.waterfallLayoutClosure = { [weak self] (layout: ExampleCollectionViewLayout, index: Int, width: CGFloat) in
      guard let weakSelf = self else { return 0 }
      return weakSelf._heights[index] * width / 200
    }
    
    collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
    collectionView.register(ExampleCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
    collectionView.backgroundColor = .white
    collectionView.showsVerticalScrollIndicator = true
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.dataSource = self
    view.addSubview(collectionView)
  }
  
  fileprivate func _setupDataSource() {
    _heights.removeAll(keepingCapacity: false)
    _imgs.removeAll(keepingCapacity: false)
    _prices.removeAll(keepingCapacity: false)
    
    let updateDataSource: () -> Void = {
      if self._imgs.count > 0 {
        self.collectionView.reloadData()
      }
    }
    
    if let filePath = Bundle.main.path(forResource: "0.plist", ofType: nil) {
      if let rootArray = NSArray(contentsOfFile: filePath) {
        for dict in rootArray {
          let height = CGFloat(((dict as! [String: Any])["h"] as! NSNumber).doubleValue)
          _heights.append(height)
          let img = (dict as! [String: Any])["img"] as! String
          _imgs.append(img)
          let price = (dict as! [String: Any])["price"] as! String
          _prices.append(price)
          updateDataSource()
        }
      }
    }
  }
  
}

extension ExampleViewController: UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return _imgs.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if indexPath.section == 0 {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ExampleCollectionViewCell
      cell.imgString = _imgs[indexPath.item]
      cell.priceString = _prices[indexPath.item]
      return cell
    }
    return UICollectionViewCell()
  }
  
}
