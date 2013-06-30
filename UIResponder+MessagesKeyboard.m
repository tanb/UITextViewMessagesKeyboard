//
//  UIResponder+MessagesKeyboard.m
//  TBMemo
//
//  Created by tanB on 6/30/13.
//  Copyright (c) 2013 tanB. All rights reserved.
//

#import "UIResponder+MessagesKeyboard.h"

@implementation UIResponder(MessagesKeyboard)

- (void)scrollViewWillBeginDeceleratingProcedure
{
    UIView *keyboard = self.uiKeyboard;
    CGRect originalRect = [UIResponder originalRectForKeyboard:keyboard];
    if (keyboard.frame.origin.y > originalRect.origin.y) return;
    keyboard.frame = originalRect;
}

- (void)scrollViewWillEndDraggingProcedureWithVelocity:(CGPoint)velocity
{
    UIView *keyboard = self.uiKeyboard;
    CGRect originalRect = [UIResponder originalRectForKeyboard:keyboard];

    if (velocity.y < -1) {
        CGSize windowSize = [UIApplication sharedApplication].delegate.window.bounds.size;
        CGRect newFrame = keyboard.frame;
        newFrame.origin.y = windowSize.height;
        
        [UIView animateWithDuration:0.2
                         animations:^{
                             keyboard.frame = newFrame;
                         }
                         completion:^(BOOL finished){
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
        keyboard.frame = originalRect;
    }
}

- (void)scrollViewDidScrollProcedure:(UIScrollView *)scrollView
{    
    if (scrollView.panGestureRecognizer.state == UIGestureRecognizerStatePossible) return;

    UIView *keyboard = self.uiKeyboard;
    CGRect originalRect = [UIResponder originalRectForKeyboard:keyboard];

    UIWindow *mainWindow = [UIApplication sharedApplication].delegate.window;
    CGPoint location = [scrollView.panGestureRecognizer locationInView:mainWindow];
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    CGFloat position = location.x;
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown) {
        position = location.y;
    }

    if (position > originalRect.origin.y) {
        CGRect kbRect = keyboard.frame;
        kbRect.origin.y  = position;
        keyboard.frame = kbRect;
    } else {
        keyboard.frame = originalRect;
    }
}

- (UIView *)uiKeyboard
{
    if (self.inputAccessoryView) {
        id view = self.inputAccessoryView.superview;
        if ([view isKindOfClass:NSClassFromString(@"UIPeripheralHostView")]) {
            return view;
        }
    }

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

+ (CGRect)originalRectForKeyboard:(UIView *)keyboard
{
    CGSize windowSize = [UIApplication sharedApplication].delegate.window.bounds.size;
    CGRect rect = keyboard.frame;
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown) {
        rect.origin.y = windowSize.height - keyboard.frame.size.height;
    } else {
        rect.origin.y = windowSize.width - keyboard.frame.size.height;
    }
    
    return rect;
}
@end
