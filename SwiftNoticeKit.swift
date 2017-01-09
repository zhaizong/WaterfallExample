//
//  SwiftNoticeKit.swift
//  SwiftNoticeExample
//
//  Created by Crazy on 2017/1/2.
//  Copyright © 2017年 Crazy. All rights reserved.
//

import Foundation
import UIKit

fileprivate let _topBarTag: Int = 1001

extension UIResponder {
  
  func pleaseWait() { // no parameter
    SwiftNoticeKit._wait()
  }
  func successNotice(_ text: String, autoClear: Bool = true) {
    SwiftNoticeKit._showNoticeWithText(.success, text: text, autoClear: autoClear, autoClearTime: 3)
  }
  func errorNotice(_ text: String, autoClear: Bool = true) {
    SwiftNoticeKit._showNoticeWithText(.error, text: text, autoClear: autoClear, autoClearTime: 3)
  }
  func infoNotice(_ text: String, autoClear: Bool = true) {
    SwiftNoticeKit._showNoticeWithText(.info, text: text, autoClear: autoClear, autoClearTime: 3)
  }
  func noticeOnlyText(_ text: String) {
    SwiftNoticeKit._showText(text)
  }
  func noticeTop(_ text: String, autoClear: Bool = true, autoClearTime: Int = 1) {
    SwiftNoticeKit._noticeOnStatusBar(text, autoClear: autoClear, autoClearTime: autoClearTime)
  }
  func clearAllNotice() {
    SwiftNoticeKit._clear()
  }
  
}

enum NoticeType {
  case success
  case error
  case info
}

class NoticeSDK {
  struct Cache {
    static var imageOfCheckmark: UIImage?
    static var imageOfCross: UIImage?
    static var imageOfInfo: UIImage?
  }
  
  class var imageOfCheckmark: UIImage {
    guard Cache.imageOfCheckmark == nil else { return Cache.imageOfCheckmark! }
//    使用指定选项创建基于bitmap的图形上下文
//    size: new bitmap 上下文的大小（点测量）
//    opaque: bitmap 是否不透明
//    scale: bitmap 的缩放因素, if value of 0.0 则 scale factor 设置为设备主屏幕的 scale factor.
    UIGraphicsBeginImageContextWithOptions(CGSize(width: 36, height: 36), false, 0)
    
    draw(.success)
    
    Cache.imageOfCheckmark = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return Cache.imageOfCheckmark!
  }
  class var imageOfCross: UIImage {
    guard Cache.imageOfCross == nil else { return Cache.imageOfCross! }
    
    UIGraphicsBeginImageContextWithOptions(CGSize(width: 36, height: 36), false, 0)
    
    draw(.error)
    
    Cache.imageOfCross = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return Cache.imageOfCross!
  }
  class var imageOfInfo: UIImage {
    guard Cache.imageOfInfo == nil else { return Cache.imageOfInfo! }
    
    UIGraphicsBeginImageContextWithOptions(CGSize(width: 36, height: 36), false, 0)
    
    draw(.info)
    
    Cache.imageOfInfo = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return Cache.imageOfInfo!
  }
  
  class func draw(_ type: NoticeType) {
    let checkmarkBezierPath = UIBezierPath()
//    画圆
    checkmarkBezierPath.move(to: CGPoint(x: 36, y: 18)) // 将当前点移动到指定位置(当前坐标系中的一个点)
//    center: 指定一个用于定义圆弧的中心点（在当前坐标系中）
//    radius: 指定一个定义圆弧的圆的半径
//    startAngle: 指定圆弧的起始角度（以弧度表示）
//    endAngle: 指定圆弧终点角度（以弧度表示）
//    clockwise: 绘制圆弧的方向, 应该是顺时针和逆时针的区别
    checkmarkBezierPath.addArc(withCenter: CGPoint(x: 18, y: 18),
                               radius: 17.5,
                               startAngle: 0,
                               endAngle: CGFloat(M_PI * 2),
                               clockwise: true)
    checkmarkBezierPath.close() // 关闭最近添加的子路径
    
