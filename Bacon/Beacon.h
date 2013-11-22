//
//  Beacon.h
//  Beacon
//
//  Created by Joshua Barrow on 11/22/13.
//  Copyright (c) 2013 Jukaela Enterprises. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Beacon : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSString * major;
@property (nonatomic, retain) NSString * minor;
@property (nonatomic, retain) NSString * power;
@property (nonatomic, retain) NSString * status;

@end
