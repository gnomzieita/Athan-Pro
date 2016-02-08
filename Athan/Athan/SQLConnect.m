
#import "SQLConnect.h"

static SQLConnect * appInstance;

@implementation SQLConnect

+(SQLConnect*)sharedInstance {
	if (!appInstance) {
		appInstance = [[SQLConnect alloc] init];
	}
	return appInstance;
}

-(id) init {
    if (self = [super init]) {
		[self openDB]; // only open the database once during init
    }
    return self;
}

- (void) openDB
{
	databaseName = @"athan.db";
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	databasePath = [documentsDirectory stringByAppendingPathComponent:databaseName];
	sqlite3_open([databasePath UTF8String], &database);
}

- (NSMutableArray *)getSavedTips{
	NSMutableArray *recordArray = [[NSMutableArray alloc] init];	
	sqlite3_stmt *compiledStatement;
	const char *sqlStatement;
	
	sqlStatement = "SELECT * FROM country";
	if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
		while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
			NSMutableDictionary *recordDict = [[NSMutableDictionary alloc] init];
//			[recordDict setObject:[NSNumber numberWithInt:sqlite3_column_int(compiledStatement,0)] forKey:@"pk"];
//			[recordDict setObject:[NSNumber numberWithInt:sqlite3_column_int(compiledStatement,1)] forKey:@"id"];
//			[recordDict setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,2)] forKey:@"category"];
//			[recordDict setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,3)] forKey:@"poker_dharma"];
//			[recordDict setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,4)] forKey:@"poker_guru"];
//			[recordDict setObject:[NSNumber numberWithInt:sqlite3_column_int(compiledStatement,5)] forKey:@"saved"];
//			[recordDict setObject:[NSNumber numberWithInt:sqlite3_column_int(compiledStatement,6)] forKey:@"time_saved"];
			[recordArray addObject:recordDict];
		}
		sqlite3_finalize(compiledStatement);
	}
	return recordArray;
}

@end
