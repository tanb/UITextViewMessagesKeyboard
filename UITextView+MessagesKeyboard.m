//
//  UITextView+MessagesKeyboard.m
//  TBMemo
//
//  Created by tanB on 6/28/13.
//  Copyright (c) 2013 tanB. All rights reserved.
//

#import "UITextView+MessagesKeyboard.h"

@implementation UITextView (MessagesKeyboard)

- (BOOL)alwaysBounceVertical
{
    return YES;
}

- (void)scrollViewWillBeginDeceleratingProcedure
{
    if (self.uiKeyboard.frame.origin.y > self.uiKeyboardOriginalRect.origin.y) return;
    self.uiKeyboard.frame = self.uiKeyboardOriginalRect;
}

- (void)scrollViewWillEndDraggingProcedureWithVelocity:(CGPoint)velocity
{
    if (velocity.y < -1) {
        CGSize windowSize = [UIApplication sharedApplication].delegate.window.bounds.size;
        CGRect newFrame = self.uiKeyboard.frame;
        newFrame.origin.y = windowSize.height;
        
        [UIView animateWithDuration:0.2
                         animations:^{
                             self.uiKeyboard.frame = newFrame;
                         }
                         completion:^(BOOL finished){
                             UIView *keyboard = self.uiKeyboard;
                             keyboard.hidden = YES;
                             [self resignFirstResponder];
                             
                             double delayInSeconds = 0.4;
                             dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW,
                                                                     (int64_t)(delayInSeconds * NSEC_PER_SEC));
                             dispatch_after(popTime,
                                            dispatch_get_main_queue(),
                                            ^(void){
                                                keyboard.hidden = NO;
                                            });
                         }];
    } else {
        self.uiKeyboard.frame = self.uiKeyboardOriginalRect;
    }
}

- (void)scrollViewDidScrollProcedure
{
    if (self.decelerating) return;
    
    if (self.panGestureRecognizer.state == UIGestureRecognizerStatePossible) return;
    
    UIWindow *mainWindow = [UIApplication sharedApplication].delegate.window;
    CGPoint location = [self.panGestureRecognizer locationInView:mainWindow];
    
    if (location.y > self.uiKeyboardOriginalRect.origin.y) {
        CGRect kbRect = self.uiKeyboard.frame;
        kbRect.origin.y  = location.y;
        self.uiKeyboard.frame = kbRect;
    } else {
        self.uiKeyboard.frame = self.uiKeyboardOriginalRect;
    }
}

- (UIView *)uiKeyboard
{
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        if ([window isKindOfClass:NSClassFromString(@"UITextEffectsWindow")]) {
            for (UIView *view in window.subviews) {
                if ([view isKindOfClass:NSClassFromString(@"UIPeripheralHostView")]) {
                    return view;
                }
            }
        }
    }
    
    return nil;
}

- (CGRect)uiKeyboardOriginalRect
{
    CGSize windowSize = [UIApplication sharedApplication].delegate.window.bounds.size;
    CGRect rect = self.uiKeyboard.frame;
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown) {
        rect.origin.y = windowSize.height - self.uiKeyboard.frame.size.height;
    } else {
        rect.origin.y = windowSize.width - self.uiKeyboard.frame.size.height;
    }
    return rect;
}

@end
