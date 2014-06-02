//
//  ViewController.m
//  SQLLite_TEST
//
//

#import "ViewController.h"`

@interface ViewController ()
{
    NSMutableArray *arrayOfPesron;
    sqlite3 *personDB; //sqlite3 is a library; gives you access to an object that has the tools to interact with the database, personDB is a variable that represents the library
    NSString *dbPathString;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    arrayOfPesron = [[NSMutableArray alloc] init]; //used for displaying people
    [[self myTableView]setDelegate:self];
    [[self myTableView]setDataSource:self];
    [self createOrOpenDB];
    [self displayPerson];
}



-(void)createOrOpenDB
{
    char *error;
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //array of various directories/strings, what are these directories
    NSString *docPath = [path objectAtIndex:0]; //returns the object at location zero; docpath returns first item in the list of directories that nssearchpathfordirectories gives us
    dbPathString = [docPath stringByAppendingPathComponent:@"Person.db"]; //appends person.db to docpath, docpath is just a folder so we need to tell it what file we want which is person.db
    NSFileManager *fileManager = [NSFileManager defaultManager]; //declaring filemanager which we can refer to when we want to access the file system

    if (![fileManager fileExistsAtPath:dbPathString]) //fileExistsAtPath is a method on fileManager, with dbPathString as the argument
    {
        const char *dbPath = [dbPathString UTF8String]; //converting dbPath to a UTF8String
        //sqlite is in c, so we can't pass in an objective c object bc it can't understand it which is why we converted to UTF8String
        
        //create database
        if (sqlite3_open(dbPath, &personDB)== SQLITE_OK) //opening the file at dbPath and its returning the response code, SQLITE_OK returns 0 since its status code
        {   //variable is a string that happens to be sql code
            const char *sql_stmt = "CREATE TABLE IF NOT EXISTS PERSONS (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT, AGE INTEGER)";
            if(sqlite3_exec(personDB, sql_stmt, NULL, NULL, &error) == SQLITE_OK)
                //execute the sql statement, sqlite3_exec is from the sql api
            
//                //SQLITE_API int sqlite3_exec(
//                  sqlite3*,                                  /* An open database */
//                const char *sql,                           /* SQL to be evaluated */
//                int (*callback)(void*,int,char**,char**),  /* Callback function */
//                void *,                                    /* 1st argument to callback */
//                char **errmsg                              /* Error msg written here */
            {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Create" message:@"Create table" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
                [alert show]; //show is a built in method of alertview
            }
            sqlite3_close(personDB);

        }
        else
        {
            NSLog(@"Unable to open db"); //if it returns anything besides 0 for status code when opening the database
        }
    }
    
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView // from quick help: asks the data source, view controller, to return the number of sections in the table view.
{
    return 1; //shows data once, could show different things in different sections if there were multiple sections, in generation of the table it runs this method as a callback
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section //from quick help: Tells the data source to return the number of rows in a given section of a table view. (required)
{
    return [arrayOfPesron count]; //number of objects in arrayOfPesron
}
// cellForRowAtIndexPath is just a label so you know what its supposed to be doing
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{//above method iterates through each cell and gives you access to indexPath, you can make an array in the same order as the cells so you know which object in the array applies to the corresponding cell. The NSIndexPath class represents the path to a specific node in a tree of nested array collections. This path is known as an index path.
    //table is a list, each cell is just an item in the list; table will display the array in order bc the index path matches, sort of a loop, method gets run once for each cell, each time its run the value of indexPath changes as it iterates through each cell
        //gives you the opportunity to match up a tableview with an array so you can display in the order you want
    
    static NSString *cellIdentifier = @"cell"; //declaring static string variable cellIdentifier, static so its available outside of the method, static so we don't keep creating cellIdentifier when we call tableView cellForRowIndexPath
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier]; //each cell has a unique identifier presumably for memory mgmt purposes; for display of cell
    if (!cell)
    { //a cell is a row of a tableview
        
//The UITableViewCell class defines the attributes and behavior of the cells that appear in UITableView objects. This class includes properties and methods for setting and managing cell content and background (including text, images, and custom views), managing the cell selection and highlight state, managing accessory views, and initiating the editing of the cell contents.

        //need more clarification
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
//      initWithStyle -->  Initializes a table cell with a style and a reuse identifier (?) and returns it to the caller.
//        This method is the designated initializer for the class. The reuse identifier is associated with those cells (rows) of a table view that have the same general configuration, minus cell content.
//        typedef NS_ENUM(NSInteger, UITableViewCellStyle) {
//            UITableViewCellStyleDefault,	// Simple cell with text label and optional image view (behavior of UITableViewCell in iPhoneOS 2.x)
//            UITableViewCellStyleValue1,		// Left aligned label on left and right aligned label on right with blue text (Used in Settings)
//            UITableViewCellStyleValue2,		// Right aligned label on left with blue text and left aligned label on right (Used in Phone/Contacts)
//            UITableViewCellStyleSubtitle	// Left aligned label on top and left aligned label on bottom with gray text (Used in iPod).
//        };             // available in iPhone OS 3.0
        
    }
    Person *aPeraon = [arrayOfPesron objectAtIndex:indexPath.row]; //row in a section of tableview, row is actually the row number
    cell.textLabel.text = aPeraon.name; //textLabel is main text of a cell
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d",aPeraon.age]; //for age, shown below name
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addPersonButton:(id)sender //sender is way to identify the object triggering the method, sender refers to addPersonButton
{
    char *error; //needs to be "error"
    if(sqlite3_open([dbPathString UTF8String], &personDB) == SQLITE_OK) //&personDB pointing to memory address of personDB bc its a primitive not an object
    {
        NSString *insertStmt = [NSString stringWithFormat:@"INSERT INTO PERSONS (NAME,AGE) VALUES ('%s','%d')",[self.nameField.text UTF8String],[self.ageField.text intValue]];
        const char *insert_stmt = [insertStmt UTF8String];
        NSLog(@"Add Person button click..");
        if (sqlite3_exec(personDB, insert_stmt, NULL, NULL, &error) == SQLITE_OK)
        {
            NSLog(@"Person added to DB");
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Add person Complete" message:@"Person added to DB" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil]; //otherButtonTitles:nil included bc just one button
            [alert show];
            Person *person = [[Person alloc] init];
            [person setName:self.nameField.text]; //could just do person.name or person.age, camel-casing age and name
            [person setAge:[self.ageField.text intValue]];
            [arrayOfPesron addObject:person];
        }
        sqlite3_close(personDB); //closes connection to the database personDB
    
/*        SQLITE_API int sqlite3_close(sqlite3 *);
 
         ** The type for a callback function.
         ** This is legacy and deprecated.  It is included for historical
         ** compatibility and is not documented.
*/
    
    }
    
    
    [self displayPerson];

}

- (IBAction)deletePersonButton:(id)sender //sender is a way to identify who's triggering the method
{
    UIButton *btn  = sender; //delete button is the sender, getting triggered on slide which is the ibaction (confirm?)
    if([[self myTableView] isEditing])
    {
        [btn setTitle:@"Delete" forState:UIControlStateNormal];
    }
    else
    {
        [btn setTitle:@"Done" forState:UIControlStateNormal];
    }

    [[self myTableView]setEditing:!self.myTableView.editing animated:YES];
}

-(void)deleteData:(NSString *)deleteQuery
{
    char *error;
    if (sqlite3_exec(personDB, [deleteQuery UTF8String], NULL, NULL, &error)==SQLITE_OK)
    {
        NSLog(@"Person Deleted");
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Delete" message:@"Person Deleted" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
        [alert show];
    }
}
//commitEditingStyle: Asks the data source to commit the insertion or deletion of a specified row in the receiver.
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        Person *p = [arrayOfPesron objectAtIndex:indexPath.row];
        [self deleteData:[NSString stringWithFormat:@"DELETE FROM PERSONS WHERE NAME IS '%s'", [p.name UTF8String]]];
        [arrayOfPesron removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)displayPerson
{
    sqlite3_stmt *statement ;
    if (sqlite3_open([dbPathString UTF8String], &personDB)==SQLITE_OK) ////opening the file at dbPathString and its returning the response code, SQLITE_OK returns 0 since its status code
    {
        [arrayOfPesron removeAllObjects];
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM PERSONS"];
        const char *query_sql = [querySQL UTF8String]; //converting to type of string C understands
        if (sqlite3_prepare(personDB, query_sql, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement)== SQLITE_ROW) //while stepping through database, if it returns a row it should keep going, cuts out if it returns something other than SQLITE_ROW
            {
                NSString *name = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 1)];
                //read data and take what we want from it - column 1 and 2 name and age, we don't display column 0 bc its an id
                //converting statement into name variable; its just a placeholder which is why we can use it twice
                NSString *ageString = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 2)];
                //
                Person *person = [[Person alloc]init];
                [person setName:name];
                [person setAge:[ageString intValue]];
                [arrayOfPesron addObject:person];
                
            }
        }
    }
    [[self myTableView]reloadData];
}
@end
