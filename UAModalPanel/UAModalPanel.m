//
//  UACategoryDetailsViewController.m
//  Ambiance
//
//  Created by Matt Coneybeare on 3/6/10.
//  Copyright 2010 Urban Apps LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "UAModalPanel.h"
#import "UARoundedRectView.h"
#import "BarrettUseful.h"

#define DEFAULT_MARGIN              20.0f
#define DEFAULT_BACKGROUND_COLOR    [UIColor colorWithWhite:0.0 alpha:0.8]
#define DEFAULT_CORNER_RADIUS       4.0f
#define DEFAULT_BORDER_WIDTH        1.5f
#define DEFAULT_BORDER_COLOR        [UIColor whiteColor]
#define DEFAULT_BOUNCE              YES
#define DEFAULT_KEYBOARD_MOVE       YES
#define DEFAULT_SIZE_TO_CONTENT     NO

@interface UAModalPanel () <UIGestureRecognizerDelegate>
@end

@implementation UAModalPanel

@synthesize roundedRect, closeButton, delegate, contentView, contentContainer;
@synthesize innerMargin, outerMargin, cornerRadius, borderWidth, borderColor, contentColor, shouldBounce, shouldMoveForKeyboard, sizeToContent, tapOutsideToClose;
@synthesize onClosePressed;

- (void)calculateInnerFrame {
    //adjust the popup frame here for iPad if it is too big.
    innerFrame = self.frame;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self calculateInnerFrame];
        delegate = nil;
        roundedRect = nil;
        closeButton = nil;
        contentView = nil;
        startEndPoint = CGPointZero;
        
        outerMargin = DEFAULT_MARGIN;
        innerMargin = DEFAULT_MARGIN;
        cornerRadius = DEFAULT_CORNER_RADIUS;
        borderWidth = DEFAULT_BORDER_WIDTH;
        borderColor = [DEFAULT_BORDER_COLOR retain];
        contentColor = [DEFAULT_BACKGROUND_COLOR retain];
        shouldBounce = DEFAULT_BOUNCE;
        shouldMoveForKeyboard = DEFAULT_KEYBOARD_MOVE;
        sizeToContent = DEFAULT_SIZE_TO_CONTENT;
        self.tapOutsideToClose = NO;
        
        self.animationTimeScale = 1.0;
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.autoresizesSubviews = YES;
        
        self.contentContainer = [[[UIView alloc] initWithFrame:self.bounds] autorelease];
        self.contentContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.contentContainer.autoresizesSubviews = YES;
        [self addSubview:self.contentContainer];
        
        [self setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.5]]; // Fixed, the bacground mask.
        
        //      self.roundedRect.hidden = NO;  // init.
        //      self.closeButton.hidden = NO; // init.
        
        [self.contentView setBackgroundColor:[UIColor clearColor]];
        self.delegate = nil;
        
        
    }
    return self;
}

- (void)dealloc {
    self.roundedRect = nil;
    self.closeButton = nil;
    self.contentContainer = nil;
    self.borderColor = nil;
    self.contentColor = nil;
    delegate = nil;
    [super dealloc];
}

#pragma mark - Accessors

- (void)setCornerRadius:(CGFloat)newRadius {
    cornerRadius = newRadius;
    self.roundedRect.layer.cornerRadius = cornerRadius;
}
- (void)setBorderWidth:(CGFloat)newWidth {
    borderWidth = newWidth;
    self.roundedRect.layer.borderWidth = borderWidth;
}
- (void)setBorderColor:(UIColor *)newColor {
    [newColor retain];
    [borderColor release];
    borderColor = newColor;
    
    self.roundedRect.layer.borderColor = [borderColor CGColor];
}
- (void)setContentColor:(UIColor *)newColor {
    [newColor retain];
    [contentColor release];
    contentColor = newColor;
    
    self.roundedRect.backgroundColor = contentColor;
}

