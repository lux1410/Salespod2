//
//  LocalDB.m
//  Salespod
//
//  Created by inin on 3/8/14.
//  Copyright (c) 2014 lux. All rights reserved.
//

#import "LocalDB.h"


@implementation LocalDB

static LocalDB* _db;

+ (LocalDB*)LocalDatabase{
    
    if (_db == nil) {
        _db = [[LocalDB alloc] init];
    }
    return _db;
}

- (id)init {
    if ((self = [super init])) {
       
              
        NSString *sqLiteDb =[self checkAndCreateFile:@"db.sqlite3"];
        
        if (sqlite3_open([sqLiteDb UTF8String], &_database) != SQLITE_OK) {
            NSLog(@"Failed to open database!");
        }
    }
    return self;
}

- (void)dealloc {
    
    sqlite3_close(_database);
   
}

-(NSString *) checkAndCreateFile:(NSString *)fileName{
	
    NSArray *homePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *homeDir = [homePaths objectAtIndex:0];
    NSString *filePath = [homeDir stringByAppendingPathComponent:fileName];
	
    BOOL success;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    success = [fileManager fileExistsAtPath:filePath];
	
    if(!success){
        
        
        const char *dbpath = [filePath UTF8String];
        
        if (sqlite3_open(dbpath, &_database) == SQLITE_OK)
        {
            char *errMsg;
            const char *sql_stmt ="CREATE TABLE IF NOT EXISTS PLACES (id text primary key,name text, address text, lat real,lng real)";
           
           
            
            if (sqlite3_exec(_database, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                [NSException raise:@"DB Create Error" format:@"%@",@"Error creating DB!"];
                 
            }
           
        }
        
    }
        
    return filePath;
}


-(int)updateRecord:(MapPoint*)aRecord{
    
    sqlite3_stmt *stmt;
    int cnt=0;
    
    const char* sql="UPDATE PLACES SET NAME=?,ADDRESS=?,LAT=?,LNG=? WHERE ID=?";
    if (sqlite3_prepare_v2(_database, sql, -1, &stmt, nil)
        == SQLITE_OK)
    {
    
    sqlite3_bind_text(stmt, 1, [aRecord.name UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(stmt, 2, [aRecord.address UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_double(stmt, 3, aRecord.coordinate.latitude);
    sqlite3_bind_double(stmt, 4, aRecord.coordinate.longitude);
    sqlite3_bind_text(stmt, 5, [aRecord.id UTF8String], -1, SQLITE_TRANSIENT);
 
    
    sqlite3_step(stmt);
    
    cnt=sqlite3_changes(_database);

    sqlite3_finalize(stmt);
    
    }
    
    return cnt;
    
}

-(int)insertRecord:(MapPoint*)aRecord{
    
    sqlite3_stmt *stmt;
    int cnt=0;
    
    const char* aQuery="SELECT NAME,ADDRESS FROM PLACES WHERE ID=?";
    
    if (sqlite3_prepare_v2(_database, aQuery, -1, &stmt, nil)
        == SQLITE_OK)
    {
        
        sqlite3_bind_text(stmt, 1, [aRecord.id UTF8String], -1, SQLITE_TRANSIENT);
        if (sqlite3_step(stmt) == SQLITE_ROW)
        {
             char* name = (char *) sqlite3_column_text(stmt, 0);
             char* addr=(char *) sqlite3_column_text(stmt, 1);
            
             aRecord.name=[[NSString alloc] initWithUTF8String:name];
             aRecord.address=[[NSString alloc] initWithUTF8String:addr];
            
            sqlite3_finalize(stmt);
            return 0;
        }
        
      sqlite3_finalize(stmt);  
        
    
    const char* sql="INSERT INTO PLACES(ID,NAME,ADDRESS,LAT,LNG) VALUES(?,?,?,?,?)";
    
    if (sqlite3_prepare_v2(_database, sql, -1, &stmt, nil)
        == SQLITE_OK)
      {
    
       sqlite3_bind_text(stmt, 1, [aRecord.id UTF8String], -1, SQLITE_TRANSIENT);
       sqlite3_bind_text(stmt, 2, [aRecord.name UTF8String], -1, SQLITE_TRANSIENT);
       sqlite3_bind_text(stmt, 3, [aRecord.address UTF8String], -1, SQLITE_TRANSIENT);
       sqlite3_bind_double(stmt, 4, aRecord.coordinate.latitude);
       sqlite3_bind_double(stmt, 5, aRecord.coordinate.longitude);
       
       sqlite3_step(stmt);
    
       cnt=sqlite3_changes(_database);
    
       sqlite3_finalize(stmt);
      }
    
    }
    
    return cnt;
    
}



@end
