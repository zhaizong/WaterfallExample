//
//  ExampleCollectionViewCell.swift
//  WaterfallFlowLayoutExample
//
//  Created by Crazy on 2017/1/9.
//  Copyright © 2017年 Crazy. All rights reserved.
//

import UIKit

class ExampleCollectionViewCell: UICollectionViewCell {
  
  // MARK: - Property
  
  var imgString: String? {
    didSet {
      guard let imgString = imgString, imgString != "" else { return }
//      let index = imgString.index(imgString.startIndex, offsetBy: 3)
//      imgString.insert("s", at: imgString.index(after: index))
      DispatchQueue.global(qos: .background).async {
        if let url = URL(string: imgString) {
          do {
            let data = try Data(contentsOf: url)
            DispatchQueue.main.async {
              self._imgView.image = UIImage(data: data)
            }
          } catch let error {
            debugPrint("Error: \(error) \n")
          }
        }
      }
    }
  }
  var priceString: String? {
    didSet {
      guard let priceString = priceString, priceString != "" else { return }
      _priceLabel.text = priceString
    }
  }
  
  fileprivate var _imgView: UIImageView!
  fileprivate var _priceLabel: UILabel!
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    _imgView = UIImageView(frame: CGRect(origin: .zero, size: frame.size))
    _priceLabel = UILabel(frame: .zero)
    _priceLabel.font = UIFont.systemFont(ofSize: 15)
    _priceLabel.textColor = .white
    _priceLabel.textAlignment = .center
    
    contentView.addSubview(_imgView)
    _imgView.addSubview(_priceLabel)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    _imgView.frame = CGRect(origin: .zero, size: contentView.frame.size)
    _priceLabel.frame = CGRect(origin: CGPoint(x: 0, y: _imgView.frame.size.height - 30), size: CGSize(width: _imgView.frame.size.width, height: 30))
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
