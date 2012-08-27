//
//  EventDetailViewController.m
//  Timeline
//
//  Created by Alessandro Boron on 24/08/2012.
//  Copyright (c) 2012 Alessandro Boron. All rights reserved.
//

#import <AddressBook/AddressBook.h>
#import <QuartzCore/QuartzCore.h>
#import "EventDetailViewController.h"
#import "TimelineViewCell.h"
#import "NoteCell.h"
#import "Event.h"
#import "NewNoteViewController.h"
#import "SampleNote.h"

#define FONT_SIZE 16.0f
#define CELL_CONTENT_WIDTH 265.0f
#define CELL_CONTENT_MARGIN 10.0f
#define CELL_CONTENT_MARGIN_X 10.0f
#define CELL_CONTENT_MARGIN_Y 10.0f
#define CELL_HEIGHT 55.0f

@interface EventDetailViewController ()

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UILabel *eventDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventLocationLabel;
@property (weak, nonatomic) IBOutlet UITableView *itemsTableView;


- (IBAction)doneButtonPressed:(id)sender;
- (void)performReverseGeocoding;

@end

@implementation EventDetailViewController

@synthesize delegate = _delegate;
@synthesize event = _event;
@synthesize navigationBar = _navigationBar;
@synthesize eventDateLabel = _eventDateLabel;
@synthesize eventLocationLabel = _eventLocationLabel;
@synthesize itemsTableView = _itemsTableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //Set the background image for the navigation bar
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationBarBackground.png"] forBarMetrics:UIBarMetricsDefault];
    
    //Set the background color for the view
    self.view.backgroundColor = [UIColor colorWithRed:211.0/255 green:218.0/255 blue:224.0/255 alpha:1.0];
    
    //Set the date label of the event
    self.eventDateLabel.text = [Utility dateDescriptionForEventDetailsWithDate:self.event.date];
    
    //Set the location label of the event
    [self performReverseGeocoding];
    
    //Make rounded corner to the tableview
    self.itemsTableView.clipsToBounds = YES;
    self.itemsTableView.layer.cornerRadius = 7.0;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Segue Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    //If New Note
    if ([segue.identifier isEqualToString:@"newNoteToEventSegue"]) {
        
        NewNoteViewController *nnvc = (NewNoteViewController *)segue.destinationViewController;
        nnvc.delegate = self;
        nnvc.baseEvent = self.event;
    }
}

#pragma mark -
#pragma mark UI Methods

- (IBAction)doneButtonPressed:(id)sender{
    
    [self.delegate dismissModalViewControllerAndUpdate];
}

#pragma mark -
#pragma mark Private Methods

- (void)performReverseGeocoding{
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    //Perform the reverse geocoding based on the annotation coordinate
    [geocoder reverseGeocodeLocation:[[CLLocation alloc] initWithLatitude:self.event.location.coordinate.latitude longitude:self.event.location.coordinate.longitude] completionHandler:
     
     ^(NSArray* placemarks, NSError* error){
         //If the reverse geocoding went ok
         if ([placemarks count]>0) {
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
             //Get the name of the address
             NSString *address = [placemark.addressDictionary objectForKey:(NSString *)kABPersonAddressStreetKey];
             //Get the name of the city
             NSString *city = placemark.locality;
             
             //Set the label with address and city
             self.eventLocationLabel.text = [NSString stringWithFormat:@"%@,%@",address,city];
         }
         //If the reverse geocoding went wrong
         if (error) {
             //Set the error message
             self.eventLocationLabel.text = @"Unable to retrieve the location";
         }
     }];
}

#pragma mark -
#pragma mark ModalViewControllerDelegate

- (void)dismissModalViewController{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addEventItem:(id)sender toBaseEvent:(BaseEvent *)baseEvent{
    [self dismissViewControllerAnimated:YES completion:^{
        [self.event.eventItems addObject:sender];
        [self.itemsTableView reloadData];
    }];
    
    
}


#pragma mark -
#pragma mark UITablewViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.event.eventItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //Get the object at the specified index path
    id objectInTimeline = [self.event.eventItems objectAtIndex:indexPath.row];
        
    TimelineViewCell *cell = nil;
    
    UIEdgeInsets insets;
    insets.top = 37;
    insets.left = 0;
    insets.bottom = 37;
    insets.right = 0;
    
    UIImage *backgroundImg = [[UIImage imageNamed:@"eventItemContainer.png"] resizableImageWithCapInsets:insets];
    
    UIImageView *iv = [[UIImageView alloc] initWithImage:backgroundImg];
    
    //If the cell will contain a note
    if ([objectInTimeline isMemberOfClass:[SampleNote class]]) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"noteCellIdentifier"];
        
        //Get the size of the text in order to set the label frame
        CGSize size = [Utility sizeOfText:((SampleNote *)objectInTimeline).noteText width:CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2) fontSize:FONT_SIZE];

#warning handle multivalue values label
        //Set the text
        ((NoteCell *)cell).contentLabel.text  = ((SampleNote *)objectInTimeline).noteText;
        
        //Set the new frame for the cell label
        [((NoteCell *)cell).contentLabel setFrame:CGRectMake(CELL_CONTENT_MARGIN_X, CELL_CONTENT_MARGIN_Y, CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), MAX(size.height, CELL_HEIGHT))];
        
        cell.backgroundView.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, CELL_CONTENT_WIDTH, MAX(size.height, CELL_HEIGHT));
        
        cell.backgroundView = iv;
    }
    //No of the above specified objects
    else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"timelineCellIndentifier"];
    }
    
    //Disable selection style for the cell
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //Get the object at the specified index path
    id objectInTimeline = [self.event.eventItems objectAtIndex:indexPath.row];
    
    CGFloat height;
    
    //If the object is a Note
    if ([objectInTimeline isMemberOfClass:[SampleNote class]]) {
        
        //Get the size of the text
        CGSize size = [Utility sizeOfText:((SampleNote *)objectInTimeline).noteText width:CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2) fontSize:FONT_SIZE];
        
        //Get the height for the row
        height = MAX(size.height, CELL_HEIGHT) + (CELL_CONTENT_MARGIN * 2) + CELL_CONTENT_MARGIN_Y;
    }
    return height;
    /*
     else if ([objectInTimeline isMemberOfClass:[SamplePicture class]]){
     
     }
     */    
}

@end
