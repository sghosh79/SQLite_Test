//
//  ViewController.h
//  SQLLite_TEST
//
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"
#import "Person.h"

@interface ViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITextField *nameField;

@property (weak, nonatomic) IBOutlet UITextField *ageField;

@property (weak, nonatomic) IBOutlet UITableView *myTableView;

- (IBAction)addPersonButton:(id)sender;

- (IBAction)deletePersonButton:(id)sender;

- (void)displayPerson;




@end