- (UIView *)roundedRect {
    if (!roundedRect) {
        self.roundedRect = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        roundedRect.layer.masksToBounds = YES;
        roundedRect.backgroundColor = self.contentColor;
        roundedRect.layer.borderColor = [self.borderColor CGColor];
        roundedRect.layer.borderWidth = self.borderWidth;
        roundedRect.layer.cornerRadius = self.cornerRadius;
        
        [self.contentContainer insertSubview:roundedRect atIndex:0];
    }
    return roundedRect;
}
- (UIButton*)closeButton {
    if (!closeButton) {
        self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.closeButton setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
        [self.closeButton setFrame:CGRectMake(0, 0, 44, 44)];
        self.closeButton.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.closeButton.layer.shadowOffset = CGSizeMake(0,4);
        self.closeButton.layer.shadowOpacity = 0.3;
        
        [closeButton addTarget:self action:@selector(closePressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentContainer insertSubview:closeButton aboveSubview:self.roundedRect];
    }
    return closeButton;
}
- (UIView *)contentView {
    if (!contentView) {
        self.contentView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.contentView.autoresizesSubviews = YES;
        [self.contentContainer insertSubview:contentView belowSubview:self.closeButton];
    }
    return contentView;
}

- (CGRect)roundedRectFrame {
    [self calculateInnerFrame];
    CGFloat x = (self.frame.origin.x + floor((self.frame.size.width - innerFrame.size.width)/2));
    CGFloat y = (self.frame.origin.y + floor((self.frame.size.height - innerFrame.size.height)/2));
    return CGRectMake(x + self.outerMargin,
                      y + self.outerMargin,
                      innerFrame.size.width - 2*self.outerMargin,
                      innerFrame.size.height - 2*self.outerMargin);
}

- (CGRect)closeButtonFrame {
    CGRect f = self.roundedRect.frame;
    return CGRectMake(f.origin.x - floor(closeButton.frame.size.width*0.5),
                      f.origin.y - floor(closeButton.frame.size.height*0.5),
                      closeButton.frame.size.width,
                      closeButton.frame.size.height);
}

- (CGRect)contentViewFrame {
    CGRect rect = CGRectInset([self roundedRectFrame], self.innerMargin, self.innerMargin);
    return rect;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.sizeToContent) {
        contentView.center = self.center;
        roundedRect.bounds = CGRectInset(contentView.frame, -self.innerMargin, -self.innerMargin);
        roundedRect.center = self.center;
    }
    else {
        self.roundedRect.frame = [self roundedRectFrame];
        self.contentView.frame = [self contentViewFrame];
    }
    
    self.closeButton.frame = [self closeButtonFrame];
    
    //  DebugLog(@"roundedRect: %@", NSStringFromCGRect([self _roundedRectFrame]));
    //  DebugLog(@"contentView: %@", NSStringFromCGRect([self _contentViewFrame]));
}

- (void)closePressed:(id)sender {
    //What now?
    if (delegate && [delegate respondsToSelector:@selector(removeModalView)]) {
        [delegate performSelector:@selector(removeModalView)];
    }
    
    if (self.onClosePressed)
        self.onClosePressed(self);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (CGRectContainsPoint(roundedRect.frame, [touch locationInView:self])){
        return NO;
    }
    return YES;
}

- (void)tapHandler:(UITapGestureRecognizer*)gesture {
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        if (
            CGRectContainsPoint(closeButton.frame, [gesture locationInView:self]) ||
            (!CGRectContainsPoint(roundedRect.frame, [gesture locationInView:self]) && self.tapOutsideToClose)
            
            ) {
            [self closePressed:self.closeButton];
        }
    }
}

