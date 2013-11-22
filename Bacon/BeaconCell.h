//
//  BeaconCell.h
//  Beacon
//
//  Created by Joshua Barrow on 11/22/13.
//  Copyright (c) 2013 Jukaela Enterprises. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BeaconCell : NSTableCellView

@property (strong, nonatomic) IBOutlet NSTextField *nameTextField;
@property (strong, nonatomic) IBOutlet NSTextField *statusTextField;
@property (strong, nonatomic) IBOutlet NSImageView *statusImageView;
@end
