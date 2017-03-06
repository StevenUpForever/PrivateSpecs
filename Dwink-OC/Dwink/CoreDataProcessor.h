//
//  CoreDataProcesser.h
//  Dwink
//
//  Created by Chengzhi Jia on 7/8/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataProcessor : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

/**
 *  Singleton instance of CoreDataProcessor
 *
 *  @return instance variable of CoreDataProcessor
 */

+ (instancetype)sharedProcesser;

- (void)saveContext;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSURL *applicationDocumentsDirectory;

@end
