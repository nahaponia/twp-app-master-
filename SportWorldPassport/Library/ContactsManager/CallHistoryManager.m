//
//  CallHistoryManager.m
//  SportWorldPassport
//
//  Created by star on 11/29/15.
//  Copyright (c) 2015 UWP. All rights reserved.
//

#import "CallHistoryManager.h"
#import "sqlite3.h"

@implementation CallHistoryManager

+ (void)getPrivateDBs {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *dirnum = [[NSFileManager defaultManager] enumeratorAtPath: @"/private/"];
    NSString *nextItem = [NSString string];
    while( (nextItem = [dirnum nextObject])) {
        if ([[nextItem pathExtension] isEqualToString: @"db"] ||
            [[nextItem pathExtension] isEqualToString: @"sqlitedb"]) {
            if ([fileManager isReadableFileAtPath:nextItem]) {
                NSLog(@"%@", nextItem);
            }
        }
    }
}

+ (NSArray *)getCallHistoryList {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *callHisoryDatabasePath = @"/private/var/wireless/Library/CallHistory/call_history.db";
    BOOL callHistoryFileExist = FALSE;
    callHistoryFileExist = [fileManager fileExistsAtPath:callHisoryDatabasePath];

    NSMutableArray *callHistory = [[NSMutableArray alloc] init];
    
    if(callHistoryFileExist) {
        if ([fileManager isReadableFileAtPath:callHisoryDatabasePath]) {
            sqlite3 *database;
            if(sqlite3_open([callHisoryDatabasePath UTF8String], &database) == SQLITE_OK) {
                sqlite3_stmt *compiledStatement;
                NSString *sqlStatement = @"SELECT * FROM call;";
                
                int errorCode = sqlite3_prepare_v2(database, [sqlStatement UTF8String], -1,
                                                   &compiledStatement, NULL);
                if( errorCode == SQLITE_OK) {
                    int count = 1;
                    
                    while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                        // Read the data from the result row
                        NSMutableDictionary *callHistoryItem = [[NSMutableDictionary alloc] init];
                        int numberOfColumns = sqlite3_column_count(compiledStatement);
                        NSString *data;
                        NSString *columnName;
                        
                        for (int i = 0; i < numberOfColumns; i++) {
                            columnName = [[NSString alloc] initWithUTF8String:
                                          (char *)sqlite3_column_name(compiledStatement, i)];
                            data = [[NSString alloc] initWithUTF8String:
                                    (char *)sqlite3_column_text(compiledStatement, i)];
                            
                            [callHistoryItem setObject:data forKey:columnName];
                        }
                        [callHistory addObject:callHistoryItem];
                        count++;
                    }
                }
                else {
                    NSLog(@"Failed to retrieve table");
                    NSLog(@"Error Code: %d", errorCode);
                }
                sqlite3_finalize(compiledStatement);
            }
        }
    }
    
    return [NSArray arrayWithArray:callHistory];
}

@end
