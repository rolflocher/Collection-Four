//
//  ViewController.swift
//  CollectionViewTest
//
//  Created by Rolf Locher on 12/1/18.
//  Copyright © 2018 Rolf Locher. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    
    var spacing = 500
    
    let Titles = ["1", "2", "3", "4"]
    let AppImages: [UIImage] = [
    
        UIImage(named: "app3")!,
        UIImage(named: "app2")!,
        UIImage(named: "app1")!,
        UIImage(named: "app4")!,
        ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource=self
        collectionView.delegate=self
        
        let layout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsets.init(top: 0,left: 5,bottom: 0,right: 5)
        layout.minimumInteritemSpacing = 5
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4 //AppImages.count //Titles.count   //AppImages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        cell.AppImageView.image = AppImages[indexPath.item]
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.borderWidth = 0.5
        //cell.frame.size.height = CGFloat(spacing)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderColor = UIColor.gray.cgColor
        cell?.layer.borderWidth = 2
        if( indexPath == [0,0]) {
            let vc: UIViewController = storyboard!.instantiateViewController(withIdentifier: "Cloudview") as UIViewController
            self.present(vc, animated: true, completion: nil)
        }
        if( indexPath == [0,1]) {
            let vc: UIViewController = storyboard!.instantiateViewController(withIdentifier: "Colorview") as UIViewController
            self.present(vc, animated: true, completion: nil)
        }
        if( indexPath == [0,2]) {
            let vc: UIViewController = storyboard!.instantiateViewController(withIdentifier: "NotesView") as UIViewController
            self.present(vc, animated: true, completion: nil)
        }
        if( indexPath == [0,3]) {
            let vc: UIViewController = storyboard!.instantiateViewController(withIdentifier: "GalleryView") as UIViewController
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderColor = UIColor.lightGray.cgColor
        cell?.layer.borderWidth = 0.5
    }
    
    var previousScrollOffset : CGFloat = 0
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {


        //layout.invalidateLayout()

        let scrollDiff = scrollView.contentOffset.y - self.previousScrollOffset
        //let absoluteTop: CGFloat = 0;
        //let absoluteBottom: CGFloat = scrollView.contentSize.height - scrollView.frame.size.height;

        //let isScrollingDown = scrollDiff > 0 && scrollView.contentOffset.y > absoluteTop
        //let isScrollingUp = scrollDiff < 0 && scrollView.contentOffset.y < absoluteBottom

        let newSpacing = abs(scrollDiff)

        

        if newSpacing > 5 {
            DispatchQueue.main.async{
            //self.collectionView?.setCollectionViewLayout(layout, animated: true)
                //let insets : UIEdgeInsets = (top: 0, left: 0, bottom: 0, right: 0)
                let layout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
                layout.invalidateLayout()
                layout.prepare()
                layout.minimumInteritemSpacing = 100
                self.spacing = 100
                /////
//                UIView.animate(withDuration: 0.7, delay: 1.0, options: .curveEaseOut, animations: {
//                    //self.view.layoutIfNeeded()
//                    self.collectionView.performBatchUpdates({
                
//                        layout.minimumInteritemSpacing = 100
//
//                    })
//                }, completion: { finished in
//                    print("Basket doors opened!")
//                })
                /////
                self.collectionView.layoutIfNeeded()
                self.collectionView.reloadData()
                
                
                //let insets = UIEdgeInsets.init(top: 50, left: 0, bottom: 50, right: 0)
                //self.collectionView.contentInset = insets
            //print(newSpacing)
            //print(self.collectionView.contentInset)
            }
                //self.collectionView.setNeedsLayout()
                //self.collectionView.collectionViewLayout.invalidateLayout()


                //layout.minimumInteritemSpacing = newSpacing

//                UIView.animate(withDuration: 1) {
//                    self.collectionView.setCollectionViewLayout(layout, animated: true)
//                    //CGSize(width: self.collectionView.frame.width - 50, height: 30)
//                    //self.collectionFlow.minimumInteritemSpacing = newSpacing
//                    self.collectionView.setNeedsLayout()
//                    //self.CollectionReusableViewTrailing.increaseSize(10)
//               // }

            //self.spacing = newSpacing
        }

        self.previousScrollOffset = scrollView.contentOffset.y
    }
    
    
    
    
}

