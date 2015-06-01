//
//  AmbientesTableViewController.m
//  Onrange
//
//  Created by Thiago Castro on 01/03/15.
//  Copyright (c) 2015 Thiago Castro. All rights reserved.
//

#import "AmbientesTableViewController.h"
#import "AmbientesTableViewCell.h"
#import "SettingsTableViewController.h"

@interface AmbientesTableViewController (){
    NSArray *arrAmbientes;
    NSIndexPath *checkedIndexPath;
    NSString *ambiente;
    int linhaAmbiente;
}

@end

@implementation AmbientesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    arrAmbientes = @[@"Produção", @"Desenvolvimento"];
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString *tema_img = [def objectForKey:@"tema_img"];
    NSString *tema_cor = [def objectForKey:@"tema_cor"];
    
    UIImage *image = [UIImage imageNamed:tema_img];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
    
    UIColor *navcolor = [UIColor colorWithHexString:tema_cor];
    self.navigationController.navigationBar.barTintColor = navcolor;
    
    self.navigationController.navigationBar.topItem.title = @"•";
    
    ambiente = [def objectForKey:@"ambiente"];
    
    if (ambiente == nil || [ambiente isEqualToString:@"Produção"]) {
        linhaAmbiente = 0;
    }else if ([ambiente isEqualToString:@"Desenvolvimento"]) {
        linhaAmbiente = 1;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return arrAmbientes.count;;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ambientesCell";
    AmbientesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if(linhaAmbiente == indexPath.row){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    [[cell lblAmbiente]setText:[arrAmbientes objectAtIndex:indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(checkedIndexPath) {
        UITableViewCell* uncheckCell = [tableView
                                        cellForRowAtIndexPath:checkedIndexPath];
        uncheckCell.accessoryType = UITableViewCellAccessoryNone;
    }
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    checkedIndexPath = indexPath;
    
    SettingsTableViewController *settingsTVC = [self.navigationController.viewControllers objectAtIndex:1];
    
    NSString *nomeAmbiente;
    
    if (indexPath.row == 0) {
        nomeAmbiente = @"Produção";
    }else if (indexPath.row == 1) {
        nomeAmbiente = @"Desenvolvimento";
    }
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:nomeAmbiente forKey:@"ambiente"];
    [def synchronize];
    
    [self.navigationController popToViewController:settingsTVC animated:YES];
}

@end
