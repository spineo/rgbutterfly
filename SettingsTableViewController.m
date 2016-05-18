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
#import "ManagedObjectUtils.h"

@interface SettingsTableViewController ()

@property (nonatomic, strong) UILabel *psReadOnlyLabel, *maReadOnlyLabel;
@property (nonatomic, strong) UISwitch *psReadOnlySwitch, *maReadOnlySwitch;
@property (nonatomic) BOOL editFlag, swatchesReadOnly, assocsReadOnly;
@property (nonatomic, strong) NSString *reuseCellIdentifier, *psReadOnlyKey, *psReadOnlyText, *psMakeReadOnlyLabel, *psMakeReadWriteLabel, *maReadOnlyKey, *maReadOnlyText, *maMakeReadOnlyLabel, *maMakeReadWriteLabel;
@property (nonatomic, strong) UIAlertController *noSaveAlert;

// NSManagedObject
//
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSEntityDescription *paintSwatchEntity, *mixAssocEntity;

@end

@implementation SettingsTableViewController

const int PSWATCH_READ_ONLY_SECTION  = 0;
const int MIXASSOC_READ_ONLY_SECTION = 1;
const int SETTINGS_MAX_NUM_SECTIONS  = 2;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _editFlag = FALSE;
    _reuseCellIdentifier = @"SettingsTableCell";
    
    // NSManagedObject
    //
    self.appDelegate = [[UIApplication sharedApplication] delegate];
    self.context     = [self.appDelegate managedObjectContext];
    
    _paintSwatchEntity = [NSEntityDescription entityForName:@"PaintSwatch"    inManagedObjectContext:self.context];
    _mixAssocEntity    = [NSEntityDescription entityForName:@"MixAssociation" inManagedObjectContext:self.context];


    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Swatches Read-Only Section
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Check for the default values
    //
    _psReadOnlyKey = @"swatches_read_only";
    _psReadOnlyText = @"swatches_read_only_text";
    
    _psMakeReadOnlyLabel  = @"Make My Paint Swatches Read-Only";
    _psMakeReadWriteLabel = @"Make My Paint Swatches Read/Write";
    
    NSString *labelText;
    if(! ([[NSUserDefaults standardUserDefaults] boolForKey:_psReadOnlyKey] &&
          [[NSUserDefaults standardUserDefaults] stringForKey:_psReadOnlyText])
       ) {
        _swatchesReadOnly = FALSE;
        labelText = _psMakeReadOnlyLabel;
        
        [[NSUserDefaults standardUserDefaults] setBool:_swatchesReadOnly forKey:_psReadOnlyKey];
        [[NSUserDefaults standardUserDefaults] setValue:labelText forKey:_psReadOnlyText];
        
    } else {
        _swatchesReadOnly = [[NSUserDefaults standardUserDefaults] boolForKey:_psReadOnlyKey];
        labelText = [[NSUserDefaults standardUserDefaults] stringForKey:_psReadOnlyText];
    }
    
    // Create the label and switch, set the last state or default values
    //
    _psReadOnlySwitch = [[UISwitch alloc] init];
    CGFloat switchHeight = _psReadOnlySwitch.bounds.size.height;
    CGFloat switchYOffset = (DEF_TABLE_CELL_HEIGHT - switchHeight) / 2;
    [_psReadOnlySwitch setFrame:CGRectMake(DEF_TABLE_X_OFFSET, switchYOffset, DEF_BUTTON_WIDTH, switchHeight)];
    [_psReadOnlySwitch setOn:_swatchesReadOnly];
    
    // Add the switch target
    //
    [_psReadOnlySwitch addTarget:self action:@selector(setPSSwitchState:) forControlEvents:UIControlEventValueChanged];
    
    _psReadOnlyLabel   = [FieldUtils createLabel:labelText xOffset:DEF_BUTTON_WIDTH yOffset:DEF_Y_OFFSET];
    CGFloat labelWidth = _psReadOnlyLabel.bounds.size.width;
    CGFloat labelHeight = _psReadOnlyLabel.bounds.size.height;
    CGFloat labelYOffset = (DEF_TABLE_CELL_HEIGHT - labelHeight) / 2;
    [_psReadOnlyLabel  setFrame:CGRectMake(DEF_BUTTON_WIDTH + DEF_TABLE_X_OFFSET, labelYOffset, labelWidth, labelHeight)];
    
    
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // MixAssociation Read-Only Section
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Check for the default values
    //
    _maReadOnlyKey = @"assoc_read_only";
    _maReadOnlyText = @"assoc_read_only_text";
    
    _maMakeReadOnlyLabel  = @"Make My Mix Associations Read-Only";
    _maMakeReadWriteLabel = @"Make My Mix Associations Read/Write";
    
    labelText = @"";
    if(! ([[NSUserDefaults standardUserDefaults] boolForKey:_maReadOnlyKey] &&
          [[NSUserDefaults standardUserDefaults] stringForKey:_maReadOnlyText])
       ) {
        _assocsReadOnly = FALSE;
        labelText = _maMakeReadOnlyLabel;
        
        [[NSUserDefaults standardUserDefaults] setBool:_assocsReadOnly forKey:_maReadOnlyKey];
        [[NSUserDefaults standardUserDefaults] setValue:labelText forKey:_maReadOnlyText];
        
    } else {
        _assocsReadOnly = [[NSUserDefaults standardUserDefaults] boolForKey:_maReadOnlyKey];
        labelText = [[NSUserDefaults standardUserDefaults] stringForKey:_maReadOnlyText];
    }
    
    // Create the label and switch, set the last state or default values
    //
    _maReadOnlySwitch = [[UISwitch alloc] init];
    switchHeight = _maReadOnlySwitch.bounds.size.height;
    switchYOffset = (DEF_TABLE_CELL_HEIGHT - switchHeight) / 2;
    [_maReadOnlySwitch setFrame:CGRectMake(DEF_TABLE_X_OFFSET, switchYOffset, DEF_BUTTON_WIDTH, switchHeight)];
    [_maReadOnlySwitch setOn:_assocsReadOnly];
    
    // Add the switch target
    //
    [_maReadOnlySwitch addTarget:self action:@selector(setMASwitchState:) forControlEvents:UIControlEventValueChanged];
    
    _maReadOnlyLabel   = [FieldUtils createLabel:labelText xOffset:DEF_BUTTON_WIDTH yOffset:DEF_Y_OFFSET];
    labelWidth = _maReadOnlyLabel.bounds.size.width;
    labelHeight = _maReadOnlyLabel.bounds.size.height;
    labelYOffset = (DEF_TABLE_CELL_HEIGHT - labelHeight) / 2;
    [_maReadOnlyLabel  setFrame:CGRectMake(DEF_BUTTON_WIDTH + DEF_TABLE_X_OFFSET, labelYOffset, labelWidth, labelHeight)];
    
    
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
    if (indexPath.section == PSWATCH_READ_ONLY_SECTION) {
        [cell.contentView addSubview:_psReadOnlySwitch];
        [cell.contentView addSubview:_psReadOnlyLabel];
        
    } else if (indexPath.section == MIXASSOC_READ_ONLY_SECTION) {
        [cell.contentView addSubview:_maReadOnlySwitch];
        [cell.contentView addSubview:_maReadOnlyLabel];
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

- (void)setPSSwitchState:(id)sender {
    _swatchesReadOnly = [sender isOn];

    if (_swatchesReadOnly == TRUE) {
        [_psReadOnlyLabel setText:_psMakeReadWriteLabel];
        
    } else {
        [_psReadOnlyLabel setText:_psMakeReadOnlyLabel];
    }
    _editFlag = TRUE;
}

- (void)setMASwitchState:(id)sender {
    _assocsReadOnly = [sender isOn];
    
    if (_assocsReadOnly == TRUE) {
        [_maReadOnlyLabel setText:_maMakeReadWriteLabel];
        
    } else {
        [_maReadOnlyLabel setText:_maMakeReadOnlyLabel];
    }
    _editFlag = TRUE;
}

- (IBAction)save:(id)sender {
    
    [ManagedObjectUtils setEntityReadOnly:@"PaintSwatch" isReadOnly:_swatchesReadOnly context:self.context];
    [ManagedObjectUtils setEntityReadOnly:@"MixAssociation" isReadOnly:_assocsReadOnly context:self.context];
    
    NSError *error = nil;
    if (![self.context save:&error]) {
        NSLog(@"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
    } else {
        NSLog(@"Settings save successful");

        [[NSUserDefaults standardUserDefaults] setBool:_swatchesReadOnly forKey:_psReadOnlyKey];
        [[NSUserDefaults standardUserDefaults] setValue:[_psReadOnlyLabel text] forKey:_psReadOnlyText];
        
        [[NSUserDefaults standardUserDefaults] setBool:_assocsReadOnly forKey:_maReadOnlyKey];
        [[NSUserDefaults standardUserDefaults] setValue:[_maReadOnlyLabel text] forKey:_maReadOnlyText];
        
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
