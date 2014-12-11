//
//  ThemesTableViewController.m
//  Onrange
//
//  Created by Thiago Castro on 08/12/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import "ThemesTableViewController.h"
#import "SettingsTableViewController.h"

@interface ThemesTableViewController ()

@end

@implementation ThemesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    NSString *tema_img = [def objectForKey:@"tema_img"];
    NSString *tema_cor = [def objectForKey:@"tema_cor"];
    
    UIImage *image = [UIImage imageNamed:tema_img];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
    
    UIColor *navcolor = [UIColor colorWithHexString:tema_cor];
    self.navigationController.navigationBar.barTintColor = navcolor;
    
    self.navigationController.navigationBar.topItem.title = @"•";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    if(indexPath.section == 0 && indexPath.row == 0){     //DIA

        [def setObject:@"icone_nav.png" forKey:@"tema_img"];
        [def setObject:@"#F46122" forKey:@"tema_cor"];
        
        SettingsTableViewController *settingsTVC = [self.navigationController.viewControllers objectAtIndex:1];
        [self.navigationController popToViewController:settingsTVC animated:YES];
        
    }else if(indexPath.section == 1 && indexPath.row == 0){    //NOITE
        
        [def setObject:@"icone_nav2.png" forKey:@"tema_img"];
        [def setObject:@"#2C3E50" forKey:@"tema_cor"];
        
        SettingsTableViewController *settingsTVC = [self.navigationController.viewControllers objectAtIndex:1];
        [self.navigationController popToViewController:settingsTVC animated:YES];
        
        
    }
}

@end