- (void)showAnimationStarting {};       //subcalsses override
- (void)showAnimationPart1Finished {};  //subcalsses override
- (void)showAnimationPart2Finished {};  //subcalsses override
- (void)showAnimationPart3Finished {};  //subcalsses override
- (void)showAnimationFinished { if (self.didFinishShowAnimation) { self.didFinishShowAnimation(self); } };      //subcalsses override
- (void)show {
    [self showAnimationStarting];
    self.alpha = 0.0;
    self.contentContainer.transform = CGAffineTransformMakeScale(0.00001, 0.00001);
    
    if (touchOutside) {
        [self removeGestureRecognizer:touchOutside];
        touchOutside = nil;
    }
    
    if (self.tapOutsideToClose) {
        touchOutside = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
        touchOutside.delegate = self;
        [self addGestureRecognizer:touchOutside];
    }
    
    if (self.shouldMoveForKeyboard) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardDidShow:)
                                                     name:UIKeyboardDidShowNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
    }
    
    void (^animationBlock)(BOOL) = ^(BOOL finished) {
        [self showAnimationPart1Finished];
        
        // Wait one second and then fade in the view
        [UIView animateWithDuration:0.1 * self.animationTimeScale
                         animations:^{
                             self.contentContainer.transform = CGAffineTransformMakeScale(0.95, 0.95);
                         }
                         completion:^(BOOL finished){
                             [self showAnimationPart2Finished];
                             // Wait one second and then fade in the view
                             [UIView animateWithDuration:0.1 * self.animationTimeScale
                                              animations:^{
                                                  self.contentContainer.transform = CGAffineTransformMakeScale(1.02, 1.02);
                                              }
                                              completion:^(BOOL finished){
                                                  [self showAnimationPart3Finished];
                                                  // Wait one second and then fade in the view
                                                  [UIView animateWithDuration:0.1 * self.animationTimeScale
                                                                   animations:^{
                                                                       self.contentContainer.transform = CGAffineTransformIdentity;
                                                                   }
                                                                   completion:^(BOOL finished){
                                                                       [self showAnimationFinished];
                                                                   }];
                                              }];
                         }];
    };
    
    // Show the view right away
    [UIView animateWithDuration:0.3 * self.animationTimeScale
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.alpha = 1.0;
                         self.contentContainer.center = self.center;
                         self.contentContainer.transform = CGAffineTransformMakeScale((shouldBounce ? 1.05 : 1.0), (shouldBounce ? 1.05 : 1.0));
                     }
                     completion:(shouldBounce ? animationBlock : ^(BOOL finished) {
        [self showAnimationFinished];
    })];
    
}
- (void)showFromPoint:(CGPoint)point {
    startEndPoint = point;
    self.contentContainer.center = point;
    [self show];
}

- (void)hideWithDelegate:(id)del selector:(SEL)sel {
    [self hideWithOnComplete:^(BOOL finished) {
        if ([del respondsToSelector:sel])
            [del performSelector:sel];
    }];
}