    switch type {
    case .success: // draw checkmark
      checkmarkBezierPath.move(to: CGPoint(x: 10, y: 18))
      checkmarkBezierPath.addLine(to: CGPoint(x: 16, y: 24)) // 在路径上添加一条直线
      checkmarkBezierPath.addLine(to: CGPoint(x: 27, y: 13))
      checkmarkBezierPath.move(to: CGPoint(x: 10, y: 18))
      checkmarkBezierPath.close()
    case .error: // draw X
      checkmarkBezierPath.move(to: CGPoint(x: 10, y: 10))
      checkmarkBezierPath.addLine(to: CGPoint(x: 26, y: 26))
      checkmarkBezierPath.move(to: CGPoint(x: 26, y: 10))
      checkmarkBezierPath.addLine(to: CGPoint(x: 10, y: 26))
      checkmarkBezierPath.move(to: CGPoint(x: 10, y: 10))
      checkmarkBezierPath.close()
    case .info: // draw !
      checkmarkBezierPath.move(to: CGPoint(x: 18, y: 6))
      checkmarkBezierPath.addLine(to: CGPoint(x: 18, y: 23))
      checkmarkBezierPath.move(to: CGPoint(x: 18, y: 6))
      checkmarkBezierPath.close()
      
      UIColor.white.setStroke()
      checkmarkBezierPath.stroke()
      
      let checkmarkBezierPath = UIBezierPath()
      checkmarkBezierPath.move(to: CGPoint(x: 18, y: 29))
      checkmarkBezierPath.addArc(withCenter: CGPoint(x: 18, y: 29),
                                 radius: 1,
                                 startAngle: 0,
                                 endAngle: CGFloat(M_PI * 2),
                                 clockwise: true)
      checkmarkBezierPath.close()
      
      UIColor.white.setFill()
      checkmarkBezierPath.fill()
    }
    UIColor.white.setStroke() // 设置笔画颜色
    checkmarkBezierPath.stroke() // 使用当前的绘图属性在路径上划一条线
  }
}

class SwiftNoticeKit: NSObject {
  
  // MARK: - Property
  
  static var _windows: [UIWindow] = []
  static let _rv: UIView = UIApplication.shared.keyWindow?.subviews.first as UIView!
  static var _timer: DispatchSource!
  static var _timerTimers = 0
  
  /* 
   just for iOS 8
   */
  static var _degree: Double {
    get {
      return [0, 0, 180, 270, 90][UIApplication.shared.statusBarOrientation.hashValue] as Double
    }
  }
  
  static func _wait(_ imageNames: [UIImage] = [], timeInterval: Int = 0) {
    let frame = CGRect(origin: .zero, size: CGSize(width: 78, height: 78))
    let window = UIWindow()
    window.backgroundColor = .clear
    let mainView = UIView(frame: .zero)
    mainView.layer.cornerRadius = 12
    mainView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
    
    if imageNames.count > 0 {
      if imageNames.count > _timerTimers {
        let iv = UIImageView(frame: frame)
        iv.image = imageNames.first!
        iv.contentMode = .scaleAspectFit
        mainView.addSubview(iv)
        _timer = DispatchSource.makeTimerSource(flags: .init(rawValue: 0), queue: .main) as! DispatchSource
        _timer.scheduleRepeating(deadline: DispatchTime.now(), interval: DispatchTimeInterval.milliseconds(timeInterval))
        _timer.setEventHandler(handler: { () -> Void in
          let name = imageNames[_timerTimers % imageNames.count]
          iv.image = name
          _timerTimers += 1
        })
        _timer.resume()
      }
    } else {
      let ai = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
      ai.frame = CGRect(origin: CGPoint(x: 21, y: 21), size: CGSize(width: 36, height: 36))
      ai.startAnimating()
      mainView.addSubview(ai)
    }
    window.frame = frame
    window.center = _rv.center
    mainView.frame = frame
    if let version = Double(UIDevice.current.systemVersion), version < 9.0 {
      window.center = _getRealCenter()
      window.transform = CGAffineTransform(rotationAngle: CGFloat(_degree * M_PI / 180))
    }
    window.windowLevel = UIWindowLevelAlert
    window.isHidden = false
    window.addSubview(mainView)
    _windows.append(window)
    
    mainView.alpha = 0
    UIView.animate(withDuration: 0.2) { 
      mainView.alpha = 1
    }
  }
  
