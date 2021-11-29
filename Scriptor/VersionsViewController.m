//
//  ScriptPopoverViewController.m
//  Scriptor
//
//  Created by Bryan Stober on 1/6/14.
//  Copyright (c) 2014 Bryan Stober. All rights reserved.
//

#import "VersionsViewController.h"
#import "Framework.h"
#import "Version.h"

@interface VersionsViewController ()

@property (strong,nonatomic) Version *currentCDN;
@property (strong,nonatomic) NSArray *versions;
@property (strong,nonatomic) NSString *currentVersion;
@property (strong,nonatomic) NSString *selectedVersion;

@end

@implementation VersionsViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
       
    }
    return self;
}
//Designated Init
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withFramework:(Framework *)framework andDelegate:(id<ScriptPopoverViewControllerDelegate>)delegate {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.delegate = delegate;
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:NO];
        NSArray *sortDescriptors = @[sortDescriptor];
        NSArray *versions = [NSArray arrayWithArray:[framework.versions sortedArrayUsingDescriptors:sortDescriptors]];
        _versions = [NSArray arrayWithArray:versions];
        _selectedVersion = framework.activeVersion;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.versions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MyIdentifier"];
    }
    Version *version =(self.versions)[indexPath.row];
    if ([self.selectedVersion isEqualToString:version.number]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [tableView scrollToRowAtIndexPath:indexPath
                                  atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.textLabel.text = version.number;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Version *version =(self.versions)[indexPath.row];
    [self.delegate didSelectFrameworkVersionAtIndexPath:indexPath withVersion:version];
}

@end
