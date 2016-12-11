//
//  AddMixViewController.m
//  AcrylicsColorPicker
//
//  Created by Stuart Pineo on 5/30/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//

#import "AddMixViewController.h"
#import "AssocTableViewController.h"
#import "GlobalSettings.h"
#import "ColorUtils.h"
#import "CoreDataUtils.h"
#import "PaintSwatches.h"
#import "BarButtonUtils.h"

@interface AddMixViewController ()

@end

@implementation AddMixViewController

//- (void)viewDidLoad {
//    [super viewDidLoad];
//
//    _paintSwatches    = [CoreDataUtils fetchPaintSwatches];
//    _addPaintSwatches = [[NSMutableArray alloc] init];
//    
//    [_addMixTableView setDelegate:self];
//    [_addMixTableView setDataSource:self];
//    
//    _reuseCellIdentifier = @"AddMixTableCell";
//    
//    // A few defaults
//    //
//    _defaultColor      = [GlobalSettings getDefaultColor];
//    _defaultBgColor    = [GlobalSettings getDefaultBgColor];
//    _defColorBorder    = [_defaultColor CGColor];
//    _defCellHeight     = [GlobalSettings getDefaultCellHeight];
//    _defaultFont       = [UIFont systemFontOfSize:12];
//}
//
//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}
//
///*
//#pragma mark - Navigation
//
//// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//}
//*/
//
//// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//// Tableview methods
//// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    NSLog(@"Returning sections...");
//    // Return the number of sections.
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    
//    // Return the number of rows in the section.
//    //
//    int objCount = (int)_paintSwatches.count;
//    return objCount;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_reuseCellIdentifier forIndexPath:indexPath];
//    
//    cell.imageView.frame = CGRectMake(5.0, 0.0, cell.bounds.size.height, cell.bounds.size.height);
//    cell.imageView.layer.borderColor = _defColorBorder;
//    cell.imageView.layer.borderWidth  = 1.0;
//    cell.imageView.layer.cornerRadius = 5.0;
//    
//    cell.imageView.contentMode   = UIViewContentModeScaleAspectFill;
//    cell.imageView.clipsToBounds = YES;
//    
//    if (_isRGB == FALSE) {
//        cell.imageView.image = [ColorUtils renderPaint:[_paintSwatches objectAtIndex:indexPath.row] image_thumb] cellWidth:cell.bounds.size.height cellHeight:cell.bounds.size.height];
//    } else {
//        cell.imageView.image = [ColorUtils renderRGB:_paintSwatches objectAtIndex:indexPath.row] cellWidth:cell.bounds.size.height cellHeight:cell.bounds.size.height];
//    }
//    
//    cell.accessoryType       = UITableViewCellSeparatorStyleNone;
//    if ([_paintSwatches[indexPath.row] is_selected] == TRUE) {
//        cell.accessoryType = UITableViewCellAccessoryCheckmark;
//    }
//    
//    cell.textLabel.text = [[_paintSwatches objectAtIndex:indexPath.row] name];
//    [cell.textLabel setFont:[UIFont systemFontOfSize:12]];
//    
//    [cell setBackgroundColor: [UIColor blackColor]];
//    cell.textLabel.textColor = _defaultColor;
//        
//    [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
//    
//    return cell;
//}
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    
//    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
//        cell.accessoryType = UITableViewCellAccessoryNone;
//        [_addPaintSwatches removeObject:_paintSwatches[indexPath.row]];
//    } else {
//        cell.accessoryType = UITableViewCellAccessoryCheckmark;
//        [_paintSwatches[indexPath.row] setIs_selected:TRUE];
//        [_addPaintSwatches addObject:_paintSwatches[indexPath.row]];
//    }
//    
////    NSArray *items = self.t
////    
////    int ct = [items count];
////    NSLog(@"Item Count %i", ct);
//    
//    if ([_addPaintSwatches count] > 0) {
//        [BarButtonUtils buttonEnabled:self.toolbarItems refTag:1 isEnabled:TRUE];
//    } else {
//        [BarButtonUtils buttonEnabled:self.toolbarItems refTag:1 isEnabled:FALSE];
//    }
//}
//
//// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//// SEARCH BAR methods
//// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
//- (IBAction)searchMix:(id)sender {
//    _mixSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(10, 10, 320, 50)];
//    _mixSearchBar.delegate = self;
//    
//    //    _titleView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 320, 50)];
//    //    [_titleView addSubview:_mixSearchBar];
//    
//    self.navigationItem.titleView = _mixSearchBar;
//    self.navigationItem.leftBarButtonItem = nil;
//    self.navigationItem.rightBarButtonItem = nil;
//}
//
//- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
////    searchBar.enablesReturnKeyAutomatically = YES;
////    [searchBar setShowsCancelButton:YES animated:YES];
//
//    _searchString = searchText;
//
//}
//
//// Need index of items that have been checked
////
//- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
//    
//    int count = (int)_paintSwatches.count;
//    
//    NSMutableArray *tmpPaintSwatches = [[NSMutableArray alloc] init];
//    
//    _searchMatch  = FALSE;
//
//    for (int i=0; i<count; i++) {
//        PaintSwatches *obj  = _paintSwatches[i];
//        NSString *matchName = obj.name;
//        
//        NSRange rangeValue = [matchName rangeOfString:_searchString options:NSCaseInsensitiveSearch];
//            
//        if (rangeValue.length > 0) {
//            _searchMatch = TRUE;
//            
//            [tmpPaintSwatches addObject:obj];
//        }
//    }
//    
//    _paintSwatches = tmpPaintSwatches;
//
//    [searchBar resignFirstResponder];
//    [searchBar setShowsCancelButton:NO animated:YES];
//    
//    [self.addMixTableView reloadData];
//    [self.addMixTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
//}
//
//
//- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
//    [searchBar setShowsCancelButton:YES animated:YES];
////    [self.addMixTableView reloadData];
////    [self.addMixTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
//}
//
//- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
//    searchBar.text = @"";
//    
//    _paintSwatches    = [CoreDataUtils fetchPaintSwatches];
//
//    [searchBar resignFirstResponder];
//    [searchBar setShowsCancelButton:NO animated:YES];
//    
//    [self.addMixTableView reloadData];
//    [self.addMixTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
//}

@end
