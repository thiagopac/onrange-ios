//
//  AdicionaLocalTableViewController.m
//  Onrange
//
//  Created by Thiago Castro on 06/05/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import "AdicionaLocalTableViewController.h"

@interface AdicionaLocalTableViewController ()

@end

@implementation AdicionaLocalTableViewController

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
    UIImage *image = [UIImage imageNamed:@"icone_nav.png"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
    self.navigationController.navigationBar.topItem.title = @"•";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

-(void)viewWillAppear:(BOOL)animated{
    if (self.tipoLocal) {
        [self.lblCategoria setText:self.nomeCategoria];
    }
}

- (IBAction)btnConfirmar:(UIButton *)sender {
}
@end
