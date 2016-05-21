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

@property (nonatomic, strong) UILabel *psReadOnlyLabel, *maReadOnlyLabel, *tapSettingsLabel, *stepperLabel;
@property (nonatomic, strong) UISwitch *psReadOnlySwitch, *maReadOnlySwitch;
@property (nonatomic) BOOL editFlag, swatchesReadOnly, assocsReadOnly;
@property (nonatomic, strong) NSString *reuseCellIdentifier, *psReadOnlyText, *psMakeReadOnlyLabel, *psMakeReadWriteLabel, *maReadOnlyText, *maMakeReadOnlyLabel, *maMakeReadWriteLabel, *shapeGeom;
@property (nonatomic) CGFloat tapAreaSize;
@property (nonatomic, strong) UIImageView *tapImageView;
@property (nonatomic, strong) UIAlertController *noSaveAlert;

// NSManagedObject
//
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSEntityDescription *paintSwatchEntity, *mixAssocEntity;

@end

@implementation SettingsTableViewController


// Section 1: READ-ONLY Settings
//
const int READ_ONLY_SETTINGS      = 0;
const int PSWATCH_READ_ONLY_ROW   = 0;
const int MIXASSOC_READ_ONLY_ROW  = 1;
const int READ_ONLY_SETTINGS_ROWS = 2;

const int TAP_AREA_SETTINGS       = 1;
const int TAP_AREA_ROW            = 0;
const int TAP_AREA_ROWS           = 1;

