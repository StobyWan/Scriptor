//
//  SettingsViewController.m
//  Scriptor
//
//  Created by Bryan Stober on 1/19/14.
//  Copyright (c) 2014 Bryan Stober. All rights reserved.
//

#import "SettingsViewController.h"
#import "OSCDStackManager.h"
#import "Constants.h"

static const float ITEM_DEFAULT_MAX_HEIGHT = 400.0f;
static const int POPOVER_WIDTH = 335;
//static const int POPOVER_MAX_HEIGHT = 400;
static const int POPOVER_MIN_HEIGHT = 176;
static const float ktableRowHeight = 44.0f;

static  NSString *CellIndentifier = @"settingsCell";

@interface SettingsViewController ()
    
@property (nonatomic) int selectedIndexPath;
@property (retain, nonatomic) NSMutableArray *settings;
@end

@implementation SettingsViewController
    
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
    
- (void)setOptions:(NSArray *)options {
    if (_options != options) {
        _options = [NSArray arrayWithArray:options];
    }
}
    
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.viewState == @(SettingsFTPManager)) {
       
    }

    [self.tableView reloadData];
    
}
    
- (void)viewDidLoad {
    [super viewDidLoad];
	[self forcePopoverSize];
    if (!self.options) {
        _settingsArray = @[@"Color Scheme",@"Use iCloud",@"Make Backup"];//@"ftp://"
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    NSArray *array = @[
                       [[NSUserDefaults standardUserDefaults]  valueForKey:SETTINGS_FTP],
                       [[NSUserDefaults standardUserDefaults]  valueForKey:SETTINGS_FTP_USERNAME],
                       [[NSUserDefaults standardUserDefaults]  valueForKey:SETTINGS_FTP_PASSWORD]
                       ];
    self.settings = [NSMutableArray arrayWithArray:array];
    
}

- (void)saveText:(id)sender {
    [self textFieldDidEndEditing:self.activeTextField];
    [self.view endEditing:YES];
    if ([[[NSUserDefaults standardUserDefaults]  valueForKey:SETTINGS_FTP] isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc]  initWithTitle:@"Alert" message:@"Form incomplete" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    if ([[[NSUserDefaults standardUserDefaults]  valueForKey:SETTINGS_FTP_USERNAME] isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc]  initWithTitle:@"Alert" message:@"Form incomplete" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    if ([[[NSUserDefaults standardUserDefaults]  valueForKey:SETTINGS_FTP_PASSWORD] isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc]  initWithTitle:@"Alert" message:@"Form incomplete" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
    
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (!self.options) {
        if (indexPath.row == SettingsColorScheme) {
            NSString *bPath = [NSBundle mainBundle].bundlePath;
            NSString *settingsPath = [bPath stringByAppendingPathComponent:@"Settings.bundle"];
            NSString *plistFile = [settingsPath stringByAppendingPathComponent:@"Root.plist"];
            NSDictionary *settingsDictionary = [NSDictionary dictionaryWithContentsOfFile:plistFile];
            NSArray *preferencesArray = settingsDictionary[@"PreferenceSpecifiers"];
            NSArray *titles = preferencesArray[0][@"Titles"];
            SettingsViewController *settingsSelection = [self.storyboard instantiateViewControllerWithIdentifier:@"SETTINGSVIEW"];
            [self.navigationController pushViewController:settingsSelection animated:YES];
            settingsSelection.options = titles;
            settingsSelection.viewState = @(SettingsColorScheme);
            settingsSelection.selectedOption = [[NSUserDefaults standardUserDefaults] valueForKey:SETTINGS_COLOR_SCHEME_KEY];
        }
        else if(indexPath.row == SettingsFTPManager){
            SettingsViewController *settingsSelection = [self.storyboard instantiateViewControllerWithIdentifier:@"SETTINGSVIEW"];
            settingsSelection.options = @[@"ftp://",@"Username",@"Password"];
            settingsSelection.viewState = @(SettingsFTPManager);
            settingsSelection.selectedOption = [[NSUserDefaults standardUserDefaults] valueForKey:SETTINGS_COLOR_SCHEME_KEY];
            UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(saveText:)];
            settingsSelection.navigationItem.rightBarButtonItem = done;
            [self.navigationController pushViewController:settingsSelection animated:YES];
        }
    }
    else{
        if (self.viewState == @(SettingsColorScheme)) {
            self.selectedIndexPath = indexPath.row;
            [[NSUserDefaults standardUserDefaults] setValue:(self.options)[indexPath.row] forKey:SETTINGS_COLOR_SCHEME_KEY];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [tableView reloadData];
        }
        else if(self.viewState == @(SettingsFTPManager)){
            
        }
        
    }
}
    
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!self.options) {
        return self.settingsArray.count;
    }
    else {
        return self.options.count;
    }
    
}
    
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIndentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIndentifier];
    }
    if (!self.options) {
        UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
        switchView.tag = indexPath.row;
        
        if(indexPath.row == SettingsColorScheme){
            switchView.hidden = YES;
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, 100, 30)];
            label.textAlignment = NSTextAlignmentRight;
            cell.accessoryView = label;
            label.text = [[NSUserDefaults standardUserDefaults] valueForKey:SETTINGS_COLOR_SCHEME_KEY];
            cell.textLabel.text = (self.settingsArray)[indexPath.row];
            
        }else if (indexPath.row == SettingUseIcloud) {
            cell.accessoryView = switchView;
            [switchView setOn:[[NSUserDefaults standardUserDefaults] boolForKey:SETTINGS_USE_ICLOUD_KEY] animated:NO];
            [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
            cell.textLabel.text = (self.settingsArray)[indexPath.row];
        }else if(indexPath.row == SettingMakeBackup){
            cell.accessoryView = switchView;
            [switchView setOn:[[NSUserDefaults standardUserDefaults] boolForKey:SETTINGS_MAKE_BACKUP_KEY] animated:NO];
            [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
            cell.textLabel.text = (self.settingsArray)[indexPath.row];
        }else if(indexPath.row == SettingsFTPManager){
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 34)];
            label.textAlignment = NSTextAlignmentRight;
            cell.accessoryView = label;
            label.text = [[NSUserDefaults standardUserDefaults] valueForKey:SETTINGS_FTP];
            cell.textLabel.text = (self.settingsArray)[indexPath.row];
        }
        
    }
    else{
        if (self.viewState == @(SettingsColorScheme)) {
            if ([(self.options)[indexPath.row] isEqualToString:[[NSUserDefaults standardUserDefaults] valueForKey:SETTINGS_COLOR_SCHEME_KEY]]) {
                self.selectedIndexPath = indexPath.row;
                if(indexPath.row == self.selectedIndexPath){
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
            }
            else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            cell.textLabel.text = (self.options)[indexPath.row];
        }
        else if(self.viewState == @(SettingsFTPManager)){
            UITextField *ftpTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 200, 34)];
            ftpTextField.borderStyle = UITextBorderStyleRoundedRect;
            ftpTextField.tag = indexPath.row;
            ftpTextField.delegate = self;
            ftpTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            ftpTextField.keyboardAppearance = UIKeyboardAppearanceDark;
            if (indexPath.row == 0) {
                ftpTextField.keyboardType = UIKeyboardTypeURL;
            }else if(indexPath.row == 1){
                
            }else if(indexPath.row == 2){
                ftpTextField.secureTextEntry = YES;
            }
            ftpTextField.text = (self.settings)[indexPath.row];
            cell.accessoryView = ftpTextField;
            cell.textLabel.text = (self.options)[indexPath.row];
        }
    }
    return cell;
}
    
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ktableRowHeight;
}
    
