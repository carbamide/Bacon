//
//  AdvertisementData.h
//  Beacon
//
//  Created by Joshua Barrow on 11/22/13.
//  Copyright (c) 2013 Jukaela Enterprises. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AdvertisementData : NSObject

@property (strong,nonatomic) NSUUID *proximityUUID;
@property (assign,nonatomic) uint16_t major;
@property (assign,nonatomic) uint16_t minor;
@property (assign,nonatomic) int8_t measuredPower;

- (id)initWithProximityUUID:(NSUUID *)proximityUUID
                      major:(uint16_t)major
                      minor:(uint16_t)minor
              measuredPower:(int8_t)power;


- (NSDictionary *)beaconAdvertisement;

@end
