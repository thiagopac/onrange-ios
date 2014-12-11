//
//  TipoLocalTableViewController.m
//  Onrange
//
//  Created by Thiago Castro on 06/05/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import "TipoLocalTableViewController.h"
#import "AdicionaLocalTableViewController.h"
#import "TipoLocalTableViewCell.h"

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
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString *tema_img = [def objectForKey:@"tema_img"];
    NSString *tema_cor = [def objectForKey:@"tema_cor"];
    
    UIImage *image = [UIImage imageNamed:tema_img];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
    
    UIColor *navcolor = [UIColor colorWithHexString:tema_cor];
    self.navigationController.navigationBar.barTintColor = navcolor;
    
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
    TipoLocalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if([checkedIndexPath isEqual:indexPath]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    [[cell lblTipoLocal]setText:[arrTiposLocais objectAtIndex:indexPath.row]];
    
    //Tipos de local
    //  1-Balada
    //  2-Bar
    //  3-Festa
    //  4-Locais Públicos
    
    NSString *cor;
    
    if (indexPath.row == 0) {
        cor = @"#ee4e30"; //vermelho
    }else if (indexPath.row == 1) {
        cor = @"#fcb826"; //amarelo
    }else if (indexPath.row == 2) {
        cor = @"#48b163"; //verde
    }else{
        cor = @"#5a8eaf"; //azul
    }
    
    cell.viewCorTipoLocal.backgroundColor = [UIColor colorWithHexString:cor];
    
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

    AdicionaLocalTableViewController *adicionaLocalTVC = [self.navigationController.viewControllers objectAtIndex:2];
    adicionaLocalTVC.tipoLocal = (int)indexPath.row+1;
    adicionaLocalTVC.nomeCategoria = [arrTiposLocais objectAtIndex:indexPath.row];
    [self.navigationController popToViewController:adicionaLocalTVC animated:YES];
}

@end
