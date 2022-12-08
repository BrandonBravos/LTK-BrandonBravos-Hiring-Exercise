//
//  File.swift
//  BrandonBravosSampleApp
//
//
//  Created by Brandon Bravos on 12/6/22.
//

import UIKit


// this is a global property that reference this script. Use cautiosly, should only be set once
// we will use this to get a reference to this base class throughout our project
// most notably for opening and closing our menu view, witch will rest on the side of this base view

struct TabBarController{
    static var parentController: NavigationMenuBaseController?
}


class NavigationMenuBaseController: UITabBarController {
    
    // the views we want to show
    private let tabItems: [CustomTabItem] = [.home, .favorites, .creators, .discover, .menu]

    // sets our tab bar height
    let tabBarHeight: CGFloat = 80.0
    
    // a reference to our custom tab bar
    var customTabBar: CustomTabBarView!
   
    // the leading constraint of our custom tab bar used for animating
    private var tabBarLeadingConstraint: NSLayoutConstraint!

    // our menu view that rests on the left hand side of this controller
    private var menuView: UIView!
   
    // a bool that determines if the menu is open
     public var menuIsOpen: Bool {
         return tabBarLeadingConstraint.constant > 0
       }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TabBarController.parentController = self
        self.loadTabBar()
        
    }
  

    
    // load the tab bar
    func loadTabBar() {
        // sets up our custom tab bar view amd adds our view controllers to our tab bar controller
        self.setupCustomTabBar(tabItems) { (controllers) in
            self.viewControllers = controllers
        }
        
        // sets our tab bar controller (current file) to our first view
        self.selectedIndex = 0
    }
    
    // this sets up our custom tab bar view and gets an array of view controllers
    func setupCustomTabBar(_ items: [CustomTabItem], completion: @escaping ([UIViewController]) -> Void) {
       
        // initiate an empty array to hold view controllers
        var controllers: [UIViewController] = []

        // adds the custom tab bar view and constraints.
        addCustomTabBarToView(items)
        
        // iterate through our views to add view controllers
        // IMPORTANT: WHEN CREATING A CUSTOM TAB BAR CONTROLLER, REMEMBER TO IMBED THEM IN A NAV CONTROLLER
        // There were issues registering cv's and other things until I embeded the views into a NavController
        for tabItem in tabItems{
            // get our view controller
            let rootViewController =  tabItem.viewController
            
            // imbed it into a navigation controller
            let navController = UINavigationController(rootViewController: rootViewController)
            navController.setNavigationBarHidden(true, animated: false)
            // add the navigation controller to our controllers
            controllers.append(navController)
        }
        
        // update our view
        self.view.layoutIfNeeded()
        
        // sent our completion paramaters for our higher function, a list of navigation controllers
        completion(controllers)
        
    }
    
    // changes our selected tab for our TabBarController
    func changeTab(tab: Int) {
            self.selectedIndex = tab
        }
    
    
    // MARK: Layout
    
    // adds the custom bar to our view where our tab bar should be
    func addCustomTabBarToView(_ items: [CustomTabItem]){
        

        // hide our built in tab bar view
        tabBar.isHidden = true
        
        
        customTabBar = CustomTabBarView(menuItems: items)
        
        // instead of creating a delegate, we set the function of out custom tab bar view to our function
        customTabBar.tabTapped = self.changeTab
        
        self.view.addSubview(customTabBar)
        customTabBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            customTabBar.widthAnchor.constraint(equalToConstant: tabBar.frame.width),
            customTabBar.heightAnchor.constraint(equalToConstant: tabBarHeight),
            customTabBar.bottomAnchor.constraint(equalTo: tabBar.bottomAnchor)
        ])
        
        tabBarLeadingConstraint = customTabBar.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor)
        tabBarLeadingConstraint.isActive = true
    
    }
    
}


// MARK: our custom enum used for creating a tab bar

 enum CustomTabItem: String, CaseIterable {
    case home = "home"
    case favorites = "heart"
    case creators = "creators"
    case discover = "discover"
    case menu = "menu"
    
     /// returns a view controller assoiciated with our enum
    var viewController: UIViewController {
            switch self {
            case .home:
                let homeVC = HomeViewController()
                return homeVC
            case .favorites:
                let blankVC = BlankViewController(); blankVC.view.backgroundColor = .white
                return blankVC
            case .creators:
                let blankVC = BlankViewController(); blankVC.view.backgroundColor = .white
                return blankVC
            case .discover:
                let blankVC = BlankViewController(); blankVC.view.backgroundColor = .white
                return blankVC
            case .menu:
                let blankVC = BlankViewController(); blankVC.view.backgroundColor = .white
                return blankVC
            }
        }
    
    /// the icon associated with our enum
    var icon: UIImage? {
        switch self {
        case .home:
            let imageString = getIconImageString(forIcon: .home, isSelected: false)
            return fetchIcon(named: imageString)
        case .favorites:
            let imageString = getIconImageString(forIcon: .favorites, isSelected: false)
            return fetchIcon(named: imageString)
        case .creators:
            let imageString = getIconImageString(forIcon: .creators, isSelected: false)
            return fetchIcon(named: imageString)
        case .discover:
            let imageString = getIconImageString(forIcon: .discover, isSelected: false)
            return fetchIcon(named: imageString)
        case .menu:
            let imageString = getIconImageString(forIcon: .menu, isSelected: false)
            return fetchIcon(named: imageString)
        }
    }
     
     
     // turns our raw value and adds "_icon" or "icon_selected"; only works if we follow naming conventions in assets
     private func getIconImageString(forIcon tab: CustomTabItem, isSelected: Bool)-> String{
         let selectedString = isSelected ? "_selected" : ""
         let iconString = "\(tab.rawValue)_icon\(selectedString)"
         return iconString
     }
     
     //  checks to make sure our icon is not null, if it is, return nil
     private func fetchIcon(named imageName:String) -> UIImage?{
         guard let image = UIImage(named: imageName) else  {
             print("NavBaseController: Error Finding Home Image Named: \(imageName)")
             return nil }
         return image
     }
     
     var selectedIcon: UIImage? {
         switch self {
         case .home:
             let imageString = getIconImageString(forIcon: .home, isSelected: true)
             return fetchIcon(named: imageString)
         case .favorites:
             let imageString = getIconImageString(forIcon: .favorites, isSelected: true)
             return fetchIcon(named: imageString)
         case .creators:
             let imageString = getIconImageString(forIcon: .creators, isSelected: true)
             return fetchIcon(named: imageString)
         case .discover:
             let imageString = getIconImageString(forIcon: .discover, isSelected: true)
             return fetchIcon(named: imageString)
         case .menu:
             let imageString = getIconImageString(forIcon: .menu, isSelected: true)
             return fetchIcon(named: imageString)
         }
     }
     
    
var displayTitle: String {
        return self.rawValue.capitalized(with: nil)
    }
    
}

