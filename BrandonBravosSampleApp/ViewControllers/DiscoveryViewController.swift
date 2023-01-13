//
//  ViewController.swift
//  BrandonBravosSampleApp
//
//  Created by Brandon Bravos on 12/6/22.
//

import UIKit


class DiscoveryViewController: LTKViewController {
    private enum DiscoverySections {
        case discover, alt
    }
    
    var viewModel = DiscoveryViewModel()
    
    private typealias DataSource = UICollectionViewDiffableDataSource<DiscoverySections, Profile>
    private typealias SnapShot = NSDiffableDataSourceSnapshot<DiscoverySections, Profile>
    
    private lazy var dataSource = makeDataSource()
    


    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func setCollectionViewLayout() -> UICollectionViewLayout {
        let layout = DiscoverLayout()
        layout.delegate = self
        return layout
    }
    override func viewWillAppear(_ animated: Bool) {
        guard viewModel.hasInitialized == false else {
            return
        }
        loadData()
        viewModel.hasInitialized = true
    }
    
    private func loadData() {
        viewModel.getPostData { [weak self] profile in
            DispatchQueue.main.async {
                self?.loadIndicator.pause()
                self?.applySnapShot(profile: profile)
            }
        }
    }

    private func makeDataSource() -> DataSource {
        let dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, profile in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LtkImageCell.reuseIdentifier,
                                                                for: indexPath) as? LtkImageCell else {
                print("DiscoveryViewController: Error dequeing LtkImageCell")
                return LtkImageCell()
            }
            profile.ltks.first!.getPostImage { image in
                cell.imageView.image = image
            }
            return cell
        }
        return dataSource
    }

    // update table view
    private func applySnapShot(profile: Profile) {
        var snapshot = SnapShot()
        let lastItem = dataSource.snapshot().itemIdentifiers.last
        switch lastItem == nil {
        case true:
            snapshot.appendSections([.discover])
            snapshot.appendItems([profile], toSection: .discover)
            dataSource.apply(snapshot, animatingDifferences: false)
        case false:
            snapshot = dataSource.snapshot()
            snapshot.insertItems([profile], afterItem: lastItem!)
            dataSource.apply(snapshot, animatingDifferences: false)
        }
    }
}

// MARK: Delegates
extension DiscoveryViewController {
    // if we have neared the end ouf our scroll view, download more posts.
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffsetX = scrollView.contentOffset.y
        let isLoading = viewModel.isLoading
        guard contentOffsetX >= scrollView.contentSize.height - scrollView.bounds.height - 20 else { return }
        guard !isLoading && dataSource.snapshot().numberOfItems % 10 < 5 else { return }
        loadData()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? LtkImageCell,
              cell.imageView.image != nil else {
            print("DiscoveryViewController: Error getting LtkImageCell when selected")
            return
        }

        let user = dataSource.snapshot().itemIdentifiers[indexPath.row]
        let displayViewController = DisplayViewController(withUser: user, withLtk: user.ltks.first!)
        var transitionController = TransitionImageController()
        transitionController.begin(fromView: self, fromImageView: cell.imageView, toNewView: displayViewController)
        navigationController?.pushViewController(displayViewController, animated: false)
    }
}

// used for dynamically setting height
extension DiscoveryViewController: DiscoverLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        let desiredWidth = (UIScreen.main.bounds.width / 2) - 10
        guard let post = dataSource.snapshot().itemIdentifiers[indexPath.row].ltks.first else {
            print("Discovery View Controller: Cant Find first user post")
            return 0
        }
        return post.getHeightAspectRatio(withWidth: desiredWidth)
    }
}