- (void)switchChanged:(UISwitch*)sender {
    
    switch (sender.tag) {
        case SettingsColorScheme:
        
        break;
        case SettingUseIcloud:
        [[NSUserDefaults standardUserDefaults] setBool:sender.isOn forKey:SETTINGS_USE_ICLOUD_KEY];
        [OSCDStackManager sharedManager].isCloudEnabled = sender.isOn;
        break;
        case SettingMakeBackup:
        [[NSUserDefaults standardUserDefaults] setBool:sender.isOn forKey:SETTINGS_MAKE_BACKUP_KEY];
        if (sender.isOn) {
            [[OSCDStackManager sharedManager] backupCurrentStore];
            UIAlertView *alert =[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"settings_vc_alert_title_backup", @"Back Up Succesful")  message:NSLocalizedString(@"settings_vc_alert_message_backup", @"Your data has been backed up")  delegate:nil cancelButtonTitle:NSLocalizedString(@"master_vc_ok", @"Ok")  otherButtonTitles:nil, nil];
            [alert show];
        }
        break;
        default:
        break;
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}
    
- (void)forcePopoverSize {
    self.preferredContentSize = CGSizeMake(POPOVER_WIDTH, [self heightForTableWithinPopoverWithMaxiumumHeight:ITEM_DEFAULT_MAX_HEIGHT]);;
}
    
- (float)rowHeight {
    return ktableRowHeight;
}
    
- (float)heightForTableWithinPopoverWithMaxiumumHeight:(float)maxHeight {
    
    float height = (float)([self rowHeight] * [self tableView:self.tableView numberOfRowsInSection:0]);
    if (height > maxHeight) {
        height = maxHeight;
        self.tableView.scrollEnabled= YES;
    }
    else if (height < POPOVER_MIN_HEIGHT) {
        
        height = POPOVER_MIN_HEIGHT;
    }
    
    return  height;
}
#pragma mark - UITextField Delegates

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
     self.activeTextField = textField;
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSLog(@"%@ - %d",textField.text,textField.tag);
    if (textField !=nil) {
    (self.settings)[textField.tag] = textField.text;   
    switch (textField.tag) {
        case 0:
            [[NSUserDefaults standardUserDefaults] setValue:textField.text forKey:SETTINGS_FTP];
            break;
        case 1:
            [[NSUserDefaults standardUserDefaults] setValue:textField.text forKey:SETTINGS_FTP_USERNAME];
            break;
        case 2:
            [[NSUserDefaults standardUserDefaults] setValue:textField.text forKey:SETTINGS_FTP_PASSWORD];
            break;
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
 }
    [self.view endEditing:YES];
}

#pragma mark - Responding to keyboard events

- (void)keyboardWillShow:(NSNotification *)notification {
    const NSDictionary *const userInfo = notification.userInfo;
    
//    CGRect keyboardRect = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
//    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    NSTimeInterval animationDuration;
    [userInfo[UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    const NSDictionary *const userInfo = notification.userInfo;
    
    NSTimeInterval animationDuration;
    [userInfo[UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    
}

- (IBAction)closeModal:(UIBarButtonItem *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