  static func _showNoticeWithText(_ type: NoticeType, text: String, autoClear: Bool, autoClearTime: Int) {
    let frame = CGRect(origin: .zero, size: CGSize(width: 90, height: 90))
    let window = UIWindow()
    window.backgroundColor = .clear
    let mainView = UIView(frame: .zero)
    mainView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
    mainView.layer.cornerRadius = 10
    
    var image = UIImage()
    switch type {
    case .success:
      image = NoticeSDK.imageOfCheckmark
    case .error:
      image = NoticeSDK.imageOfCross
    case .info:
      image = NoticeSDK.imageOfInfo
    }
    
    let checkmarkImageView = UIImageView(frame: CGRect(origin: CGPoint(x: 27, y: 15), size: CGSize(width: 36, height: 36)))
    checkmarkImageView.image = image
    
    let label = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 60), size: CGSize(width: 90, height: 16)))
    label.font = UIFont.systemFont(ofSize: 14)
    label.text = text
    label.textColor = .white
    label.textAlignment = .center
    
    mainView.frame = frame
    window.frame = frame
    window.center = _rv.center
    window.windowLevel = UIWindowLevelAlert
    window.isHidden = false
    
    if let version = Double(UIDevice.current.systemVersion), version < 9.0 {
      window.center = _getRealCenter()
      window.transform = CGAffineTransform(rotationAngle: CGFloat(_degree * M_PI / 180))
    }
    
    mainView.addSubview(checkmarkImageView)
    mainView.addSubview(label)
    window.addSubview(mainView)
    _windows.append(window)
    
    mainView.alpha = 0
    UIView.animate(withDuration: 0.2) { 
      mainView.alpha = 1
    }
    
  }
  
  static func _showText(_ text: String) {
    let window = UIWindow()
    window.backgroundColor = .clear
    let mainView = UIView(frame: .zero)
    mainView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
    mainView.layer.cornerRadius = 12
    
    let label = UILabel(frame: .zero)
    label.text = text
    label.textColor = .white
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 14)
    label.numberOfLines = 0
    label.sizeToFit()
    mainView.addSubview(label)
    
    let frame = CGRect(origin: .zero, size: CGSize(width: label.frame.width + 50, height: label.frame.height + 30))
    window.frame = frame
    mainView.frame = frame
    
    label.center = mainView.center
    window.center = _rv.center
    
    if let version = Double(UIDevice.current.systemVersion), version < 9.0 {
      window.center = _getRealCenter()
      window.transform = CGAffineTransform(rotationAngle: CGFloat(_degree * M_PI / 180))
    }
    
    window.windowLevel = UIWindowLevelAlert
    window.isHidden = false
    window.addSubview(mainView)
    _windows.append(window)
  }
  
  static func _noticeOnStatusBar(_ text: String, autoClear: Bool, autoClearTime: Int) {
    let frame = UIApplication.shared.statusBarFrame
    let window = UIWindow()
    window.backgroundColor = .clear
    let view = UIView(frame: .zero)
    view.backgroundColor = UIColor(red: 0x6a / 0x100,
                                   green: 0x64 / 0x100,
                                   blue: 0x9f / 0x100,
                                   alpha: 1)
    
    let label = UILabel(frame: frame)
    label.text = text
    label.textColor = .white
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 14)
    view.addSubview(label)
    
    window.frame = frame
    view.frame = frame
    
    if let version = Double(UIDevice.current.systemVersion), version < 9.0 {
      var array = [UIScreen.main.bounds.width, UIScreen.main.bounds.height]
      array = array.sorted(by: <)
      let screenWidth = array[0]
      let screenHeight = array[1]
      let x = [0, screenWidth / 2, screenWidth / 2, 10, screenWidth - 10][UIApplication.shared.statusBarOrientation.hashValue] as CGFloat
      let y = [0, screenHeight - 10, screenHeight / 2, screenHeight / 2][UIApplication.shared.statusBarOrientation.hashValue] as CGFloat
      window.center = CGPoint(x: x, y: y)
      window.transform = CGAffineTransform(rotationAngle: CGFloat(_degree * M_PI / 180))
    }
    
    window.windowLevel = UIWindowLevelStatusBar
    window.isHidden = false
    window.addSubview(view)
    _windows.append(window)
    
    var origPoint = view.frame.origin
    origPoint.y = -(view.frame.size.height)
    let destPoint = view.frame.origin
    view.tag = _topBarTag
    
    view.frame = CGRect(origin: origPoint, size: view.frame.size)
    UIView.animate(withDuration: 0.3, animations: { 
      view.frame = CGRect(origin: destPoint, size: view.frame.size)
    }) { finished in
      if autoClear {
        let selector = #selector(_hideNotice(_:))
        perform(selector, with: window, afterDelay: TimeInterval(autoClearTime))
      }
    }
  }
  
  static func _clear() {
//    取消执行先前注册的 perform(_:with:afterDelay:) 实例方法。
    cancelPreviousPerformRequests(withTarget: self)
    if let _ = _timer {
      _timer.cancel()
      _timer = nil
      _timerTimers = 0
    }
    _windows.removeAll(keepingCapacity: false)
  }
  
}

extension SwiftNoticeKit {
  
  static func _getRealCenter() -> CGPoint {
    if UIApplication.shared.statusBarOrientation.hashValue >= 3 {
      return CGPoint(x: _rv.center.y, y: _rv.center.x)
    } else {
      return _rv.center
    }
  }
  
  static func _hideNotice(_ sender: AnyObject?) {
    if let window = sender as? UIWindow {
      if let v = window.subviews.first {
        
        UIView.animate(withDuration: 0.2, animations: { 
          if v.tag == _topBarTag {
            v.frame = CGRect(origin: CGPoint(x: 0, y: -v.frame.height), size: v.frame.size)
          }
          v.alpha = 0
        }, completion: { finished in
          if let index = _windows.index(where: { (item) -> Bool in
            return item == window
          }) {
            _windows.remove(at: index)
          }
        })
        
      }
    }
  }
  
}
