//
//  DiscoverViewController.swift
//  BrandonBravosSampleApp
//
//  Created by Brandon Bravos on 12/17/22.
//

import UIKit

private struct ProfileCatagory: Hashable{
    var profile: Profile
    var isPost = true
}


class HomeViewController: LTKViewController {
    let viewModel = HomeViewModel()
    
    private typealias DataSource = UICollectionViewDiffableDataSource<DisplaySections, ProfileCatagory>
    private typealias SnapShot = NSDiffableDataSourceSnapshot<DisplaySections, ProfileCatagory>
    private lazy var dataSource = makeDataSource()
    
    private enum DisplaySections {
        case followedCreators, followingPost
    }

    private let displaySections: [DisplaySections] = [.followedCreators, .followingPost]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // gets an array of creator profiles, their posts, and products related to that post
        viewModel.getPostData { [weak self] profile in
            DispatchQueue.main.async {
                let catagorizedProfile = ProfileCatagory(profile: profile)
                self?.loadIndicator.pause()
                self?.applySnapShot(profile: catagorizedProfile)
                self?.collectionView.alpha = 1
            }
        }
    }
    
    private func makeDataSource() -> DataSource {
        // create cells
        let dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, profile in
            switch self.displaySections[indexPath.section] {
            case .followedCreators:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FollowedCreatorsCell.reuseIdentifier,
                                                                    for: indexPath) as? FollowedCreatorsCell else {
                    let cell = FollowedCreatorsCell()
                    print("HomeViewController: Error dequeing FollowedCreatorsCell")
                    return cell
                }
                var profiles = self.dataSource.snapshot().itemIdentifiers.map{$0.profile}
                profiles.removeFirst()
                cell.setProfileArray(profiles: profiles)
                return cell
            case .followingPost:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FullDisplayCell.reuseIdentifier,
                                                                    for: indexPath) as? FullDisplayCell else {
                    let cell = FullDisplayCell()
                    print("HomeViewController: Error dequeing FullDisplayCell")
                    return cell
                }
                guard let post = profile.profile.ltks.first else {
                    print("HomeViewController: Error getting post")
                    return BlankCollectionViewCell()
                }
                cell.setProducts(products: post.products)
                post.getPostImage { image in
                    cell.configure(profile: profile.profile, withPostImage: image)
                }
                return cell
            }
        }
        
        // create headers
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader else {
                return nil
            }
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                                   withReuseIdentifier: SimpleHeaderReusableView.reuseIdentifier,
                                                                                   for: indexPath) as? SimpleHeaderReusableView else {
                let headerView = SimpleHeaderReusableView()
                print("HomeViewController: Could not find SimpleHeaderReusableView")
                return headerView
            }
            let title = indexPath.section == 0 ? "Creators you follow" : "Shop new posts from Creators you follow"
            headerView.setTitle(title)
            return headerView
        }
        return dataSource
    }

    // update table view
    private func applySnapShot(profile: ProfileCatagory) {
        var snapshot = SnapShot()
        let lastItem = dataSource.snapshot().itemIdentifiers.last
        var initialPost = profile
        initialPost.isPost.toggle()

        switch lastItem == nil {
        case true:
            snapshot.appendSections([.followedCreators, .followingPost])
            snapshot.appendItems([profile], toSection: .followingPost)
            snapshot.appendItems([initialPost], toSection: .followedCreators)
            dataSource.apply(snapshot, animatingDifferences: true)
        case false:
            snapshot = dataSource.snapshot()
            snapshot.insertItems([profile], afterItem: lastItem!)
            snapshot.reloadSections([.followedCreators])
            dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
}

// MARK: - Delegates
extension HomeViewController{
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        switch displaySections[indexPath.section] {
        case .followedCreators:
            return CGSize(width: screenWidth, height: 100)
        case .followingPost:
            let post = dataSource.snapshot().itemIdentifiers[indexPath.row + 1].profile.ltks.first
            let adjustedHeight = post?.getHeightAspectRatio(withWidth: screenWidth)
            return CGSize(width: screenWidth - 20, height: adjustedHeight! + 150)
        }
    }

    // if we have neared the end ouf our scroll view, download more posts.
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let isLoading = viewModel.isLoading
        guard scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.bounds.height - 20 else { return }
        guard !isLoading  && dataSource.snapshot().numberOfItems > viewModel.profileArray.count - 5 else { return }
        viewModel.getPostData { [weak self] profile in
            DispatchQueue.main.async {
                let catgorizedProfile = ProfileCatagory(profile: profile)
                self?.applySnapShot(profile: catgorizedProfile)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        guard indexPath.section == 1 else {return}
        guard let cell = collectionView.cellForItem(at: indexPath) as? FullDisplayCell,
              cell.postImageView.image != nil else {
            print("DiscoveryViewController: Error getting LtkImageCell when selected")
            return
        }

        let user = dataSource.snapshot().itemIdentifiers[indexPath.row + 1].profile
        let displayViewController = DisplayViewController(withUser: user, withLtk: user.ltks.first!)
        
        var transitionController = TransitionImageController()
        transitionController.begin(fromView: self, fromImageView: cell.postImageView, toNewView: displayViewController)

        // push the view controller
        navigationController?.pushViewController(displayViewController, animated: false)
    }
}

