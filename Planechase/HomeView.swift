//
//  HomeView.swift
//  Planechase
//
//  Created by Max O'Brien on 20/08/14.
//  Copyright (c) 2014 Max O'Brien. All rights reserved.
//

import UIKit

class HomeView: UIViewController {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var backgroundMaskView: UIView!
    @IBOutlet weak var planarDieMaskView: UIView!
    @IBOutlet weak var planarCardView: UIView!
    @IBOutlet weak var planarImageView: UIImageView!
    @IBOutlet weak var planarDieImageVIew: UIImageView!
    @IBOutlet weak var reshuffleButton: UIButton!
    @IBOutlet weak var rollDieButton: UIButton!
    
    var animator : UIDynamicAnimator!
    var attachmentBehavior : UIAttachmentBehavior!
    var gravityBehavior : UIGravityBehavior!
    var snapBehavior : UISnapBehavior!
    
    var number = 0
    var order = [Int]()
    var phenomProbability = 10
    var isPhenom = 1
    
    @IBAction func handleGesture(sender: AnyObject) {
        
        let location = sender.locationInView(view)
        let myView = planarCardView
        let boxLocation = sender.locationInView(planarCardView)
        
        if sender.state == UIGestureRecognizerState.Began {
            
            animator.removeBehavior(snapBehavior)
            
            let centerOffset = UIOffsetMake(boxLocation.x - CGRectGetMidX(myView.bounds), boxLocation.y - CGRectGetMidY(myView.bounds))
            
            attachmentBehavior = UIAttachmentBehavior(item: myView, offsetFromCenter: centerOffset, attachedToAnchor: location)
            attachmentBehavior.frequency = 0
            
            animator.addBehavior(attachmentBehavior)
            
        }
        else if sender.state == UIGestureRecognizerState.Changed {
            attachmentBehavior.anchorPoint = location
        }
        else if sender.state == UIGestureRecognizerState.Ended {
            
            animator.removeBehavior(attachmentBehavior)
            
            snapBehavior = UISnapBehavior(item: myView, snapToPoint: view.center)
            animator.addBehavior(snapBehavior)
            
            let translation = sender.translationInView(view)
            if translation.x < -500 {
                
                animator.removeAllBehaviors()
                
                var gravity = UIGravityBehavior(items: [planarCardView])
                gravity.gravityDirection = CGVectorMake(-50, 0)
                animator.addBehavior(gravity)
                
                delay (0.3) {
                    self.refreshView()
                }
            }
        }
        
    }
    
    func refreshView() {
        
        isPhenom = phenomGenerator(phenomProbability)
        
        if isPhenom >= 1 {
            
            number++
            
        }
        
        if number > cardList.count - 1 {
            
            order = shuffleArray(&order)
            number = 0
        }
        
        animator.removeAllBehaviors()
        planarCardView.center = self.view.center
        
        viewDidAppear(true)
        
    }
    
    @IBAction func rollDieButtonDidPress(sender: AnyObject) {
        
        planarDieMaskView.alpha = 0
        planarDieMaskView.hidden = false
        
        planarDieImageVIew.hidden = true
        
        spring(0.5) {
            
            self.planarDieMaskView.alpha = 1
        
        }
        
        delay (0.5) {
            
            self.planarDieImageVIew.alpha = 0
            self.planarDieImageVIew.hidden = false
            self.planarDieImageVIew.image = UIImage(named: dieResult())
            
            spring(0.5) {
                self.planarDieImageVIew.alpha = 1
            }
            
        }
        
        delay (2.5) {
            
            spring(0.5) {
                
                self.planarDieMaskView.alpha = 0
                
            }
            
            delay (0.5) {
                
                self.planarDieMaskView.hidden = true
            }
            
        }
        
    }
    
    @IBAction func reshuffleButtonDidPress(sender: AnyObject) {
        
        order = shuffleArray(&order)
        number = 0
        isPhenom = 1
        viewDidAppear(true)
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        order = cardOrder(cardCount())
        
        insertBlurView(backgroundMaskView, UIBlurEffectStyle.Dark)
        insertBlurView(planarDieMaskView, UIBlurEffectStyle.Dark)
        
        animator = UIDynamicAnimator(referenceView: view)
        
        planarCardView.alpha = 0
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(Bool())
        
        let scale = CGAffineTransformMakeScale(0.5, 0.5)
        let translate = CGAffineTransformMakeTranslation(2000, 0)
        
        planarCardView.transform = CGAffineTransformConcat(scale, translate)
        
        spring(0.5){
            
            let scale = CGAffineTransformMakeScale(1, 1)
            let translate = CGAffineTransformMakeTranslation(0, 0)
            
            self.planarCardView.transform = CGAffineTransformConcat(scale, translate)
            
        }
        
        animator = UIDynamicAnimator(referenceView: view)
        
        if isPhenom == 0 {
            
            var phenomSelect = phenomGenerator(phenomList.count)
            
            planarImageView.image = UIImage(named: getCard(phenomList)[phenomSelect] + ".hq")
            backgroundImageView.image = UIImage(named: getCard(phenomList)[phenomSelect] + ".crop.hq")
            
        } else {
            
            planarImageView.image = UIImage(named: getCardName(order[number]) + ".hq")
            backgroundImageView.image = UIImage(named: getCardName(order[number]) + ".crop.hq")
            
        }
        
        planarCardView.alpha = 1
        
    }
    
}
