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
    @IBOutlet weak var reshuffleButton: UIButton!
    @IBOutlet weak var gameModeButton: UIButton!
    @IBOutlet weak var rollDieButton: UIButton!
    @IBOutlet weak var currentPlaneButton: UIButton!
    @IBOutlet weak var cardSelectButton: UIButton!
    @IBOutlet weak var cardSelectDoneButton: UIButton!
    @IBOutlet weak var increaseCounterButton: UIButton!
    @IBOutlet weak var decreaseCounterButton: UIButton!
    @IBOutlet weak var cardTypeControl: UISegmentedControl!
    
    enum DeckDirection: Int {
        
        case NewCard = 0
        case NextCard, PreviousCard, PhenomCard, ReturnToCurrent
        
    }
    
    let GravityDirection: Float = 50
    
    var animator : UIDynamicAnimator!
    var attachmentBehavior : UIAttachmentBehavior!
    var gravityBehavior : UIGravityBehavior!
    var snapBehavior : UISnapBehavior!
    var translateFrom = CGFloat()
    var counterCount = Int()
    var deck = CardDeck()
    var cardListType = [Card]()
    
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
        let ScreenOffset: CGFloat = 500
        
        snapBehavior = UISnapBehavior(item: currentView, snapToPoint: CGPoint(x: view.center.x, y: view.center.y + 25))
        animator.removeBehavior(attachmentBehavior)
        animator.addBehavior(snapBehavior)
        
         if deck.drawnCards[deck.currentViewedCard].type == Card.CardType.Phenom && deck.currentViewedCard == deck.drawnCards.count - 1 {
            
            if translation.x < -ScreenOffset {
                
                changePlane(StandardTimeDelay, -GravityDirection, DeckDirection.NewCard)
                
            } else if translation.x > ScreenOffset && deck.currentViewedCard > 0 {
                
                changePlane(StandardTimeDelay, GravityDirection, DeckDirection.PreviousCard)
                
            }
            
        } else {
        
            if translation.x < -ScreenOffset && deck.currentViewedCard < deck.standardPosition - 1 {
                
                changePlane(StandardTimeDelay, -GravityDirection, DeckDirection.NextCard)
                
            } else if translation.x > ScreenOffset && deck.currentViewedCard > 0 {
                
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
        
        rollDieButton.enabled = false
        
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
            
            delay (0.3) {
                
                self.planarDieMaskView.hidden = true
                self.rollDieButton.enabled = true
                
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
    
    @IBAction func gameModeButtonDidPress(sender: AnyObject) {
        
        var modeAlertView = UIAlertView()
        
        modeAlertView.title = "Eternities Map"
        modeAlertView.message = "Game Mode Coming Soon"
        modeAlertView.addButtonWithTitle("Dismiss")
        
        modeAlertView.show()
        
    }
    
    @IBAction func cardSelectButtonDidPress(sender: AnyObject) {
        
        //cardListTableView.reloadData()
        
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
        
        switch cardTypeControl.selectedSegmentIndex {
        case 0:
            cardListType = deck.standardCards
            cardListTableView.reloadData()
        case 1:
            cardListType = deck.phenomCards
            cardListTableView.reloadData()
        default:
            break
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
        
        cardListType = deck.standardCards
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
        
    }
    
    /*
        tableView -> Int gives the table rows based on the number of items in a defined array.
    */
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cardListType.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let Cell = UITableViewCell()
        let CheckButton = UIButton(frame: CGRectMake(0, 0, 25, 25))
        
        var CheckButtonImage = UIImage()
        var cellSelectedColorView = UIView()
        var cardState = cardListType[indexPath.row].included
        
        switch cardState {
        case true:
            CheckButtonImage = UIImage(named: "icon-included")
            CheckButton.selected = false
        case false:
            CheckButtonImage = UIImage(named: "icon-excluded")
            CheckButton.selected = true
        default:
            break
        }
        
        CheckButton.setImage(CheckButtonImage, forState: UIControlState.Normal)
        CheckButton.backgroundColor = UIColor.clearColor()
        CheckButton.addTarget(self, action: "accessoryButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        CheckButton.tag = indexPath.row
        //CheckButton.imageView?.contentMode = UIViewContentMode.Center
        
        cellSelectedColorView.backgroundColor = UIColor(red: 0, green: 0.569, blue: 0.998, alpha: 1)
        
        Cell.textLabel?.text = cardListType[indexPath.row].name.capitalizedString
        Cell.textLabel?.textColor = UIColor(white: 1, alpha: 0.7)
        Cell.tintColor = UIColor(white: 1, alpha: 0.7)
        Cell.backgroundColor = UIColor.clearColor()
        Cell.selectedBackgroundView = cellSelectedColorView
        
        Cell.accessoryView = CheckButton
        
        return Cell
    }
    
    func accessoryButtonTapped(sender: UIButton!) {
        
        sender.selected = !sender.selected
        
        switch sender.selected {
        case true:
            cardListType[sender.tag].included = false
        case false:
            cardListType[sender.tag].included = true
        default:
            break
        }
        
        cardListTableView.reloadData()
    }
    
    /*
        tableView (didSelectRowAtIndexPath) changes the image of the cardImagePreviewView to
        show the selected card.
    */
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        cardPreviewImageView.image = UIImage(named: cardListType[indexPath.row].image + ".hq")
        
    }
    
}
