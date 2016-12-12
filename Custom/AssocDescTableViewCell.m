//
//  AssocTableViewCell.m
//  AcrylicsColorPicker
//
//  Created by Stuart Pineo on 4/18/15.
//  Copyright (c) 2015 Stuart Pineo. All rights reserved.
//

#import "AssocDescTableViewCell.h"
#import "GlobalSettings.h"

@interface AssocDescTableViewCell()

@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) UILabel *mainLabel;
//@property (nonatomic, strong) UIAlertView *noTextAlert;

@end

@implementation AssocDescTableViewCell

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
        
        CGSize size   = self.contentView.frame.size;
        CGFloat xpos   = 5.0;
    
        _descField = [[UITextField alloc] initWithFrame:CGRectMake(xpos, 5.0, size.width - 5.0, size.height - 10.0)];
        
        [_descField setBackgroundColor: LIGHT_BG_COLOR];
     
        [_descField.layer setCornerRadius: DEF_CORNER_RADIUS];
        [_descField.layer setBorderWidth: DEF_BORDER_WIDTH];
        
//        [_descField setTag: DEF_TAG_NUM];
        
        [_descField setTextAlignment:NSTextAlignmentLeft];
        [_descField setFont: TEXT_FIELD_FONT];
        [_descField setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];


        [self.contentView addSubview:_descField];
        
        // Textfields
        //
        [_descField setUserInteractionEnabled: YES];
        [_descField setDelegate:self];
    }

    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

// Textfields
//
- (void)textFieldDidBeginEditing:(UITextField *)textField {
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    _textEntered = textField.text;
    _textReturn  = TRUE;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


@end
