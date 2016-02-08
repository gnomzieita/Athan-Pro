
#import <UIKit/UIKit.h>
#import <sqlite3.h>


@interface SQLConnect : UIViewController {
	sqlite3 *database;	
	NSString *databaseName;
	NSString *databasePath;
}
+(SQLConnect*)sharedInstance;

- (NSMutableArray *)getSavedTips;
@end
