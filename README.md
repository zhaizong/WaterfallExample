# WaterfallExample
waterfall layout example, written in pure Swift.

# How To Realize

* 利用UICollectionView实现瀑布流
* 创建自定义类继承UICollectionViewLayout
* 手动实现以下四个方法
```swift
Tells the layout object to update the current layout.
override func prepare() (UICollectionView第一次布局的时候和失效的时候会调用该方法.)

Returns the layout attributes for all of the cells and views in the specified rectangle.
override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? (返回rect范围内所有元素的布局属性的数组)

Returns the layout attributes for the item at the specified index path.
override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? (返回indexPath位置上的元素的布局属性)

override var collectionViewContentSize: CGSize (返回collectionView的滚动范围)
```

* Closure
```swift
提供接口给外界修改一些瀑布流布局的参数
@required
var waterfallLayoutClosure: ((_ waterfallLayout: ExampleCollectionViewLayout, _ index: Int, _ width: CGFloat) -> CGFloat)! (返回index位置下的item的高度)

@optional
var columnCountOfWaterfallLayoutClosure: ((_ waterfallLayout: ExampleCollectionViewLayout) -> Int)? (返回瀑布流显示的列数)
var rowMarginOfWaterfallLayoutClosure: ((_ waterfallLayout: ExampleCollectionViewLayout) -> CGFloat)? (return row margin)
var columnMarginOfWaterfallLayoutClosure: ((_ waterfallLayout: ExampleCollectionViewLayout) -> CGFloat)? (return column margin)
var edgeInsetsOfWaterfallLayoutClosure: ((_ waterfallLayout: ExampleCollectionViewLayout) -> UIEdgeInsets)? (return insets)
```

# Requirements

* iOS 8.0+
