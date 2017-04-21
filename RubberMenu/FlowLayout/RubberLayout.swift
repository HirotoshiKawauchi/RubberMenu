//
//  RubberLayout.swift
//  RubberMenu
//
//  Created by HIROTOSHI KAWAUCHI on 2017/04/09.
//  Copyright © 2017年 HIROTOSHI KAWAUCHI. All rights reserved.
//

import UIKit

class RubberLayout: UICollectionViewFlowLayout {
    var dynamicAnimator: UIDynamicAnimator? // 物理的な動作を与えるためにいる
    var visibleIndexPathSet: NSMutableSet?
    var latestDelta: CGFloat = 0.0
    
    let maxHeight: CGFloat = 35.0
    let cellHeight: CGFloat = 130.0
    let cellAllign: CGFloat = 100.0 //?
    
    override init() {
        super.init()
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup() {
        collectionView?.bounces = true
        var itemSize = self.itemSize
        itemSize.height = cellHeight + cellAllign + maxHeight
        self.itemSize = itemSize
        minimumLineSpacing = -cellAllign
        dynamicAnimator = UIDynamicAnimator(collectionViewLayout: self)
        visibleIndexPathSet = NSMutableSet()
    }
    
    override func prepare() {
        super.prepare()
        
        // 描画範囲の決定 collectionViewのサイズにinsetはx軸とy軸でそれぞれ-100(画面外にでてる状態)にする
        let visibleRect = CGRect(origin: collectionView?.bounds.origin ?? .zero , size: collectionView?.bounds.size ?? .zero).insetBy(dx: -100, dy: -100)
        
        // 可視領域に入っているcellのIndexを取得
        let itemsInVisibleRectArray: [UICollectionViewLayoutAttributes] = super.layoutAttributesForElements(in: visibleRect) ?? []
        
        // 重複を排除し純粋なIndexPathのリストを手にいれる
        let itemsIndexPathsInVisibleRectSet = NSSet(array: itemsInVisibleRectArray.map({ $0.indexPath }) )
        
        // 見えてない部分のBehavioursを取得
        let noLongerVisibleBehaviours = dynamicAnimator?.behaviors.filter({ (behavior) -> Bool in
            guard let attachmentBehavior = behavior as? UIAttachmentBehavior,
                let attributes = attachmentBehavior.items.last as? UICollectionViewLayoutAttributes else {
                    return true
            }
            
            let currentlyVisible = itemsIndexPathsInVisibleRectSet.member(attributes.indexPath) != nil
            return !currentlyVisible
        })
        
        
        // 見えてないBehavioursを削除
        noLongerVisibleBehaviours?.forEach({
            if let attachmentBehavior = $0 as? UIAttachmentBehavior,
                let attributes = attachmentBehavior.items.last as? UICollectionViewLayoutAttributes {
                dynamicAnimator?.removeBehavior($0)
                visibleIndexPathSet?.remove(attributes.indexPath)
            }
        })
        
        // 新しく見えるItemを取得
        let newlyVisibleItems = itemsInVisibleRectArray.filter { item -> Bool in
            let currentlyVisible = visibleIndexPathSet?.member(item.indexPath) != nil
            return !currentlyVisible
        }
        
        // タッチした場所から新しくBehaviorを作成して付与
        let touchLocation: CGPoint = collectionView?.panGestureRecognizer.location(in: collectionView) ?? .zero
        newlyVisibleItems.forEach { item in
            var center = item.center
            item.zIndex = Int(center.y)
            let springBehaviour = UIAttachmentBehavior(item: item, attachedToAnchor: center)
            springBehaviour.length = 0.0 // 2点間のうんたらかんたら。。。よくわからん
            springBehaviour.damping = 0.5 // 減衰率、0に近づくほど振動が止まらなくなる
            springBehaviour.frequency = 0.8 //振動数、これが大きいとよく跳ねる
            springBehaviour.action = { // アニメーションが行われるたびに呼ばれる。ここではセルの高さが変わる
                if let cell = self.collectionView?.cellForItem(at: item.indexPath) as? RubberCell {
                    cell.setNewHeight(self.latestDelta)
                }
            }
            if !__CGPointEqualToPoint(.zero, touchLocation) {
                let distanceFromTouch = fabsf(Float(touchLocation.y - springBehaviour.anchorPoint.y))
                let scrollResistance = distanceFromTouch / 1100.0 // スクロールスピードの調整。1に近づくと早くなる
                var newY: CGFloat = 0.0
                
                if latestDelta < 0 {
                    newY = max(fixDelta(latestDelta, withResistance: 1),
                               fixDelta(latestDelta, withResistance: CGFloat(scrollResistance)))
                    center.y += newY
                } else {
                    newY = min(fixDelta(latestDelta, withResistance: 1),
                               fixDelta(latestDelta, withResistance: CGFloat(scrollResistance)))
                    center.y += newY
                }
                item.center = center
            } else {
                NSLog("not touch")
            }
            
            dynamicAnimator?.addBehavior(springBehaviour)
            visibleIndexPathSet?.add(item.indexPath)
        }
    }
    
    func fixDelta(_ delta: CGFloat, withResistance res: CGFloat) -> CGFloat {
        if delta * res >= maxHeight {
            return maxHeight
        } else if (delta * res) <= -maxHeight {
            return -maxHeight
        } else {
            return delta * res
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let dynamicAnimator = dynamicAnimator else {
            return nil
        }
        
        return dynamicAnimator.items(in: rect) as? [UICollectionViewLayoutAttributes]
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let dynamicAnimator = dynamicAnimator else {
            return nil
        }
        
        return dynamicAnimator.layoutAttributesForCell(at: indexPath)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let scrollView = collectionView else {
            return false
        }
        
        let delta = newBounds.origin.y - scrollView.bounds.origin.y
        latestDelta = delta
        if let touchLocation = collectionView?.panGestureRecognizer.location(in: collectionView),
            let springBehaviors = dynamicAnimator?.behaviors.filter({ $0 is UIAttachmentBehavior }) as? [UIAttachmentBehavior] {
            springBehaviors.forEach({ springBehavior in
                let distanceFromTouch = fabsf(Float(touchLocation.y - springBehavior.anchorPoint.y))
                let scrollResistance = distanceFromTouch / 1100
                
                if let item = springBehavior.items.first as? UICollectionViewLayoutAttributes {
                    var center = item.center
                    item.zIndex = Int(center.y)
                    
                    if delta < 0 {
                        center.y += max(fixDelta(delta, withResistance: 1), fixDelta(delta, withResistance: CGFloat(scrollResistance)))
                    } else {
                        center.y += min(fixDelta(delta, withResistance: 1), fixDelta(delta, withResistance: CGFloat(scrollResistance)))
                    }
                    item.center = center
                    
                    dynamicAnimator?.updateItem(usingCurrentState: item)
                }
            })
        }
        return false
    }
}
