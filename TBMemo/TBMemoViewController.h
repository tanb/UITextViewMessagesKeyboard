//
//  TBMemoViewController.h
//  TBMemo
//
//  Created by tanB on 6/26/13.
//  Copyright (c) 2013 tanB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Memo.h"

@interface TBMemoViewController : UIViewController <UITextViewDelegate>
@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (nonatomic) UILabel *timestampLabel;
@property (strong, nonatomic) Memo *memoItem;

@end
