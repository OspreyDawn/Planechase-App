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
    @IBOutlet weak var cardSelectView: UIView!
    @IBOutlet weak var cardListView: UIView!
    @IBOutlet weak var cardPreviewImageView: UIImageView!
    @IBOutlet weak var planarImageView: UIImageView!
    @IBOutlet weak var planarDieImageView: UIImageView!
    @IBOutlet weak var phenomSliderView: UIView!
    @IBOutlet weak var phenomSliderImageView: UIImageView!
    @IBOutlet weak var reshuffleButton: UIButton!
    @IBOutlet weak var phenomChanceButton: UIButton!
    @IBOutlet weak var phenomChanceSlider: UISlider!
    @IBOutlet weak var rollDieButton: UIButton!
    @IBOutlet weak var currentPlaneButton: UIButton!
    @IBOutlet weak var cardSelectButton: UIButton!
    @IBOutlet weak var cardSelectDoneButton: UIButton!
    @IBOutlet weak var hideSliderButton: UIButton!
    @IBOutlet weak var phenomChanceLabel: UILabel!
    
    var animator : UIDynamicAnimator!
    var attachmentBehavior : UIAttachmentBehavior!
    var gravityBehavior : UIGravityBehavior!
    var snapBehavior : UISnapBehavior!
    
    var number = 0
    var order = [Int]()
    var translateFrom = CGFloat()
    var phenomProbability = Int()
    var isPhenom = 1
    var currentPlane = 0
    var runPhenom = Bool()
    
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
            
            snapBehavior = UISnapBehavior(item: myView, snapToPoint: CGPoint(x: view.center.x, y: view.center.y + 25))
            animator.addBehavior(snapBehavior)
            
            let translation = sender.translationInView(view)
            
            if isPhenom >= 1 {
                
                if translation.x < -500 && number < currentPlane {
                    
                    changePlane(0.5, direction: -50, planeOrder: 0)
                    
                } else if translation.x > 500 && number > 0 {
                    
                    changePlane(0.5, direction: 50, planeOrder: 1)
                    
                }
                
            } else if isPhenom == 0 && translation.x < -500 {
                
                changePlane(0.5, direction: -50, planeOrder: 0)
                
                isPhenom = 1
                currentPlane++
                
            }
        }
        
    }
    
    func refreshView() {
        
        currentPlaneButton.hidden = true
        
        animator.removeAllBehaviors()
        planarCardView.center = CGPoint(x: view.center.x, y: view.center.y + 25)
        
        if number > cardList.count - 1 {
            
            order = shuffleArray(&order)
            number = 0
        }
        
        viewDidAppear(true)
        
        if number < currentPlane {
            
            currentPlaneButton.hidden = false
            
        }
        
    }
    
    func changePlane(timeDelay: Double, direction: CGFloat, planeOrder: Int) {
        
        var planeTo = planeOrder
        
        animator.removeAllBehaviors()
        
        var gravity = UIGravityBehavior(items: [planarCardView])
        gravity.gravityDirection = CGVectorMake(direction, 0)
        animator.addBehavior(gravity)
        
        delay (timeDelay) {
            self.refreshView()
        }
        
        if planeTo == 0 {
            
            number++
            translateFrom = 2000
            
            
        } else if planeTo == 1 {
            
            number--
            translateFrom = -2000
            
        } else if planeTo == 2 {
            
            translateFrom = 2000
            
        } else if planeTo == 3 {
            
            number = currentPlane
            translateFrom = 2000
            
        }
        
    }
    
    func transitionPlane(direction: CGFloat) {
        
        let scale = CGAffineTransformMakeScale(0.5, 0.5)
        let translate = CGAffineTransformMakeTranslation(direction, 0)
        
        planarCardView.transform = CGAffineTransformConcat(scale, translate)
        
        spring(0.5){
            
            let scale = CGAffineTransformMakeScale(1, 1)
            let translate = CGAffineTransformMakeTranslation(0, 0)
            
            self.planarCardView.transform = CGAffineTransformConcat(scale, translate)
            
        }
        
    }
    
    @IBAction func rollDieButtonDidPress(sender: AnyObject) {
        
        var rollDie = numberGenerator(6)
        var dieResult = String()
        
        if rollDie >= 2 {
        
            dieResult = "img-sq_pd-b_180"
        
        } else if rollDie == 1 {
        
            dieResult = "img-sq_pd-c_180"
        
        } else if rollDie == 0 {
        
            dieResult = "img-sq_pd-p_180"
        
        }
        
        planarDieMaskView.alpha = 0
        planarDieMaskView.hidden = false
        
        planarDieImageView.hidden = true
        
        spring(0.5) {
            
            self.planarDieMaskView.alpha = 1
        
        }
        
        delay (0.5) {
            
            self.planarDieImageView.alpha = 0
            self.planarDieImageView.hidden = false
            self.planarDieImageView.image = UIImage(named: dieResult)
            
            spring(0.5) {
                self.planarDieImageView.alpha = 1
            }
            
        }
        
        delay (2.5) {
            
            spring(0.5) {
                
                self.planarDieMaskView.alpha = 0
                self.planarDieImageView.alpha = 0
                
            }
            
            delay (0.5) {
                
                self.planarDieMaskView.hidden = true
                
                if rollDie == 0 {
                    
                    self.rollPlaneswalk(self.runPhenom)
                    
                }
                
            }
            
        }
        
    }
    
    func rollPlaneswalk(phenomOn: Bool) {
        
        var phenomCheck = phenomOn
        
        if phenomCheck == true {
            
            isPhenom = numberGenerator(self.phenomProbability)
            
            if isPhenom >= 1 {
                
                changePlane(0.3, direction: -50, planeOrder: 0)
                currentPlane++
                
            } else {
                
                changePlane(0.3, direction: -50, planeOrder: 2)
                
            }
            
        } else {
            
            changePlane(0.3, direction: -50, planeOrder: 0)
            currentPlane++
            isPhenom = 1
            
        }
        
    }
    
    func shuffleCards() {
        
        order = shuffleArray(&order)
        number = 0
        currentPlane = 0
        isPhenom = 1
        currentPlaneButton.hidden = true
        viewDidAppear(true)
        
    }
    
    @IBAction func reshuffleButtonDidPress(sender: AnyObject) {
        
        shuffleCards()

    }
    
    @IBAction func phenomChanceButtonDidPress(sender: AnyObject) {
        
        phenomSliderView.hidden = false
        hideSliderButton.hidden = false
        
        let scale = CGAffineTransformMakeScale(0.3, 0.3)
        let translate = CGAffineTransformMakeTranslation(0, -50)
        
        phenomSliderView.transform = CGAffineTransformConcat(scale, translate)
        phenomSliderView.alpha = 0
        
        spring (0.5) {
            
            let scale = CGAffineTransformMakeScale(1, 1)
            let translate = CGAffineTransformMakeTranslation(0, 0)
            
            self.phenomSliderView.transform = CGAffineTransformConcat(scale, translate)
            self.phenomSliderView.alpha = 1
            
        }
        
    }
    
    @IBAction func hideSliderButtonDidPress(sender: AnyObject) {
        
        hideSliderButton.hidden = true
        
        let scale = CGAffineTransformMakeScale(1, 1)
        let translate = CGAffineTransformMakeTranslation(0, 0)
        
        phenomSliderView.transform = CGAffineTransformConcat(scale, translate)
        phenomSliderView.alpha = 1
        
        spring (0.5) {
            
            let scale = CGAffineTransformMakeScale(0.3, 0.3)
            let translate = CGAffineTransformMakeTranslation(0, -50)
            
            self.phenomSliderView.transform = CGAffineTransformConcat(scale, translate)
            self.phenomSliderView.alpha = 0
            
        }
        
    }
    
    @IBAction func phenomChanceSliderDidChange(sender: AnyObject) {
        
        var sliderValue = Int(phenomChanceSlider.value)
        
        runPhenom = true
        
        phenomChanceLabel.text = "1 in " + "\(sliderValue)"
        
        phenomProbability = sliderValue
        
        if sliderValue == 1 {
            
            runPhenom = false
            
            phenomChanceLabel.text = "Off"
            
        }
    }
    
    @IBAction func cardSelectButtonDidPress(sender: AnyObject) {
        
        cardSelectView.hidden = false
        cardSelectView.alpha = 0
        cardListView.transform = CGAffineTransformMakeTranslation(-320, 0)
        cardPreviewImageView.transform = CGAffineTransformMakeScale(0.3, 0.3)
        
        spring(0.5) {
            
            self.cardSelectView.alpha = 1
            self.cardListView.transform = CGAffineTransformMakeTranslation(0, 0)
            self.cardPreviewImageView.transform = CGAffineTransformMakeScale(1, 1)
            
        }
        
    }
    
    @IBAction func cardSelectDoneDidPress(sender: AnyObject) {
        
        cardSelectView.alpha = 1
        cardListView.transform = CGAffineTransformMakeTranslation(0, 0)
        cardPreviewImageView.transform = CGAffineTransformMakeScale(1, 1)
        
        spring(0.5) {
            
            self.cardSelectView.alpha = 0
            self.cardListView.transform = CGAffineTransformMakeTranslation(-320, 0)
            self.cardPreviewImageView.transform = CGAffineTransformMakeScale(0.3, 0.3)
            
        }
        
    }
    
    @IBAction func currentPlaneButtonDidPress(sender: AnyObject) {
        
        changePlane(0.5, direction: -50, planeOrder: 3)
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().idleTimerDisabled = true
        
        order = cardOrder(cardCount())
        
        insertBlurView(backgroundMaskView, UIBlurEffectStyle.Dark)
        insertBlurView(planarDieMaskView, UIBlurEffectStyle.Dark)
        insertBlurView(cardSelectView, UIBlurEffectStyle.Dark)
        
        animator = UIDynamicAnimator(referenceView: view)
        
        planarCardView.alpha = 0
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(Bool())
        
        transitionPlane(translateFrom)
        
        animator = UIDynamicAnimator(referenceView: view)
        
        if isPhenom == 0 {
            
            var phenomSelect = numberGenerator(phenomList.count)
            
            planarImageView.image = UIImage(named: getCard(phenomList)[phenomSelect] + ".hq")
            backgroundImageView.image = UIImage(named: getCard(phenomList)[phenomSelect] + ".crop.hq")
            
        } else {
            
            planarImageView.image = UIImage(named: getCardName(order[number]) + ".hq")
            backgroundImageView.image = UIImage(named: getCardName(order[number]) + ".crop.hq")
            
        }
        
        planarCardView.alpha = 1
        
    }
    
}
