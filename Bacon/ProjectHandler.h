//
//  DataHandler.h
//  Fetch
//
//  Created by Josh on 9/8/13.
//  Copyright (c) 2013 Jukaela Enterprises. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Beacon;

@interface ProjectHandler : NSObject

/**
 * Import Beacon from Path
 *
 * @param path The path to load the project from
 * @return Success or failure boolean
 */
+(BOOL)importFromPath:(NSString *)path;

/**
 * Export Beacon
 *
 * @param project The Beacon to export
 * @param url The url to save the Project to
 * @return NSDictionary representation of the exported Beacon
 */
+(BOOL)exportBeacon:(Beacon *)project toUrl:(NSURL *)url error:(NSError **)error;

@end
