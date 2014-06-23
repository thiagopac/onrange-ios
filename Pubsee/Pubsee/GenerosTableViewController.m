//
//  GenerosTableViewController.m
//  Onrange
//
//  Created by Thiago Castro on 22/06/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import "GenerosTableViewController.h"
#import "GenerosTableViewCell.h"
#import "SettingsTableViewController.h"

@interface GenerosTableViewController (){
    NSArray *arrGeneros;
    NSIndexPath *checkedIndexPath;
    NSString *genero;
    int linhaGenero;
}

@end

@implementation GenerosTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    arrGeneros = @[@"Homens e mulheres",@"Homens",@"Mulheres"];
    
    UIImage *image = [UIImage imageNamed:@"icone_nav.png"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
    self.navigationController.navigationBar.topItem.title = @"•";
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    genero = [def objectForKey:@"genero"];

    if (genero == nil || [genero isEqualToString:@"MF"]) {
        linhaGenero = 0;
    }else if ([genero isEqualToString:@"M"]) {
        linhaGenero = 1;
    }else if ([genero isEqualToString:@"F"]) {
        linhaGenero = 2;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrGeneros.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"generosCell";
    GenerosTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if(linhaGenero == indexPath.row){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    [[cell lblGenero]setText:[arrGeneros objectAtIndex:indexPath.row]];
    
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
    
    NSString *siglaGenero;
    
    if (indexPath.row == 0) {
        siglaGenero = @"MF";
    }else if (indexPath.row == 1) {
        siglaGenero = @"M";
    }else{
        siglaGenero = @"F";
    }
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:siglaGenero forKey:@"genero"];
    [def synchronize];
    
    [self.navigationController popToViewController:settingsTVC animated:YES];
}

@end