const int SETTINGS_MAX_SECTIONS   = 2;

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
    // Swatches Read-Only Row
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Check for the default values
    //
    _psReadOnlyText = @"swatches_read_only_text";
    
    _psMakeReadOnlyLabel  = @"Make My Paint Swatches Read-Only";
    _psMakeReadWriteLabel = @"Make My Paint Swatches Read/Write";
    
    NSString *labelText;
    if(! ([[NSUserDefaults standardUserDefaults] boolForKey:PAINT_SWATCH_RO_KEY] &&
          [[NSUserDefaults standardUserDefaults] stringForKey:_psReadOnlyText])
       ) {
        _swatchesReadOnly = FALSE;
        labelText = _psMakeReadOnlyLabel;
        
        [[NSUserDefaults standardUserDefaults] setBool:_swatchesReadOnly forKey:PAINT_SWATCH_RO_KEY];
        [[NSUserDefaults standardUserDefaults] setValue:labelText forKey:_psReadOnlyText];
        
    } else {
        _swatchesReadOnly = [[NSUserDefaults standardUserDefaults] boolForKey:PAINT_SWATCH_RO_KEY];
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
    // MixAssociation Read-Only Row
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Check for the default values
    //
    _maReadOnlyText = @"assoc_read_only_text";
    
    _maMakeReadOnlyLabel  = @"Make My Mix Associations Read-Only";
    _maMakeReadWriteLabel = @"Make My Mix Associations Read/Write";
    
    labelText = @"";
    if(! ([[NSUserDefaults standardUserDefaults] boolForKey:MIX_ASSOC_RO_KEY] &&
          [[NSUserDefaults standardUserDefaults] stringForKey:_maReadOnlyText])
       ) {
        _assocsReadOnly = FALSE;
        labelText = _maMakeReadOnlyLabel;
        
        [[NSUserDefaults standardUserDefaults] setBool:_assocsReadOnly forKey:MIX_ASSOC_RO_KEY];
        [[NSUserDefaults standardUserDefaults] setValue:labelText forKey:_maReadOnlyText];
        
    } else {
        _assocsReadOnly = [[NSUserDefaults standardUserDefaults] boolForKey:MIX_ASSOC_RO_KEY];
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
    
    
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Tap Area Widgets
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    // Sizing parameters
    //
    _tapAreaSize = [[NSUserDefaults standardUserDefaults] floatForKey:TAP_AREA_SIZE_KEY];
    if (! _tapAreaSize) {
        _tapAreaSize = DEF_TAP_AREA_SIZE;
        [[NSUserDefaults standardUserDefaults] setFloat:DEF_TAP_AREA_SIZE forKey:TAP_AREA_SIZE_KEY];
    }
    
//    CGFloat viewHeight     = (_tapAreaSize * 2) + _sizePadding * 2;
//    CGFloat stepperOffsetX = 80.0;
//    CGFloat stepperOffsetY = _sizePadding + (_tapAreaSize / 2) - 13.0;
//    CGFloat shapeOffsetX   = 190.0;
//    CGFloat shapeOffsetY  = _sizePadding + (_tapAreaSize / 2) - 11.0;
//    
//    
//    // Creat the alertView main frame (to contain the imageView, stepper, and stepper label)
//    //
//    _rgbMainView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 0.0, viewHeight)];
//    [_rgbMainView setBackgroundColor: DARK_BG_COLOR];
//    
//    
//    // UIImageView (represents the current tap area)
//    //
//    [self setOffsetY: _sizePadding];
    
    _tapSettingsLabel = [FieldUtils createLabel:@"Change the size/shape of the tap area."];
    
    _tapImageView = [[UIImageView alloc] init];
    [_tapImageView setBackgroundColor:LIGHT_BG_COLOR];

    // Set the default
    //
    _shapeGeom = [[NSUserDefaults standardUserDefaults] stringForKey:SHAPE_GEOMETRY_KEY];
    if (! _shapeGeom) {
        _shapeGeom = SHAPE_CIRCLE_VALUE;
    }
    
    if ([_shapeGeom isEqualToString:SHAPE_CIRCLE_VALUE]) {
        [_tapImageView.layer setCornerRadius:_tapAreaSize / 2.0];
        [_tapImageView.layer setBorderWidth:DEF_BORDER_WIDTH];
        
    // Rectangle
    //
    } else {
        [_tapImageView.layer setCornerRadius:CORNER_RADIUS_NONE];
        [_tapImageView.layer setBorderWidth:DEF_BORDER_WIDTH];
    }
    [_tapImageView.layer setBorderColor:[LIGHT_BORDER_COLOR CGColor]];
    
//
//    // Label displaying the value in the stepper
//    //
    int size = (int)_tapAreaSize;
    _stepperLabel = [FieldUtils createLabel:[[NSString alloc] initWithFormat:@"%i", size]];
    [_stepperLabel setTextColor:DARK_TEXT_COLOR];
    [_stepperLabel setBackgroundColor:CLEAR_COLOR];
    [_stepperLabel setTextAlignment:NSTextAlignmentCenter];
    
    //[_tapImageView addSubview:_stepperLabel];
    
    
//    // UIStepper (change the size of the tapping area)
//    //
//    _tapAreaStepper = [[UIStepper alloc] initWithFrame:CGRectMake(stepperOffsetX, stepperOffsetY, _tapAreaSize, _tapAreaSize)];
//    [_tapAreaStepper setTintColor: LIGHT_TEXT_COLOR];
//    [_tapAreaStepper addTarget:self action:@selector(tapAreaStepperPressed) forControlEvents:UIControlEventValueChanged];
//    
//    
//    // Set min, max, step, and default values and wraps parameter
//    //
//    [_tapAreaStepper setMinimumValue:_stepMinVal];
//    [_tapAreaStepper setMaximumValue:_stepMaxVal];
//    [_tapAreaStepper setStepValue:_stepIncVal];
//    [_tapAreaStepper setValue:_tapAreaSize];
//    [_tapAreaStepper setWraps:NO];
//    
//    
//    // Create the Match Num Stepper
//    //
//    CGFloat matchNumYOffset = stepperOffsetY + _tapAreaSize + DEF_FIELD_PADDING;
//    _matchNumLabel = [FieldUtils createLabel:@"Match #" xOffset:_imageViewXOffset yOffset:matchNumYOffset];
//    [_matchNumLabel setFont: TEXT_LABEL_FONT];
//    
//    _matchNumStepper = [[UIStepper alloc] initWithFrame:CGRectMake(stepperOffsetX, matchNumYOffset, _tapAreaSize, _tapAreaSize)];
//    [_matchNumStepper setTintColor: LIGHT_TEXT_COLOR];
//    [_matchNumStepper addTarget:self action:@selector(matchNumStepperPressed) forControlEvents:UIControlEventValueChanged];
//    
//    // Set min, max, step, and default values and wraps parameter
//    //
//    [_matchNumStepper setMinimumValue:_matchStepMinVal];
//    [_matchNumStepper setMaximumValue:_matchStepMaxVal];
//    [_matchNumStepper setStepValue:_matchStepIncVal];
//    [_matchNumStepper setValue:_maxMatchNum];
//    [_matchNumStepper setWraps:NO];
//    
//    
//    _matchNumTextField = [FieldUtils createTextField:[[NSString alloc] initWithFormat:@"%i", _maxMatchNum] tag: INCR_ALG_BTN_TAG];
//    [_matchNumTextField setFrame:CGRectMake(shapeOffsetX, matchNumYOffset, DEF_SM_TXTFIELD_WIDTH, DEF_TEXTFIELD_HEIGHT)];
//    [_matchNumTextField setAutoresizingMask: NO];
//    [_matchNumTextField setKeyboardType: UIKeyboardTypeNumberPad];
//    [_matchNumTextField setTag: MATCH_NUM_TAG];
//    [_matchNumTextField setDelegate:self];
//    
//    
//    // Initialize the shape
//    //
//    if ([_shapeGeom isEqualToString:_circleLabel]) {
//        [self setShapeTitle: _rectLabel];
//    } else {
//        [self setShapeTitle: _circleLabel];
//    }
//    
//    CGRect buttonFrame = CGRectMake(shapeOffsetX, shapeOffsetY, DEF_BUTTON_WIDTH, DEF_BUTTON_HEIGHT);
//    _shape = [BarButtonUtils create3DButton:_shapeTitle tag: SHAPE_BUTTON_TAG frame: buttonFrame];
//    [_shape addTarget:self action:@selector(changeShape) forControlEvents:UIControlEventTouchUpInside];
//    
//    [_rgbMainView addSubview:_tapImageView];
//    [_rgbMainView addSubview:_tapAreaStepper];
//    [_rgbMainView addSubview:_shape];
//    
//    [_rgbMainView addSubview:_matchNumLabel];
//    [_rgbMainView addSubview:_matchNumStepper];
//    [_rgbMainView addSubview:_matchNumTextField];
    

    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Create No Save alert
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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
    return SETTINGS_MAX_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == READ_ONLY_SETTINGS) {
        return READ_ONLY_SETTINGS_ROWS;
        
    } else if (section == TAP_AREA_SETTINGS) {
        return TAP_AREA_ROWS;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.section == TAP_AREA_SETTINGS) {
        return DEF_VLG_TBL_CELL_HGT;
        
    } else {
        return DEF_TABLE_CELL_HEIGHT;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *headerStr;
    if (section == READ_ONLY_SETTINGS) {
        headerStr = @"Read-Only Settings";
        
    } else if (section == TAP_AREA_SETTINGS) {
        headerStr = @"Tap Area Settings";
    }
    return headerStr;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    
//    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(DEF_X_OFFSET, DEF_Y_OFFSET, tableView.bounds.size.width, DEF_TABLE_HDR_HEIGHT)];
//    [headerView setBackgroundColor: DARK_BG_COLOR];
//    
//    [headerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth |
//     UIViewAutoresizingFlexibleLeftMargin |
//     UIViewAutoresizingFlexibleRightMargin];
//    
//    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(DEF_X_OFFSET, DEF_Y_OFFSET+1.0, tableView.bounds.size.width, DEF_TABLE_HDR_HEIGHT-2.0)];
//    [headerLabel setBackgroundColor: DARK_BG_COLOR];
//    [headerLabel setTextColor: LIGHT_TEXT_COLOR];
//    [headerLabel setFont: TABLE_HEADER_FONT];
//    
//    [headerLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth |
//     UIViewAutoresizingFlexibleLeftMargin |
//     UIViewAutoresizingFlexibleRightMargin];
//        
//    if (section == TAP_AREA_SETTINGS) {
//        [headerView addSubview:headerLabel];
//        [headerLabel setText:@"Change the size and/or shape of the tap area."];
//        [headerLabel setTextAlignment: NSTextAlignmentCenter];
//    }
//    
//    return headerView;
//}


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
    [cell.textLabel setFont:TABLE_CELL_FONT];
    [cell.textLabel setTextColor:LIGHT_TEXT_COLOR];
    [cell.imageView setImage:nil];
    [cell.textLabel setText:@""];
    
    if (indexPath.section == READ_ONLY_SETTINGS) {
    
        // Name, and reference type
        //
        if (indexPath.row == PSWATCH_READ_ONLY_ROW) {
            [cell.contentView addSubview:_psReadOnlySwitch];
            [cell.contentView addSubview:_psReadOnlyLabel];
            
        } else if (indexPath.row == MIXASSOC_READ_ONLY_ROW) {
            [cell.contentView addSubview:_maReadOnlySwitch];
            [cell.contentView addSubview:_maReadOnlyLabel];
        }
        
    } else if (indexPath.section == TAP_AREA_SETTINGS) {
        [_tapSettingsLabel setFrame:CGRectMake(DEF_TABLE_X_OFFSET, DEF_Y_OFFSET, self.tableView.bounds.size.width, DEF_LABEL_HEIGHT)];
        [cell.contentView addSubview:_tapSettingsLabel];
        
        [_tapImageView setFrame:CGRectMake(DEF_TABLE_X_OFFSET, _tapSettingsLabel.bounds.size.height + DEF_FIELD_PADDING, _tapAreaSize, _tapAreaSize)];
        [cell.contentView addSubview:_tapImageView];
        
        [_stepperLabel setFrame:CGRectMake(DEF_TABLE_X_OFFSET, _tapSettingsLabel.bounds.size.height + DEF_FIELD_PADDING, _tapAreaSize, _tapAreaSize)];
        [cell.contentView addSubview:_stepperLabel];
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

        [[NSUserDefaults standardUserDefaults] setBool:_swatchesReadOnly forKey:PAINT_SWATCH_RO_KEY];
        [[NSUserDefaults standardUserDefaults] setValue:[_psReadOnlyLabel text] forKey:_psReadOnlyText];
        
        [[NSUserDefaults standardUserDefaults] setBool:_assocsReadOnly forKey:MIX_ASSOC_RO_KEY];
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
