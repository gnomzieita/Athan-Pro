//
//  APSettingsViewController.m
//  Athan
//
//  Created by Alex Agarkov on 22.01.16.
//  Copyright © 2016 Alex Agarkov. All rights reserved.
//

#import "APSettingsViewController.h"

@interface APSettingsViewController () <UITableViewDataSource, UITableViewDelegate>
- (IBAction)backButton:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *table;
@end

@implementation APSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
        {
            return 1;
        }
            break;
        case 1:
        {
            return 12;
        }
            break;
        case 2:
        {
            return 4;
        }
            break;
        case 3:
        {
            return 1;
        }
            break;
        case 4:
        {
            return 6;
        }
            break;
            
        default:
            break;
    }
    return 10;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
        {
            return @"Координаты GPS";
        }
            break;
        case 1:
        {
            return @"Время молитвы - опции";
        }
            break;
        case 2:
        {
            return @"Настройка интерфейса";
        }
            break;
        case 3:
        {
            return @"Премиум";
        }
            break;
        case 4:
        {
            return @"Поддержка пользователей";
        }
            break;
            
        default:
            break;
    }
    return @"";
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    UITableViewCell* cell = [[UITableViewCell alloc] init];
    
    [cell.textLabel setText:[NSString stringWithFormat:@"%@",indexPath]];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (IBAction)backButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
