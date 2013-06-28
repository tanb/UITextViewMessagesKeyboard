//
//  UITextView+MessagesKeyboard.h
//  TBMemo
//
//  Created by tanB on 6/28/13.
//  Copyright (c) 2013 tanB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UITextView (MessagesKeyboard)

- (void)scrollViewWillBeginDeceleratingProcedure;
- (void)scrollViewWillEndDraggingProcedureWithVelocity:(CGPoint)velocity;
- (void)scrollViewDidScrollProcedure;

- (UIView *)uiKeyboard;

@end
