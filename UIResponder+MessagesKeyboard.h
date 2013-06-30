//
//  UIResponder+MessagesKeyboard.h
//  TBMemo
//
//  Created by tanB on 6/30/13.
//  Copyright (c) 2013 tanB. All rights reserved.
//


@interface UIResponder(MessagesKeyboard)
- (void)scrollViewWillBeginDeceleratingProcedure;
- (void)scrollViewWillEndDraggingProcedureWithVelocity:(CGPoint)velocity;
- (void)scrollViewDidScrollProcedure:(UIScrollView *)scrollView;

+ (UIView *)uiKeyboard;

@end
