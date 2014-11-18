//
// Created by Makar Stetsenko on 16.11.14.
// Copyright (c) 2014 PartySmash. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSCellDelegate.h"


@interface PSSearchUserVC : UISearchDisplayController <UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate, UISearchBarDelegate, PSCellDelegate>

@end