//
//  TBStoreManager.h
//  TBMemo
//
//  Created by tanB on 6/26/13.
//  Copyright (c) 2013 tanB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TBStoreManager : NSObject

@property (nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) NSManagedObjectModel *managedObjectModel;
@property (nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (TBStoreManager *)sharedManager;

@end
