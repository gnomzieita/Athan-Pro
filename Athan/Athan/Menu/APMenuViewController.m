//
//  APMenuViewController.m
//  Athan
//
//  Created by Alex Agarkov on 20.01.16.
//  Copyright © 2016 Alex Agarkov. All rights reserved.
//

#import "APMenuViewController.h"

@interface APMenuViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>
{
    NSDictionary* prayerDict;
}

@property (weak, nonatomic) IBOutlet UICollectionView *table;

@end

@implementation APMenuViewController

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

#pragma mark - UICollectionViewDataSource -

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 26;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:[NSString stringWithFormat:@"cell%i",indexPath.row] forIndexPath:indexPath];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate -

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (isiPad) {
        return CGSizeMake((self.view.frame.size.width-60.0f)/4,(self.view.frame.size.width-60.0f)/4/0.9f);
    }
    return CGSizeMake((self.view.frame.size.width-60.0f)/3,(self.view.frame.size.width-60.0f)/3/0.9f);
}
@end
