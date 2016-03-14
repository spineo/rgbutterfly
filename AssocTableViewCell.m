//
//  AssocTableViewCell.m
//  AcrylicsColorPicker
//
//  Created by Stuart Pineo on 4/18/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//

#import "AssocTableViewCell.h"
#import "GlobalSettings.h"
#import "AlertUtils.h"

@interface AssocTableViewCell()

@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) UITextField *mixName;
@property (nonatomic, strong) UILabel *mainLabel;
@property (nonatomic, strong) UIAlertView *noTextAlert;

@end

@implementation AssocTableViewCell

- (void)awakeFromNib {
    // Initialization code
    //
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {

    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if (self) {
        _textReturn    = FALSE;
        _textEntered   = @"";
    
        [self setBackgroundColor: CLEAR_COLOR];
        
        CGSize size    = self.contentView.frame.size;
        CGFloat xpos   = DEF_TABLE_CELL_HEIGHT+ 22.0;
    
        _mixName = [[UITextField alloc] initWithFrame:CGRectMake(xpos, 5.0, size.width - (size.width / 4.0), size.height - 10.0)];
        
        [_mixName setBackgroundColor: LIGHT_BG_COLOR];
        [_mixName setTextColor: DARK_TEXT_COLOR];
     
        [_mixName.layer setCornerRadius: DEF_CORNER_RADIUS];
        [_mixName.layer setBorderWidth: DEF_BORDER_WIDTH];
        [_mixName setTag: DEF_TAG_NUM];
        [_mixName setTextAlignment:NSTextAlignmentLeft];
        [_mixName setFont: TEXT_FIELD_FONT];
        
        UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 5.0, self.frame.size.height)];
        _mixName.leftView = paddingView;
        _mixName.leftViewMode = UITextFieldViewModeAlways;

        [_mixName setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
        [_mixName setClearButtonMode: UITextFieldViewModeWhileEditing];

        [self.contentView addSubview:_mixName];
        
        // Textfields
        //
        [_mixName setUserInteractionEnabled: YES];
//        [_mixName addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
        [_mixName setDelegate:self];
        
        // Tap size Alert View
        //
        _noTextAlert = [[UIAlertView alloc] initWithTitle:@"No Color Name Entered"
                                            message:@"Please enter a primary, mix, or primary + color name."
                                            delegate:self
                                            cancelButtonTitle:@"Ok"
                                            otherButtonTitles: nil];
        [_noTextAlert setTintColor: DARK_TEXT_COLOR];
        
//        _noTextAlert = [AlertUtils createOkAlert:@"Error" message:@"Device has no camera"];
//        [_presentingViewController presentViewController:_noTextAlert animated:YES completion:nil];
    }

    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

// Minimize keyboard
//
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    [_mixName resignFirstResponder];
//}


- (void)textFieldDidBeginEditing:(UITextField *)textField {
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([textField.text isEqualToString:@""]) {
        [_noTextAlert show];
        
    } else {
        _textEntered = textField.text;
        _textReturn  = TRUE;
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

@end
