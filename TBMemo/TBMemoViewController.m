//
//  TBMemoViewController.m
//  TBMemo
//
//  Created by tanB on 6/26/13.
//  Copyright (c) 2013 tanB. All rights reserved.
//

#import "TBMemoViewController.h"
#import "TBStoreManager.h"
#define TOP_MARGIN 10

@interface TBMemoViewController ()
@property (nonatomic) UIGestureRecognizer *titleViewTapGesture;
@property (nonatomic) UIView *inputAccessoryView;
@end



@implementation TBMemoViewController

#pragma mark - initializer
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (!self) return nil;
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

    [center addObserver:self
               selector:@selector(keyboardWillShow:)
                   name:UIKeyboardWillShowNotification
                 object:nil];

    [center addObserver:self
               selector:@selector(keybaordWillHide:)
                   name:UIKeyboardWillHideNotification
                 object:nil];
    
    [center addObserver:self
               selector:@selector(keybaordDidHide:)
                   name:UIKeyboardDidHideNotification
                 object:nil];
    
    self.titleViewTapGesture =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(showEditTitleAlertView:)];

    return self;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.textView scrollViewDidScrollProcedure];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset
{
    
    [self.textView scrollViewWillEndDraggingProcedureWithVelocity:velocity];
 }

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    [self.textView scrollViewWillBeginDeceleratingProcedure];
}


#pragma mark - view life sycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.textView.contentInset = UIEdgeInsetsMake(TOP_MARGIN, 0, 0, 0);
    self.textView.scrollIndicatorInsets = UIEdgeInsetsZero;
    self.textView.delegate = self;

    CGRect accessoryViewRect = {0, self.view.bounds.size.height - 1, self.view.bounds.size.width, 1};
    self.inputAccessoryView = [[UIView alloc] initWithFrame:accessoryViewRect];
    self.inputAccessoryView.layer.shadowColor = [UIColor colorWithRed:1.000 green:0.273 blue:0.000 alpha:1.000].CGColor;
    self.inputAccessoryView.layer.shadowOpacity = 1;
    self.inputAccessoryView.layer.shadowRadius = 3;
    self.inputAccessoryView.layer.shadowOffset = CGSizeMake(0, -1);
    self.inputAccessoryView.layer.shouldRasterize = YES;
    self.inputAccessoryView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    self.inputAccessoryView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.inputAccessoryView.backgroundColor = [UIColor redColor];
    self.textView.inputAccessoryView = self.inputAccessoryView;
    [self.view addSubview:self.inputAccessoryView];
    
    self.timestampLabel = [UILabel new];
    self.timestampLabel.frame = CGRectMake(0, -2, self.textView.bounds.size.width, TOP_MARGIN);
    self.timestampLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.timestampLabel.textAlignment = NSTextAlignmentCenter;
    self.timestampLabel.backgroundColor = [UIColor clearColor];
    self.timestampLabel.textColor = [UIColor colorWithWhite:0.657 alpha:1.000];
    self.timestampLabel.font = [UIFont boldSystemFontOfSize:10];
    
    UIView *textViewContentView = [self grabWebDocumentView];
    if (textViewContentView) {
        [textViewContentView addSubview:self.timestampLabel];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self configureView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    UIView *titleView = [self grabTitleView];
    if (titleView) {
        titleView.userInteractionEnabled = YES;
        [titleView addGestureRecognizer:self.titleViewTapGesture];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    UIView *titleView = [self grabTitleView];
    if (titleView) {
        titleView.userInteractionEnabled = NO;
        [titleView removeGestureRecognizer:self.titleViewTapGesture];
    }
    
    if (![self isManagedByNavigationController]) {
        // back button was pressed.
        if (![self saveMemoIfNeeded]) {
            [[TBStoreManager sharedManager].managedObjectContext rollback];
        }
    }
    
    [super viewWillDisappear:animated];
}

#pragma mark - misc
- (BOOL)isManagedByNavigationController
{
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        return NO;
    }
    return YES;
}

- (UIView *)grabTitleView
{
    for (UIView *view in self.navigationController.navigationBar.subviews) {
        if ([view isKindOfClass:NSClassFromString(@"UINavigationItemView")]) {
            return view;
        }
    }
    return nil;
}

- (UIView *)grabWebDocumentView
{
    for (UIView *view in self.textView.subviews) {
        if ([view isKindOfClass:NSClassFromString(@"UIWebDocumentView")]) {
            return view;
        }
    }
    return nil;
}

- (void)showEditTitleAlertView:(UITapGestureRecognizer *)tapGesture
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Edit Title"
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];

    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
	UITextField *textField = [alert textFieldAtIndex:0];
	textField.text = self.memoItem.title;

	[alert show];
}

