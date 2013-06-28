//
//  Memo.m
//  TBMemo
//
//  Created by tanB on 6/25/13.
//  Copyright (c) 2013 tanB. All rights reserved.
//

#import "Memo.h"


@implementation Memo

@dynamic text;
@dynamic title;
@dynamic createdAt;
@dynamic updatedAt;

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = self.createdAt;
}

@end
