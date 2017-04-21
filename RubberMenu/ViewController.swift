//
//  ViewController.swift
//  RubberMenu
//
//  Created by HIROTOSHI KAWAUCHI on 2017/04/09.
//  Copyright © 2017年 HIROTOSHI KAWAUCHI. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var itemset: [UIColor] = []
    var previousScrollViewYOffset: CGFloat?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // imageのかわり
        let colorList: [UIColor] = [
            .black, .darkGray, .lightGray, .white, .gray,
            .red, .green, .blue, .cyan, .yellow,
            .magenta, .orange, .purple, .brown,
        ]
        
        colorList.forEach { itemset.append($0) }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let newView = UIView(frame: view.bounds)
        let top = UIView(frame: CGRect(x: 0.0,
                                       y: 0.0,
                                       width: view.bounds.size.width,
                                       height: view.bounds.size.height/2))
        let bottom = UIView(frame: CGRect(x: 0.0,
                                          y: view.bounds.size.height/2,
                                          width: view.bounds.size.width,
                                          height: newView.bounds.size.height/2))
        top.backgroundColor = itemset.first
        bottom.backgroundColor = itemset.last
        newView.addSubview(top)
        newView.addSubview(bottom)
        view.addSubview(newView)
        view.bringSubview(toFront: collectionView)
        collectionView.backgroundColor = .clear
        
        var cf = collectionView.frame
        cf.origin.y -= 100
        cf.size.height += 100
        collectionView.frame = cf
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemset.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "rubberCellIdentifier", for: indexPath) as? RubberCell {
            cell.backgroundColor = itemset[indexPath.row]
            return cell
        }
        return UICollectionViewCell()
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 200)
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        return
    }
}


