//
//  SearchView.swift
//  BrandonBravosSampleApp
//
//  Created by Brandon Bravos on 12/7/22.
//

import UIKit

class SearchView: UIView {

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    private func setUpView(){
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        
        
        let searchIconView = UIImageView(image: UIImage(named: "search_icon"))
        searchIconView.tintColor = UIColor.darkGray.withAlphaComponent(0.8)
        self.addSubview(searchIconView)
        searchIconView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchIconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            searchIconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            searchIconView.widthAnchor.constraint(equalTo: heightAnchor, multiplier: 0.5),
            searchIconView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.5),
        ])
        
        let searchTextField = UITextField()
        searchTextField.placeholder = "Search fashion, home & more"
        searchTextField.font = UIFont.systemFont(ofSize: 12)
        addSubview(searchTextField)
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchTextField.centerYAnchor.constraint(equalTo: centerYAnchor),
            searchTextField.leadingAnchor.constraint(equalTo: searchIconView.trailingAnchor, constant: 5),
            searchTextField.heightAnchor.constraint(equalTo: heightAnchor),
            searchTextField.trailingAnchor.constraint(equalTo: trailingAnchor)
            
        ])
        
        bringSubviewToFront(searchTextField)

        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
