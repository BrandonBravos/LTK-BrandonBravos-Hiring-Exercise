//
//  ViewController.swift
//  BrandonBravosSampleApp
//
//  Created by Brandon Bravos on 12/6/22.
//

import UIKit

class HomeViewController: UIViewController {

    
    var viewModel = HomeViewModel()
    
    // a custom loading indicator
    private let loadIndicator = LtkLoadIndicator()

    lazy var collectionView: UICollectionView = {
         let layout = DiscoverLayout()
         let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
         cv.delegate = self
         cv.dataSource = self
        cv.register(LtkImageCell.self, forCellWithReuseIdentifier: LtkImageCell.reuseIdentifier)
         return cv
     }()
     
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addViews()

        // gets an array of creator profiles, their posts, and products related to that post
        viewModel.getPostData { [weak self] in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
                self?.loadIndicator.pause()
            }
        }
        
      
    }

}


// MARK: Delegates
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
 
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        print("hit")
        return CGSize(width: 100, height: 100)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.getCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! LtkImageCell
        let globalPoint = cell.imageView.superview?.convert( cell.imageView.frame.origin, to: nil)
        let image = cell.imageView.image!
        let frame = cell.imageView.frame

        
        let vc = DisplayViewController(withUser: viewModel.getUser(withIndex: indexPath))
      
        // render parent view in a UIImage
            UIGraphicsBeginImageContext(self.view.bounds.size);
            self.parent?.view.layer.render(in: UIGraphicsGetCurrentContext()!)
            let viewImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();

            // add the image as background of the view
        vc.view.insertSubview(UIImageView(image: viewImage), at: 0)
        
        // push the view controller
        navigationController?.pushViewController(vc, animated: false)
        vc.createTransitionAnimationImage(withImage: image, withCenter: globalPoint!, withFrame: frame)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LtkImageCell.reuseIdentifier, for: indexPath) as! LtkImageCell
        cell.imageView.image = viewModel.getImage(withIndex: indexPath)
        return cell
        
    }
}

// used for dynamically setting height
extension HomeViewController: DiscoverLayoutDelegate {
  func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath:IndexPath) -> CGFloat {
      let desiredWidth = (UIScreen.main.bounds.width / 2) - 10
      return viewModel.getImage(withIndex: indexPath)?.getHeightAspectRatio(withWidth: desiredWidth) ?? 200
  }
}


// MARK: Layout
extension HomeViewController{
    
    func addViews(){
        view.backgroundColor = .white
        
        let headearBarHeight: CGFloat = 45
        let headerView = HeaderSearchLabelView()
        headerView.backgroundColor = .white
        headerView.searchView.layer.cornerRadius = headearBarHeight / 2
        headerView.isUserInteractionEnabled = true
        view.addSubview(headerView)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: headearBarHeight)
        ])
        
        
        // sets our custom layout delegate
        if let layout = collectionView.collectionViewLayout as? DiscoverLayout {
          layout.delegate = self
        }
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 5),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -80)
        ])
        
       
        view.addSubview(loadIndicator)
        loadIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadIndicator.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 5),
            loadIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadIndicator.widthAnchor.constraint(equalToConstant: 55),
            loadIndicator.heightAnchor.constraint(equalToConstant: 55),

        ])
        
    }
    
}
