//
//  ViewController.swift
//  MusderCards
//
//  Created by Borisov Timofey on 16/07/21.
//  Copyright © 2021 Borisov Timofey. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD


class HomeController: UIViewController, SettingsControllerDelegate, LoginControllerDelegate, CardViewDelegate {
    
    let topStackView = TopNavigationStackView()
    let cardsDeckView = UIView()
    let bottomControls = HomeBottomControlsStackView()
    
    var cardViewModels = [CardViewModel]() // Empty array

    override func viewDidLoad() {
        super.viewDidLoad()
        
        topStackView.settingsButton.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
        bottomControls.refreshButton.addTarget(self, action: #selector(handleRefresh), for: .touchUpInside)
        bottomControls.likeButton.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        bottomControls.dislikeButton.addTarget(self, action: #selector(handleDislike), for: .touchUpInside)
        
        setupLayout()
        fetchCurrentUser()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser == nil {
            let registrationController = RegistrationController()
            registrationController.delegate = self
            let navController = UINavigationController(rootViewController: registrationController)
            present(navController, animated: true)
        }
    }
    
    func didFinishLoggingIn() {
        fetchCurrentUser()
    }
    
    fileprivate var user: User?
    
    fileprivate func fetchCurrentUser() {
        
        cardsDeckView.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        
        Firestore.firestore().fetchCurrentUser { (user, err) in
            if let err = err {
                print(err)
                return
            }
            self.user = user
            
//            self.fetchSwipes()
            
            self.fetchUsersFromFirestore()
        }
    }
    
//    var swipes = [String: Int]()
//
//    fileprivate func fetchSwipes() {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        Firestore.firestore().collection("swipes").document(uid).getDocument { (snapshot, err) in
//            if let err = err {
//                print(err)
//                return
//            }
//            print("Swipes:", snapshot?.data() ?? "")
//            guard let data = snapshot?.data() as? [String: Int] else { return }
//            self.swipes = data
//            self.fetchUsersFromFirestore()
//        }
//    }
    
    @objc fileprivate func handleRefresh () {
        cardsDeckView.subviews.forEach({$0.removeFromSuperview()})
        fetchUsersFromFirestore()
    }
    
    var lastFetchedUser: User?
    
    fileprivate func fetchUsersFromFirestore() {
        let minAge = user?.minSeekingAge ?? SettingsController.defaultMinSeekingAge
        let maxAge = user?.maxSeekingAge ?? SettingsController.defaultMaxSeekingAge
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Обновление списка людей..."
        hud.show(in: view)
        // Pagination to page through 2 users at a time
        
        let query = Firestore.firestore().collection("users").whereField("age", isGreaterThanOrEqualTo: minAge).whereField("age", isLessThanOrEqualTo: maxAge)
        topCardView = nil
        query.getDocuments { (snapshot, err) in
            hud.dismiss(animated: true)
            if let err = err {
                print(err)
                return
            }
            
            //Set up the nextCardView relationship for all cards
            
            var previousCardView: CardView?
            
            snapshot?.documents.forEach({ (documentSnapshot) in
                let userDictionary = documentSnapshot.data()
                let user = User(dictionary: userDictionary)
                
                let isNotCurrentUser = user.uid != Auth.auth().currentUser?.uid
                // TODO: -Change this back to normal
//                let hasNotSwipedBefore = self.swipes[user.uid!] == nil
                let hasNotSwipedBefore = true
                
                if isNotCurrentUser && hasNotSwipedBefore{
                    self.cardViewModels.append(user.toCardViewModel())
                    self.lastFetchedUser = user
                    let cardView = self.setupCardFromUser(user: user)
                    
                    previousCardView?.nextCardView = cardView
                    previousCardView = cardView
                    
                    if self.topCardView == nil {
                        self.topCardView = cardView
                    }
                }
                
            })
        }
    }
    
    var topCardView: CardView?
    
    @objc func handleLike() {
        
        performSwipeAnimation(translation: 700, angle: 15)
    }
    
    @objc func handleDislike() {
       
        performSwipeAnimation(translation: -700, angle: -15)
    }
    
        
    
    
    
    fileprivate func performSwipeAnimation(translation: CGFloat, angle: CGFloat) {
        let duration = 0.4
        
        let translationAnimation = CABasicAnimation(keyPath: "position.x")
        translationAnimation.toValue = translation
        translationAnimation.duration = duration
        translationAnimation.fillMode = .forwards
        translationAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        translationAnimation.isRemovedOnCompletion = false
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.duration = duration
        rotationAnimation.toValue = angle * CGFloat.pi/180
        
        let cardView = topCardView
        topCardView = cardView?.nextCardView
        
        CATransaction.setCompletionBlock {
            cardView?.removeFromSuperview()
        }
        
        cardView?.layer.add(translationAnimation, forKey: "translation")
        cardView?.layer.add(rotationAnimation, forKey: "rotation")
        
        CATransaction.commit()
    }
    
    func didRemoveCard(cardView: CardView) {
        self.topCardView?.removeFromSuperview()
        self.topCardView = self.topCardView?.nextCardView
    }
    
    fileprivate func setupCardFromUser(user: User) -> CardView {
        let cardView = CardView(frame: .zero)
        cardView.delegate = self
        cardView.cardViewModel = user.toCardViewModel()
        cardsDeckView.addSubview(cardView)
        cardsDeckView.sendSubviewToBack(cardView)
        cardView.fillSuperview()
        return cardView
    }
    
    func didTapMoreInfo(cardViewModel: CardViewModel) {
        let userDetailsController = UserDetailsController()
        userDetailsController.cardViewModel = cardViewModel
        present(userDetailsController, animated: true)
    }
    
    @objc func handleSettings() {
        let settingsController = SettingsController()
        settingsController.delegate = self
        let navController = UINavigationController(rootViewController: settingsController)
        present(navController, animated: true)
    }
    
    func didSaveSettings() {
        fetchCurrentUser()
    }
    
    fileprivate func setupFirestoreUserCards() {
        cardViewModels.forEach { (cardViewModel) in
            let cardView = CardView(frame: .zero)
            
            cardView.cardViewModel = cardViewModel
            
            cardsDeckView.addSubview(cardView)
            cardView.fillSuperview()
        }
    }
    
    //MARK:- Fileprivate
    fileprivate func setupLayout() {
        navigationController?.isNavigationBarHidden = true
        
        view.backgroundColor = .white
        let overallStackView = UIStackView(arrangedSubviews: [topStackView, cardsDeckView, bottomControls])
        overallStackView.axis = .vertical
        
        view.addSubview(overallStackView)
        overallStackView.frame = .init(x: 0, y: 0, width: 300, height: 200)
        overallStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor)
        overallStackView.isLayoutMarginsRelativeArrangement = true
        overallStackView.layoutMargins = .init(top: 0, left: 12, bottom: 0, right: 12)
        
        overallStackView.bringSubviewToFront(cardsDeckView)
    }
}

