//
//  PBPlacesItem.h
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 7/21/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PBPlacesActivity;

@interface PBPlacesItem : NSManagedObject

@property (nonatomic, retain) NSNumber * placesItemId;
@property (nonatomic, retain) NSString * addr;
@property (nonatomic, retain) NSString * addrCity;
@property (nonatomic, retain) NSString * addrState;
@property (nonatomic, retain) NSString * addrZip;
@property (nonatomic, retain) NSString * addrCountry;
@property (nonatomic, retain) NSNumber * lat;
@property (nonatomic, retain) NSNumber * lng;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * website;
@property (nonatomic, retain) NSNumber * foursquareReferenceId;
@property (nonatomic, retain) NSSet *placesActivity;
@end

@interface PBPlacesItem (CoreDataGeneratedAccessors)

- (void)addPlacesActivityObject:(PBPlacesActivity *)value;
- (void)removePlacesActivityObject:(PBPlacesActivity *)value;
- (void)addPlacesActivity:(NSSet *)values;
- (void)removePlacesActivity:(NSSet *)values;

@end
