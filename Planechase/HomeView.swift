//
//  HomeView.swift
//  Planechase
//
//  Created by Max O'Brien on 20/08/14.
//  Copyright (c) 2014 Max O'Brien. All rights reserved.
//

/*
    Variable Convention: firstSecond
    Constant Convention: FirstSecond
*/

import UIKit

class HomeView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var backgroundMaskView: UIView!
    @IBOutlet weak var planarDieMaskView: UIView!
    @IBOutlet weak var planarCardView: UIView!
    @IBOutlet weak var planarCounterView: UIView!
    @IBOutlet weak var cardSelectView: UIView!
    @IBOutlet weak var cardListView: UIView!
    @IBOutlet weak var cardListTableView: UITableView!
    @IBOutlet weak var planarCounterLabel: UILabel!
    @IBOutlet weak var counterCountLabel: UILabel!
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
    @IBOutlet weak var increaseCounterButton: UIButton!
    @IBOutlet weak var decreaseCounterButton: UIButton!
    @IBOutlet weak var cardTypeControl: UISegmentedControl!
    @IBOutlet weak var phenomChanceLabel: UILabel!
    
    enum DeckDirection: Int {
        
        case NewCard = 0
        case NextCard, PreviousCard, PhenomCard, ReturnToCurrent
        
    }
    
    let GravityDirection: Float = 50
    
    var animator : UIDynamicAnimator!
    var attachmentBehavior : UIAttachmentBehavior!
    var gravityBehavior : UIGravityBehavior!
    var snapBehavior : UISnapBehavior!
    
    var order = [Int]()
    var translateFrom = CGFloat()
    var counterCount = Int()
    var cardListType = cardList
    
    var deck = CardDeck(phenom: 10)
    
    /*
        gestureBegin removes the snap behaviour of the planarCardView when it is
        touched and offsets the origin based on where it is touched.
    */
    
    func gestureBegin(location: CGPoint, _ currentView: UIView, box: CGPoint) {
        
        animator.removeBehavior(snapBehavior)
        
        let CenterOffset = UIOffsetMake(box.x - CGRectGetMidX(currentView.bounds), box.y - CGRectGetMidY(currentView.bounds))
        
        attachmentBehavior = UIAttachmentBehavior(item: currentView, offsetFromCenter: CenterOffset, attachedToAnchor: location)
        attachmentBehavior.frequency = 0
        
        animator.addBehavior(attachmentBehavior)
        
    }
    
    /*
        gestureChanged moves the planarCardView when it is dragged.
    */
    
    func gestureChanged(location: CGPoint) {
        
        attachmentBehavior.anchorPoint = location
        
    }
    
    /*
        gestureEnded enables the snap behaviour again when the planarCardView is no 
        longer touched and checks whether to change the card based on where it is at
        the point it is detached and what position the shown card is.
    */
    
    func gestureEnded( currentView: UIView, _ translation: CGPoint ) {
        
        let StandardTimeDelay = 0.5
        
        snapBehavior = UISnapBehavior(item: currentView, snapToPoint: CGPoint(x: view.center.x, y: view.center.y + 25))
        animator.removeBehavior(attachmentBehavior)
        animator.addBehavior(snapBehavior)
        
         if deck.drawnCards[deck.currentViewedCard].type == CardDeck.Card.CardType.Phenom {
            
            if translation.x < -500 {
                
                changePlane(StandardTimeDelay, -GravityDirection, DeckDirection.NewCard)
                
            } else if translation.x > 500 && deck.currentViewedCard > 0 {
                
                changePlane(StandardTimeDelay, GravityDirection, DeckDirection.PreviousCard)
                
            }
            
        } else {
        
            if translation.x < -500 && deck.currentViewedCard < deck.standardPosition - 1 {
                
                changePlane(StandardTimeDelay, -GravityDirection, DeckDirection.NextCard)
                
            } else if translation.x > 500 && deck.currentViewedCard > 0 {
                
                changePlane(StandardTimeDelay, GravityDirection, DeckDirection.PreviousCard)
                
            }
        }
        
    }
    
    /*
        handleGesture parses in the gesture states and executes them based on what their
        inputs are.
    */
    
    @IBAction func handleGesture(sender: AnyObject) {
        
        let State: UIGestureRecognizerState = sender.state
        
        switch State {
        case UIGestureRecognizerState.Began:
            gestureBegin(sender.locationInView(view), planarCardView, box: sender.locationInView(planarCardView))
        case UIGestureRecognizerState.Changed:
            gestureChanged(sender.locationInView(view))
        case UIGestureRecognizerState.Ended:
            gestureEnded(planarCardView, sender.translationInView(view))
        default:
            break // Do Nothing
        }
        
    }
    
    /*
        refreshView resets the view and sets what features are enabled based on the
        refreshed view's card type and position.
    */
    
    func refreshView() {
        
        currentPlaneButton.hidden = true
        rollDieButton.enabled = true
        increaseCounterButton.enabled = true
        decreaseCounterButton.enabled = true
        
        animator.removeAllBehaviors()
        planarCardView.center = CGPoint(x: view.center.x, y: view.center.y + 25)
        
        if deck.currentViewedCard > deck.standardCards.count - 1 {
            
            deck.shuffle()
            
        }
        
        viewDidAppear(true)
        
        if deck.currentViewedCard < deck.standardPosition - 1 {
            
            currentPlaneButton.hidden = false
            rollDieButton.enabled = false
            increaseCounterButton.enabled = false
            decreaseCounterButton.enabled = false
            
        }
        
    }
    
    /*
        changePlane changes the card based enabling specific use cases based on the 
        user's input.
    */
    
    func changePlane(timeDelay: Double, _ direction: Float, _ planeOrder: DeckDirection) {
        
        let OffScreenOffset: CGFloat = 2000
        
        var gravity = UIGravityBehavior(items: [planarCardView])
        gravity.gravityDirection = CGVectorMake(CGFloat(direction), 0)
        animator.removeAllBehaviors()
        animator.addBehavior(gravity)
        
        delay (timeDelay) {
            self.refreshView()
        }
        
        switch planeOrder {
            
        case .NewCard:
            deck.drawNewCard()
            translateFrom = OffScreenOffset
            self.deck.currentViewedCard++
            
        case .NextCard:
            deck.nextCard
            translateFrom = OffScreenOffset
            
        case .PreviousCard:
            deck.previousCard
            translateFrom = -OffScreenOffset
            
        case .PhenomCard:
            translateFrom = OffScreenOffset
            
        case .ReturnToCurrent:
            deck.currentCard
            translateFrom = OffScreenOffset
            
        }
        
    }
    
    /*
        transitionPlane animates a new card into view based a specified direction.
    */
    
    func transitionPlane(direction: CGFloat) {
        
        let Scale = CGAffineTransformMakeScale(0.5, 0.5)
        let Translate = CGAffineTransformMakeTranslation(direction, 0)
        
        planarCardView.transform = CGAffineTransformConcat(Scale, Translate)
        
        spring(0.5){
            
            let Scale = CGAffineTransformMakeScale(1, 1)
            let Translate = CGAffineTransformMakeTranslation(0, 0)
            
            self.planarCardView.transform = CGAffineTransformConcat(Scale, Translate)
            
        }
        
    }
    
    /*
        rollDieButtonDidPress initiates the roll of the planar die and executes actions
        based on its result.
    */
    
    @IBAction func rollDieButtonDidPress(sender: AnyObject) {
        
        let StandardTimeDelay = 0.5
        let SpringTimeDuration = 0.5
        
        var rollDie = numberGenerator(6)
        var dieResult = String()
        
        switch rollDie {
        case 0: dieResult = "img-sq_pd-p_180"
        case 1: dieResult = "img-sq_pd-c_180"
        default: dieResult = "img-sq_pd-b_180"
        
        }
        
        planarDieMaskView.alpha = 0
        planarDieMaskView.hidden = false
        planarDieImageView.hidden = true
        
        spring(SpringTimeDuration) {
            
            self.planarDieMaskView.alpha = 1
        
        }
        
        delay (StandardTimeDelay) {
            
            self.planarDieImageView.alpha = 0
            self.planarDieImageView.hidden = false
            self.planarDieImageView.image = UIImage(named: dieResult)
            
            spring(SpringTimeDuration) {
                
                self.planarDieImageView.alpha = 1
            
            }
            
        }
        
        delay (2.5) {
            
            spring(SpringTimeDuration) {
                
                self.planarDieMaskView.alpha = 0
                self.planarDieImageView.alpha = 0
                
            }
            
            delay (StandardTimeDelay) {
                
                self.planarDieMaskView.hidden = true
                
                if rollDie == 0 {
                    
                    self.changePlane(StandardTimeDelay, -self.GravityDirection, DeckDirection.NewCard)
                    
                }
                
            }
            
        }
        
    }
    

    
    @IBAction func reshuffleButtonDidPress(sender: AnyObject) {
        
        deck.shuffle()
        currentPlaneButton.hidden = true
        viewDidAppear(true)

    }
    
    @IBAction func phenomChanceButtonDidPress(sender: AnyObject) {
        
        phenomSliderView.hidden = false
        hideSliderButton.hidden = false
        
        let Scale = CGAffineTransformMakeScale(0.3, 0.3)
        let Translate = CGAffineTransformMakeTranslation(0, -50)
        
        phenomSliderView.transform = CGAffineTransformConcat(Scale, Translate)
        phenomSliderView.alpha = 0
        
        spring (0.5) {
            
            let Scale = CGAffineTransformMakeScale(1, 1)
            let Translate = CGAffineTransformMakeTranslation(0, 0)
            
            self.phenomSliderView.transform = CGAffineTransformConcat(Scale, Translate)
            self.phenomSliderView.alpha = 1
            
        }
        
    }
    
    @IBAction func hideSliderButtonDidPress(sender: AnyObject) {
        
        hideSliderButton.hidden = true
        
        let Scale = CGAffineTransformMakeScale(1, 1)
        let Translate = CGAffineTransformMakeTranslation(0, 0)
        
        phenomSliderView.transform = CGAffineTransformConcat(Scale, Translate)
        phenomSliderView.alpha = 1
        
        spring (0.5) {
            
            let Scale = CGAffineTransformMakeScale(0.3, 0.3)
            let Translate = CGAffineTransformMakeTranslation(0, -50)
            
            self.phenomSliderView.transform = CGAffineTransformConcat(Scale, Translate)
            self.phenomSliderView.alpha = 0
            
        }
        
    }
    
    /*
        phenomChanceSliderDidChange changes the chances phenomenoms have to appear based
        user input
    */
    
    @IBAction func phenomChanceSliderDidChange(sender: AnyObject) {
        
        var sliderValue = Int(phenomChanceSlider.value)
        
        phenomChanceLabel.text = "1 in " + "\(sliderValue)"
        
        deck.probability = sliderValue
        
        if sliderValue == 1 {
            
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
    
    @IBAction func cardTypeControlDidPress(sender: AnyObject) {
        
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
    
    
    /*
        currentPlaneButtonDidPress returns players back to the most current plane if
        they have been browsing where they have been.
    */
    
    @IBAction func currentPlaneButtonDidPress(sender: AnyObject) {
        
        let StandardTimeDelay = 0.5
        
        changePlane(StandardTimeDelay, -GravityDirection, DeckDirection.ReturnToCurrent)
        
    }
    
    func counterTracker(counterType: String) {
        
        counterCount = 0
        counterCountLabel.text = "\(counterCount)"
        
        planarCounterView.hidden = false
        planarCounterLabel.text = "\(counterType) Counters"
        
    }
    
    /*
        showCounterTracker is shown when specific cards are revealed and fills in the
        relevant name into the counter tracker label.
    */
    
    func showCounterTracker(planeName: String) {
        
        switch planeName {
            
            case "aretopolis": counterTracker("Scroll")
            case "kilnspire district": counterTracker("Charge")
            case "mount keralia": counterTracker("Pressure")
            case "naar isle": counterTracker("Flame")
            
        default: planarCounterView.hidden = true
            
        }
        
    }
    
    @IBAction func increaseCounterDidPress(sender: AnyObject) {
        
        counterCount++
        counterCountLabel.text = "\(counterCount)"
        
        
        if deck.drawnCards[deck.standardPosition - 1].name == "aretopolis" && counterCount == 10 {
            
            changePlane(0.5, -GravityDirection, DeckDirection.NewCard)
            
        }
        
            decreaseCounterButton.enabled = true
        
    }
    
    @IBAction func decreaseCounterDidPress(sender: AnyObject) {
        
        counterCount--
        counterCountLabel.text = "\(counterCount)"
        
        if counterCount == 0 {
            
            decreaseCounterButton.enabled = false
            
        }
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().idleTimerDisabled = true
        
        insertBlurView(backgroundMaskView, UIBlurEffectStyle.Dark)
        insertBlurView(planarDieMaskView, UIBlurEffectStyle.Dark)
        insertBlurView(cardSelectView, UIBlurEffectStyle.Dark)
        insertBlurView(planarCounterView, UIBlurEffectStyle.Light)
        
        animator = UIDynamicAnimator(referenceView: view)
        
        planarCardView.alpha = 0
        
        cardListTableView.separatorColor = UIColor(white: 1, alpha: 0.3)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(Bool())
        
        // Set the incoming direction of the new view based on what card will be shown next.
        transitionPlane(translateFrom)
        
        animator = UIDynamicAnimator(referenceView: view)
            
        planarImageView.image = UIImage(named: deck.drawnCards[deck.currentViewedCard].image)
        backgroundImageView.image = UIImage(named: deck.drawnCards[deck.currentViewedCard].backgroundImage)
        
        planarCardView.alpha = 1
        
        showCounterTracker(deck.drawnCards[deck.currentViewedCard].name)
        
        print(deck.currentViewedCard)
        print(deck.standardPosition)
        
    }
    
    /*
        tableView -> Int gives the table rows based on the number of items in a defined array.
    */
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cardListType.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let Cell = UITableViewCell()
        
        Cell.textLabel?.text = cardListType[indexPath.row].capitalizedString
        Cell.textLabel?.textColor = UIColor(white: 1, alpha: 0.7)
        
        Cell.backgroundColor = UIColor(white: 0, alpha: 0)
        Cell.tintColor = UIColor(white: 1, alpha: 0.7)
        
        Cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        
        return Cell
    }
    
    /*
        tableView (didSelectRowAtIndexPath) changes the image of the cardImagePreviewView to
        show the selected card.
    */
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        cardPreviewImageView.image = UIImage(named: cardListType[indexPath.row] + ".hq")
        
    }
    
}
