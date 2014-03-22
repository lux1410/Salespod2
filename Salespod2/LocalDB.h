//
//  LocalDB.h
//  Salespod
//
//  Created by inin on 3/8/14.
//  Copyright (c) 2014 lux. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

#import "MapPoint.h"


@interface LocalDB : NSObject{
    sqlite3 *_database;
}

+ (LocalDB*)LocalDatabase;
-(int)updateRecord:(MapPoint*)aRecord;
-(int)insertRecord:(MapPoint*)aRecord;
-(NSMutableArray*)getPlacesFromDB:(CLLocation*)currentLocation;
//- (NSArray *)failedBankInfos;

@end
