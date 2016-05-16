//
//  SettingsTableViewController.m
//  AcrylicsColorPicker
//
//  Created by Stuart Pineo on 5/9/16.
//  Copyright © 2016 Stuart Pineo. All rights reserved.
//
#import "SettingsTableViewController.h"
#import "GlobalSettings.h"
#import "FieldUtils.h"
#import "AlertUtils.h"
#import "AppDelegate.h"

@interface SettingsTableViewController ()

@property (nonatomic, strong) UILabel *readOnlyLabel;
@property (nonatomic, strong) UISwitch *readOnlySwitch;
@property (nonatomic) BOOL editFlag, swatchesReadOnly;
@property (nonatomic, strong) NSString *reuseCellIdentifier, *readOnlyKey, *readOnlyText, *makeReadOnlyLabel, *makeReadWriteLabel;
@property (nonatomic, strong) UIAlertController *noSaveAlert;

// NSManagedObject
//
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSEntityDescription *paintSwatchEntity;

@end

@implementation SettingsTableViewController

const int SETTINGS_READ_ONLY_SECTION = 0;
const int SETTINGS_MAX_NUM_SECTIONS  = 1;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _editFlag = FALSE;
    _reuseCellIdentifier = @"SettingsTableCell";
    
    // NSManagedObject
    //
    self.appDelegate = [[UIApplication sharedApplication] delegate];
    self.context = [self.appDelegate managedObjectContext];
    
    _paintSwatchEntity        = [NSEntityDescription entityForName:@"PaintSwatch"    inManagedObjectContext:self.context];


    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Swatches Read-Only Section
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Check for the default values
    //
    _readOnlyKey = @"swatches_read_only";
    _readOnlyText = @"swatches_read_only_text";
    
    _makeReadOnlyLabel  = @"Make My Paint Swatches Read-Only";
    _makeReadWriteLabel = @"Make My Paint Swatches Read/Write";
    
    NSString *labelText;
    if(! ([[NSUserDefaults standardUserDefaults] boolForKey:_readOnlyKey] &&
          [[NSUserDefaults standardUserDefaults] stringForKey:_readOnlyText])
       ) {
        _swatchesReadOnly = FALSE;
        labelText = _makeReadOnlyLabel;
        
        [[NSUserDefaults standardUserDefaults] setBool:_swatchesReadOnly forKey:_readOnlyKey];
        [[NSUserDefaults standardUserDefaults] setValue:labelText forKey:_readOnlyText];
        
    } else {
        _swatchesReadOnly = [[NSUserDefaults standardUserDefaults] boolForKey:_readOnlyKey];
        labelText = [[NSUserDefaults standardUserDefaults] stringForKey:_readOnlyText];
    }
    
    // Create the label and switch, set the last state or default values
    //
    _readOnlySwitch = [[UISwitch alloc] init];
    CGFloat switchHeight = _readOnlySwitch.bounds.size.height;
    CGFloat switchYOffset = (DEF_TABLE_CELL_HEIGHT - switchHeight) / 2;
    [_readOnlySwitch setFrame:CGRectMake(DEF_TABLE_X_OFFSET, switchYOffset, DEF_BUTTON_WIDTH, switchHeight)];
    [_readOnlySwitch setOn:_swatchesReadOnly];
    
    // Add the switch target
    //
    [_readOnlySwitch addTarget:self action:@selector(setROSwitchState:) forControlEvents:UIControlEventValueChanged];
    
    _readOnlyLabel   = [FieldUtils createLabel:labelText xOffset:DEF_BUTTON_WIDTH yOffset:DEF_Y_OFFSET];
    CGFloat labelWidth = _readOnlyLabel.bounds.size.width;
    CGFloat labelHeight = _readOnlyLabel.bounds.size.height;
    CGFloat labelYOffset = (DEF_TABLE_CELL_HEIGHT - labelHeight) / 2;
    [_readOnlyLabel  setFrame:CGRectMake(DEF_BUTTON_WIDTH + DEF_TABLE_X_OFFSET, labelYOffset, labelWidth, labelHeight)];
    
    
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Section
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    
    // Create No Save alert
    //
    _noSaveAlert = [AlertUtils createBlankAlert:@"Settings Not Saved" message:@"Continue without saving?"];
    
    UIAlertAction* YesButton = [UIAlertAction
                               actionWithTitle:@"Yes"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   [self dismissViewControllerAnimated:YES completion:nil];
                               }];
    
    UIAlertAction* NoButton = [UIAlertAction
                                   actionWithTitle:@"No"
                                   style:UIAlertActionStyleDefault
                                   handler:nil];
    
    [_noSaveAlert addAction:YesButton];
    [_noSaveAlert addAction:NoButton];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return SETTINGS_MAX_NUM_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    return DEF_TABLE_CELL_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell...
    //
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_reuseCellIdentifier forIndexPath:indexPath];
    
    // Global defaults
    //
    [cell setBackgroundColor:DARK_BG_COLOR];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [tableView setSeparatorColor:GRAY_BG_COLOR];
    [cell.imageView setImage:nil];
    [cell.textLabel setText:@""];
    
    // Name, and reference type
    //
    if (indexPath.section == SETTINGS_READ_ONLY_SECTION) {

        [cell.contentView addSubview:_readOnlySwitch];
        [cell.contentView addSubview:_readOnlyLabel];
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Widget states and Save

- (void)setROSwitchState:(id)sender {
    _swatchesReadOnly = [sender isOn];

    if (_swatchesReadOnly == TRUE) {
        [_readOnlyLabel setText:_makeReadWriteLabel];
        
    } else {
        [_readOnlyLabel setText:_makeReadOnlyLabel];
    }
    _editFlag = TRUE;
}

- (IBAction)save:(id)sender {
    
    NSError *error = nil;
    if (![self.context save:&error]) {
        NSLog(@"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
    } else {
        NSLog(@"Settings save successful");

        [[NSUserDefaults standardUserDefaults] setBool:_swatchesReadOnly forKey:_readOnlyKey];
        [[NSUserDefaults standardUserDefaults] setValue:[_readOnlyLabel text] forKey:_readOnlyText];
        
        _editFlag = FALSE;
    }
}


#pragma mark - Navigation

/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)goBack:(id)sender {
    
    // Leaving without saving?
    //
    if (_editFlag == TRUE) {
        [self presentViewController:_noSaveAlert animated:YES completion:nil];
        
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


@end
