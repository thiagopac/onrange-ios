//
//  TipoLocalTableViewController.m
//  Onrange
//
//  Created by Thiago Castro on 06/05/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import "TipoLocalTableViewController.h"
#import "AdicionaLocalTableViewController.h"

@interface TipoLocalTableViewController (){
    NSArray *arrTiposLocais;
    NSIndexPath *checkedIndexPath;
}

@end

@implementation TipoLocalTableViewController

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
    
    arrTiposLocais = @[@"Boate / Pub",@"Bar / Restaurante",@"Festa / Show",@"Locais públicos"];
    
    UIImage *image = [UIImage imageNamed:@"icone_nav.png"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
    self.navigationController.navigationBar.topItem.title = @"•";
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
    return arrTiposLocais.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"tipoLocalCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if([checkedIndexPath isEqual:indexPath]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    [[cell textLabel]setText:[arrTiposLocais objectAtIndex:indexPath.row]];
    
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
    
    /*
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setInteger:indexPath.row forKey:@"tipoLocal"];
    [def synchronize];
     */
    
    AdicionaLocalTableViewController *adicionaLocalTVC = [self.navigationController.viewControllers objectAtIndex:2];
    adicionaLocalTVC.tipoLocal = indexPath.row+1;
    adicionaLocalTVC.nomeCategoria = [arrTiposLocais objectAtIndex:indexPath.row];
    [self.navigationController popToViewController:adicionaLocalTVC animated:YES];
}

@end
