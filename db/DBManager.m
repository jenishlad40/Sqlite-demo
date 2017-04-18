//
//  DBManager.m
//  SQLite Database
//
//  Created by Mahaboobsab Nadaf on 22/09/16.
//  Copyright © 2016 com.NeoRays. All rights reserved.
//

#import "DBManager.h"
static DBManager* sharedInstance = nil;

static sqlite3 *database = nil;

static sqlite3_stmt *statement = nil;
@implementation DBManager
+(DBManager *)getSharedInstance
{
    if (!sharedInstance) {
        sharedInstance=[[super allocWithZone:NULL]init];
        [sharedInstance createDB];
    }
    
    return sharedInstance;
}
-(BOOL)createDB
{
    NSString *docsDir;
    NSArray *dirPaths;
    
    
    //get the document directory
    dirPaths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths [0];
    
    //build path to the database
    databasePath=[[NSString alloc]initWithString:[docsDir stringByAppendingPathComponent:@"student.db"]];
    
    BOOL isSuccess=YES;
    
    NSFileManager *fileMgr=[NSFileManager defaultManager];
    if ([fileMgr fileExistsAtPath:databasePath]==NO) {
        
        const char *dbpath=[databasePath UTF8String];
        if (sqlite3_open(dbpath, &database)==SQLITE_OK) {
            char *errorMsg;
            const char *sql_stmt="create table if not exists studentsDetail (regno integer primary key, name text, department text, year text)";
            if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errorMsg)!=SQLITE_OK) {
                
                isSuccess=NO;
                NSLog(@"Failed to create table");
            }
            sqlite3_close(database);
            return isSuccess;
        }
        else
        {
            isSuccess=NO;
            NSLog(@"Failed to open/create database");
        }
    }
    
    
    return isSuccess;
}

-(BOOL)saveData:(NSString *)registerNumber name:(NSString *)name department:(NSString *)department year:(NSString *)year
{
    const char *dbpath = [databasePath UTF8String]; if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        NSString *insertSQL = [NSString stringWithFormat:@"insert into studentsDetail (regno,name, department, year) values (\"%ld\",\"%@\", \"%@\", \"%@\")",(long)[registerNumber integerValue], name, department, year];
        const char *insert_stmt = [insertSQL UTF8String]; sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL); if (sqlite3_step(statement) == SQLITE_DONE)
        {
            sqlite3_reset(statement);
            return YES; }
        else {
            return NO;
        }
    }
    return NO;
    
}


-(NSArray *)findByRegisterNumber:(NSString *)registerNumber{
    
    
    const char *dbpath = [databasePath UTF8String]; if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        NSString *querySQL = [NSString stringWithFormat:
                              @"select name, department, year from studentsDetail where regno=\"%@\"",registerNumber];
        const char *query_stmt = [querySQL UTF8String]; NSMutableArray *resultArray = [[NSMutableArray alloc]init]; if (sqlite3_prepare_v2(database,
                                                                                                                                           query_stmt, -1, &statement, NULL) == SQLITE_OK) {
            if (sqlite3_step(statement) == SQLITE_ROW) {
                NSString *name = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)]; [resultArray addObject:name];
                NSString *department = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 1)]; [resultArray addObject:department];
                NSString *year = [[NSString alloc]initWithUTF8String: (const char *) sqlite3_column_text(statement, 2)]; [resultArray addObject:year];
                sqlite3_reset(statement);
                return resultArray;
            } else{
                sqlite3_reset(statement);
                NSLog(@"Not found");
                return nil; }
            
        }
    }
    return nil;
}

@end