- (BOOL)saveMemoIfNeeded
{
    if (!self.memoItem.text && [self.textView.text isEqualToString:@""]) {
        return NO;
    }
    
    self.memoItem.text  = self.textView.text;
    NSCharacterSet *wSpaceNewline = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    if (!self.memoItem.title) {
        self.memoItem.title =
        [self.memoItem.text componentsSeparatedByCharactersInSet:wSpaceNewline][0];
    }
    NSManagedObjectContext *context = [TBStoreManager sharedManager].managedObjectContext;
    NSError *error = nil;
    
    NSDictionary *changed = [self.memoItem changedValues];
    if ([changed count] > 0) {
        self.memoItem.updatedAt = [NSDate date];
        if (![context save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } else {
            return YES;
        }
    }
    return NO;
}

- (Memo *)memoItem
{
    NSManagedObjectContext *context = [TBStoreManager sharedManager].managedObjectContext;
    
    if (!_memoItem) {
        _memoItem = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Memo class])
                                                  inManagedObjectContext:context];
    }
    return _memoItem;
}

- (void)configureView
{
    self.title = self.memoItem.title;
    self.textView.text = self.memoItem.text;
    if ([self.textView.text isEqualToString:@""]) [self.textView becomeFirstResponder];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yy HH:mm"];    
    self.timestampLabel.text = [formatter stringFromDate:self.memoItem.updatedAt];
}

#pragma mark - memory
- (void)dealloc
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - keyboard notification handler
- (void)keyboardWillShow:(NSNotification *)notification
{
    if (![self.textView isFirstResponder]) return;

    // Get userInfo
    NSDictionary *userInfo;
    userInfo = [notification userInfo];

    // Calc overlap of keyboardFrame and textViewFrame
    CGFloat overlap;
    CGRect keyboardFrame;
    CGRect textViewFrame;
    keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardFrame = [self.textView.superview convertRect:keyboardFrame
                                                fromView:nil];
    textViewFrame = self.textView.frame;
    overlap = MAX(0.0f, CGRectGetMaxY(textViewFrame) - CGRectGetMinY(keyboardFrame));
    
    // Animate insets of _scrollView
    NSTimeInterval duration;
    UIViewAnimationCurve animationCurve;
    void (^animations)(void);
    duration = [[userInfo
                 objectForKey:UIKeyboardAnimationDurationUserInfoKey]
                doubleValue];
    animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    animations = ^(void) {
        // Set insets of _scrollView
        self.textView.contentInset = UIEdgeInsetsMake(TOP_MARGIN, 0.0f, overlap, 0.0f);
        self.textView.scrollIndicatorInsets = UIEdgeInsetsMake(0.0f, 0.0f, overlap, 0.0f);
    };
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:(animationCurve << 16)
                     animations:animations
                     completion:nil];
    
    // Scroll to bottom
    CGRect rect;
    rect.origin.x = 0.0f;
    rect.origin.y = self.textView.contentSize.height - 1.0f;
    rect.size.width = CGRectGetWidth(self.textView.frame);
    rect.size.height = 1.0f;
    [self.textView scrollRectToVisible:rect animated:YES];
}

- (void)keybaordWillHide:(NSNotification *)notification
{
    if (![self.textView isFirstResponder]) return;

    CGRect accessoryViewRect = {0, self.view.bounds.size.height - 1, self.view.bounds.size.width, 1};

    self.inputAccessoryView.frame = accessoryViewRect;

    [self.view addSubview:self.inputAccessoryView];
    
    // Get userInfo
    NSDictionary *userInfo;
    userInfo = [notification userInfo];
    
    // Animate insets of _scrollView
    NSTimeInterval duration;
    UIViewAnimationCurve animationCurve;
    duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];

    void (^animations)(void) = ^(void) {
        self.textView.contentInset = UIEdgeInsetsMake(TOP_MARGIN, 0, 0, 0);
        self.textView.scrollIndicatorInsets = UIEdgeInsetsZero;
    };
    
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:(animationCurve << 16)
                     animations:animations
                     completion:nil];
}

- (void)keybaordDidHide:(NSNotification *)notification
{
    CGRect accessoryViewRect = {0, self.view.bounds.size.height - 1, self.view.bounds.size.width, 1};    
    self.inputAccessoryView.frame = accessoryViewRect;

    [self.view addSubview:self.inputAccessoryView];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	UITextField *textField = [alertView textFieldAtIndex:0];

	if (buttonIndex == 0 && textField) {
        self.memoItem.title = textField.text;
        self.title = self.memoItem.title;
        if ([self.title isEqualToString:@""]) [self showEditTitleAlertView:nil];
	}
}
@end
