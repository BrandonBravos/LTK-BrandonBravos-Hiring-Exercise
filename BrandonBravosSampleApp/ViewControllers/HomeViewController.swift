//
//  DiscoverViewController.swift
//  BrandonBravosSampleApp
//
//  Created by Brandon Bravos on 12/17/22.
//

import UIKit

class HomeViewController: UIViewController {
        private enum DisplaySections{
            case followedCreators, followingPost
        }
    
        private let displaySections:[DisplaySections] = [.followedCreators,.followingPost]
    
    // a custom loading indicator
    private let loadIndicator = LtkLoadIndicator()
    
        lazy var collectionView: UICollectionView = {
            let layout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 20, right: 10)
            layout.minimumLineSpacing = 100
            let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
            cv.delegate = self
            cv.dataSource = self
            return cv
        }()
    
        let viewModel = HomeViewModel()
    
        override func viewDidLoad() {
            super.viewDidLoad()
            setUpView()
            // gets an array of creator profiles, their posts, and products related to that post
            viewModel.getPostData { [weak self] in
                DispatchQueue.main.async {
                    self?.loadIndicator.pause()
                    self?.collectionView.alpha = 1
                    self?.collectionView.reloadData()
                }
            }
            
        }
    }
    
    extension HomeViewController:  UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
        func numberOfSections(in collectionView: UICollectionView) -> Int {
            return displaySections.count
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
            let headerHeight:CGFloat = section == 0 ? 25 : 40
            return CGSize(width: UIScreen.main.bounds.width, height: headerHeight)
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let cell = collectionView.cellForItem(at: indexPath) as! FullDisplayCell
            let globalPoint = cell.postImageView.superview?.convert( cell.postImageView.frame.origin, to: nil)
            let image = cell.postImageView.image!
            let frame = cell.postImageView.frame

            let user = viewModel.getUser(withIndex: indexPath)
            let vc = DisplayViewController(withUser: user, withLtk: user.ltks.first!)
          
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
        
        
        // add our supplementary header view
        func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SimpleHeaderReusableView.reuseIdentifier, for: indexPath) as! SimpleHeaderReusableView
            let title = indexPath.section == 0 ? "Creators you follow" : "Shop new posts from Creators you follow"
            headerView.setTitle(title)
            return headerView
        }
        
        // if we have neared the end ouf our scroll view, download more posts.
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
           let contentOffsetX = scrollView.contentOffset.y
           if contentOffsetX >= (scrollView.contentSize.height - scrollView.bounds.height) - 20 /* Needed offset */ {
               guard !viewModel.isLoading  && viewModel.getLoadedPostsCount() > viewModel.profileArray.count - 5 else { return }
               viewModel.isLoading = true
               viewModel.getPostData { [weak self] in
                   DispatchQueue.main.async {
                       self?.collectionView.reloadData()
                   }
               }
           }
       }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            switch displaySections[indexPath.section] {
            case .followedCreators:
                return CGSize(width: UIScreen.main.bounds.width, height: 100)
            case .followingPost:
                return CGSize(width: UIScreen.main.bounds.width - 20, height: (viewModel.loadedPostsArray[indexPath.row].ltks.first?.getHeightAspectRatio(withWidth: UIScreen.main.bounds.width))! + 150 )
            }
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            if section > displaySections.count { return 0}
            switch displaySections[section]{
            case .followedCreators: return 1
            case .followingPost: return viewModel.loadedPostsArray.count
            }
        }
    
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            switch displaySections[indexPath.section] {
            case .followedCreators:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FollowedCreatorsCell.reuseIdentifier, for: indexPath) as! FollowedCreatorsCell
                cell.setProfileArray(profiles: viewModel.loadedPostsArray)
                return cell
            case .followingPost:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FullDisplayCell.reuseIdentifier, for: indexPath) as! FullDisplayCell
                
                cell.setProducts(products: viewModel.loadedPostsArray[indexPath.row].ltks.first!.products)
                
                viewModel.getImage(withIndex: indexPath){image in
                        cell.configure(profile: self.viewModel.loadedPostsArray[indexPath.row], withPostImage: image)
                }
                
                return cell

            }
        }
    
    
    }
    
    //MARK: Layout
    extension HomeViewController{
    
        private func setUpView(){
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
    
            collectionView.alpha = 0
            collectionView.register(SimpleHeaderReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SimpleHeaderReusableView.reuseIdentifier)
            collectionView.register(BlankCollectionViewCell.self, forCellWithReuseIdentifier: BlankCollectionViewCell.reuseIdentifier)
            collectionView.register(FollowedCreatorsCell.self, forCellWithReuseIdentifier: FollowedCreatorsCell.reuseIdentifier)
            collectionView.register(FullDisplayCell.self, forCellWithReuseIdentifier: FullDisplayCell.reuseIdentifier)

            view.addSubview(collectionView)
            collectionView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                collectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 5),
                collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100)
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
