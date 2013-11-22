//
//  DataHandler.m
//  Fetch
//
//  Created by Josh on 9/8/13.
//  Copyright (c) 2013 Jukaela Enterprises. All rights reserved.
//

#import "ProjectHandler.h"
#import "Beacon.h"
#import <ObjectiveRecord/ObjectiveRecord.h>

@implementation ProjectHandler

+(BOOL)importFromPath:(NSString *)path
{
    NSLog(@"%s", __FUNCTION__);
    
    NSDictionary *importedDictionary = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    
    Beacon *beacon = [Beacon create];
    
    [beacon setName:importedDictionary[@"name"]];
    [beacon setUuid:importedDictionary[@"uuid"]];
    [beacon setMajor:importedDictionary[@"major"]];
    [beacon setMinor:importedDictionary[@"minor"]];
    [beacon setPower:importedDictionary[@"power"]];
    
    [beacon setStatus:@"Beacon Off"];
    
    return [beacon save];
}

+(BOOL)exportBeacon:(Beacon *)project toUrl:(NSURL *)url error:(NSError **)error
{
    NSLog(@"%s", __FUNCTION__);
    
    NSMutableDictionary *returnDictionary = [NSMutableDictionary dictionary];
    
    [returnDictionary setObject:[project name] forKey:@"name"];
    [returnDictionary setObject:[project uuid] forKey:@"uuid"];
    [returnDictionary setObject:[project major] forKey:@"major"];
    [returnDictionary setObject:[project minor] forKey:@"minor"];
    [returnDictionary setObject:[project power] forKey:@"power"];
    
    NSData *encodedData = [NSKeyedArchiver archivedDataWithRootObject:returnDictionary];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
        [[NSFileManager defaultManager] removeItemAtURL:url error:&*error];
        
        if (*error) {
            NSLog(@"%@", [*error description]);
        }
    }
    
    return [encodedData writeToURL:url atomically:YES];
}

@end
