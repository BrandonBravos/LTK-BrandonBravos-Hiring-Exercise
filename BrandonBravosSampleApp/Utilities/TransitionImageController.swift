//
//  TransitionImageController.swift
//  BrandonBravosSampleApp
//
//  Created by Brandon Bravos on 1/3/23.
//

import UIKit

struct TransitionImageController {
    var toViewController: DisplayViewController?
    var fromImageView = UIImageView()
    var transitionImageView = UIImageView()
    
    /// creates the transition image and begins by covering it over the previous image at the specified points.
    mutating public func begin(fromView viewController: UIViewController,
                               fromImageView imageView: UIImageView,
                               toNewView toViewController: DisplayViewController) {
        self.toViewController = toViewController
        self.fromImageView = imageView
        self.createBackgroundImage(fromViewController: viewController, toViewController: toViewController)

        addImageViewToNewController()
        tansition()
    }
    
    mutating private func addImageViewToNewController() {
        guard let toViewController = toViewController else {
            print("TransitionImageController: Error finding ViewController")
            return
        }

        let globalPoint = fromImageView.superview?.convert( fromImageView.frame.origin, to: nil)
        let frame = fromImageView.frame
        let transitionImageView = UIImageView()
        self.transitionImageView = transitionImageView
        transitionImageView.image = fromImageView.image
        transitionImageView.clipsToBounds = true
        transitionImageView.layer.cornerRadius = 15
        transitionImageView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        transitionImageView.center = CGPoint(x: globalPoint!.x + frame.width/2, y: globalPoint!.y + frame.height/2)
        toViewController.view.addSubview(transitionImageView)
    }

    // starts the transitional animation. Animates our view from one end to hover over our post image
    private func tansition(){
        guard let toViewController = toViewController else {
            print("TransitionImageController: Error finding ViewController")
            return
        }
        let height = fromImageView.image!.getHeightAspectRatio(withWidth:  UIScreen.main.bounds.width - 20) - 30
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: { [self] in
            toViewController.view.backgroundColor = .white
            transitionImageView.frame = CGRect(x: 6, y: 163, width: UIScreen.main.bounds.width - 12, height: height)
        }, completion: { _ in
            toViewController.view.layoutIfNeeded()
            animateTransitionFadeIn()
        })
    }

    // fades in the views and removes the transition image
    private func animateTransitionFadeIn() {
        guard let toViewController = toViewController else {
            print("TransitionImageController: Error finding ViewController")
            return
        }
        let transitionAlpha = 1.0
        UIView.animate(withDuration: 0.1, delay: 0,
                       options: .curveEaseIn, animations: {
            for view in toViewController.animationViews {
                view.alpha = transitionAlpha
            }
        }) { _ in
            toViewController.view.layoutIfNeeded()
            self.transitionImageView.alpha = 0
        }
    }

    private func createBackgroundImage(fromViewController viewController: UIViewController, toViewController: UIViewController) {
        // render parent view in a UIImage
        UIGraphicsBeginImageContext(viewController.view.bounds.size)
        viewController.parent?.view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let viewImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        // add the image as background of the view
        toViewController.view.insertSubview(UIImageView(image: viewImage), at: 0)
    }
}
