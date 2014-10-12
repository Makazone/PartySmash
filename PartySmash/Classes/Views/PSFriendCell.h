//
//  PSFriendCell.h
//  PartySmash
//
//  Created by Makar Stetsenko on 17.07.14.
//  Copyright (c) 2014 PartySmash. All rights reserved.
//



@interface PSFriendCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *friendPic;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UIButton *follow;

@end
