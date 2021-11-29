//
//  SettingsViewController.h
//  Scriptor
//
//  Created by Bryan Stober on 1/19/14.
//  Copyright (c) 2014 Bryan Stober. All rights reserved.
//

#import <UIKit/UIKit.h>

enum SettingType : NSInteger {
    SettingsColorScheme= 0,
    SettingUseIcloud = 1,
    SettingMakeBackup = 2,
    SettingsFTPManager = 3
    
};

@interface SettingsViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *settingsArray;
@property (strong, nonatomic) NSArray *options;
@property (strong, nonatomic) NSString *selectedOption;
@property (strong, nonatomic) NSNumber *viewState;
@property (strong, nonatomic) UITextField *activeTextField;

- (IBAction)closeModal:(UIBarButtonItem *)sender;

@end