- (void)hideWithOnComplete:(UAModalDisplayPanelAnimationComplete)onComplete {
    // Hide the view right away
    [UIView animateWithDuration:0.3 * self.animationTimeScale
                     animations:^{
                         self.alpha = 0;
                         if (startEndPoint.x != CGPointZero.x || startEndPoint.y != CGPointZero.y) {
                             self.contentContainer.center = startEndPoint;
                         }
                         self.contentContainer.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
                     }
                     completion:^(BOOL finished){
                         if (onComplete)
                             onComplete(finished);
                         
                         [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
                         [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
                         [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
                     }];
}


#pragma mark - Keyboard Moving

- (void)keyboardWillShow:(NSNotification *)notification {
    CGFloat keyboardHeight = 0;
    CGFloat animationDuration = 0.3;
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (notification) {
        NSDictionary* keyboardInfo = [notification userInfo];
        CGRect keyboardFrame = [[keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        animationDuration = [[keyboardInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        
        if(UIInterfaceOrientationIsPortrait(orientation))
            keyboardHeight = keyboardFrame.size.height;
        else
            keyboardHeight = keyboardFrame.size.width;
        
        if (IOS_8_OR_LATER) keyboardHeight = keyboardFrame.size.height;
    }
    
    CGFloat screenHeight = 0;
    
    if(UIInterfaceOrientationIsPortrait(orientation))
        screenHeight = [UIScreen mainScreen].bounds.size.height;
    else
        screenHeight = [UIScreen mainScreen].bounds.size.width;
    
    if (IOS_8_OR_LATER) screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    __block CGRect frame = self.roundedRect.frame;
    keyboardDelta = frame.origin.y;
    
    if (frame.origin.y + frame.size.height > screenHeight - keyboardHeight) {
        
        frame.origin.y = screenHeight - keyboardHeight - frame.size.height - 10;
        
        if (frame.origin.y < 0)
            frame.origin.y = 0;
        
        keyboardDelta -= frame.origin.y;
        
        
        UIViewAnimationCurve curve = [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
        
        [UIView animateWithDuration:animationDuration
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             [UIView setAnimationCurve:curve];
                             self.roundedRect.frame = frame;
                             
                             frame = self.closeButton.frame;
                             frame.origin.y -= keyboardDelta;
                             self.closeButton.frame = frame;
                             
                             frame = self.contentView.frame;
                             frame.origin.y -= keyboardDelta;
                             self.contentView.frame = frame;
                             
                             self.contentContainer.transform = CGAffineTransformIdentity;
                         }
                         completion:nil];
    }
    else {
        keyboardDelta = 0.0f;
    }
}

- (void)keyboardDidShow:(NSNotification *)notification {
    // sometimes we couldn't move the view during willShow (eg when a text field has immediate focus), so we move it here
    CGFloat keyboardHeight = 0;
    CGFloat animationDuration = 0.3;
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (notification) {
        NSDictionary* keyboardInfo = [notification userInfo];
        CGRect keyboardFrame = [[keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        animationDuration = [[keyboardInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        
        if(UIInterfaceOrientationIsPortrait(orientation))
            keyboardHeight = keyboardFrame.size.height;
        else
            keyboardHeight = keyboardFrame.size.width;
        
        if (IOS_8_OR_LATER) keyboardHeight = keyboardFrame.size.height;
    }
    
    CGFloat screenHeight = 0;
    
    if(UIInterfaceOrientationIsPortrait(orientation))
        screenHeight = [UIScreen mainScreen].bounds.size.height;
    else
        screenHeight = [UIScreen mainScreen].bounds.size.width;
    
    if (IOS_8_OR_LATER) screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    
    __block CGRect frame = self.roundedRect.frame;
    CGFloat previousKeyboardDelta = keyboardDelta;
    keyboardDelta = frame.origin.y;
    
    if (frame.origin.y + frame.size.height > screenHeight - keyboardHeight) {
        
        frame.origin.y = screenHeight - keyboardHeight - frame.size.height - 10;
        
        if (frame.origin.y < 15)
            frame.origin.y = 15;
        
        keyboardDelta -= frame.origin.y;
        
        UIViewAnimationCurve curve = [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
        
        [UIView animateWithDuration:animationDuration
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             [UIView setAnimationCurve:curve];
                             self.roundedRect.frame = frame;
                             
                             frame = self.closeButton.frame;
                             frame.origin.y -= keyboardDelta;
                             self.closeButton.frame = frame;
                             
                             frame = self.contentView.frame;
                             frame.origin.y -= keyboardDelta;
                             self.contentView.frame = frame;
                             
                             self.contentContainer.transform = CGAffineTransformIdentity;
                         }
                         completion:nil];
    }
    else {
        keyboardDelta = previousKeyboardDelta;
    }
}


- (void)keyboardWillHide:(NSNotification*)notification {
    if (keyboardDelta > 0.0f) {
        CGFloat animationDuration = 0.3;
        
        if (notification) {
            NSDictionary* keyboardInfo = [notification userInfo];
            animationDuration = [[keyboardInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        }
        
        UIViewAnimationCurve curve = [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
        
        [UIView animateWithDuration:animationDuration
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             [UIView setAnimationCurve:curve];
                             CGRect frame;
                             
                             frame = self.roundedRect.frame;
                             frame.origin.y += keyboardDelta;
                             self.roundedRect.frame = frame;
                             
                             frame = self.closeButton.frame;
                             frame.origin.y += keyboardDelta;
                             self.closeButton.frame = frame;
                             
                             frame = self.contentView.frame;
                             frame.origin.y += keyboardDelta;
                             self.contentView.frame = frame;
                         } 
                         completion:nil];
    }
}

@end
