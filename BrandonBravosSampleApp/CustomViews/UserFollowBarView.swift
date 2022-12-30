//
//  UserFollowBarView.swift
//  BrandonBravosSampleApp
//
//  Created by Brandon Bravos on 12/15/22.
//

import UIKit

class UserFollowBarView: UIView {

    let profileImageView = UIImageView()
    let profileUserTextLabel = UILabel()
    let profileBarHeight = 55.0
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
    }
    
    public func setUsername(_ usernameString: String){
        profileUserTextLabel.text = usernameString
    }
    
    public func setProfileImage(_ image: UIImage?){
        guard let image = image else {
            return
        }

        DispatchQueue.main.async {
            self.profileImageView.image = image
        }
    }
    
    override func layoutSubviews() {
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = (profileBarHeight - 20) / 2
        addSubview(profileImageView)
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            profileImageView.widthAnchor.constraint(equalToConstant: profileBarHeight - 20),
            profileImageView.heightAnchor.constraint(equalToConstant: profileBarHeight - 20),

        ])
        
        profileUserTextLabel.font = UIFont.montserratFont(withMontserrat: .bold, withSize: 15)
        addSubview(profileUserTextLabel)
        profileUserTextLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileUserTextLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8),
            profileUserTextLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            profileUserTextLabel.heightAnchor.constraint(equalToConstant: profileBarHeight),
            profileUserTextLabel.widthAnchor.constraint(equalToConstant: 350)
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
