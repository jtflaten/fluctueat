
# FluctuEat

The **FluctuEat** app is intended to help people find out what Food Trucks are open and nearest to them and
to help food truck Operators get that information out as easily as possible. Because of this, there are two possible
user flows.

user type definitions:

“vendor” is used to refer to a Food Truck operator, who will have signed up to use this app to put out up-to-date
location information. vendors will have access to many more viewControllers and capabilities than
the regular user type. they will have to log in to the app to be able to get to the vendor tabController flow

user is the term from here out for any person accessing the app that is not a Vendor. The user's UX will be very simple
compared to the vendor's so  we will cover it first.

### USER UX

#### HomeMapVC and HomeTableVC
When a user opens the app, there will be a viewController available to them with a map. the map will show where the user
is and have annotations for each food truck near them. tapping the annotation will show the user the truckInfo VC.

#### FoodTruckInfoVC
When a FoodTruckVC is opened, the app will show the user a picture of the Food Truck,
it's name, a short description, and up to six images of the food offered by the food truck.
There will be a "Let's Get Some" button that will open up either googleMaps if available or Apple Maps if not
and give the user directions to the food Truck.

### VENDOR UX

### ACCESSING VENDOR MODE
On the HomeMapVC, a user can access the login page for Vendor Mode by pressing “vendor”

## VendorInfoVC
the first vc the vendor will have access to will allow them to upload images and update the information about
their food truck. a vendor will provide an image of the truck, the name, description, and up to six images of the
food they serve. images are persisted and sent to Firebase Storage as soon as they are chosen. if a vendor attempts
to navigate away from the page without giving a name and description and saving it, they are given a warning and must
update those text fields and save before continuing. (this should only need to happen once). A vendor will not be allowed
to save an empty string for either name or description

## VendorMapVC
The map will show the vendor's location and the VendorMapVC will have an "Open" and a "Close" button.
the Open button will publish the relevant information to the
publicly available part of the database, which is what the "user" ViewControllers use to get to populate their respective
objects (map and table).

**A VENDOR has to SAVE on the VendorInfoVC and then press OPEN on the VendorMapVC**

## TESTER/REVIEWER UX
If you'd like to demo the Vendor side of things, I've set up a Vendor account for you to write
to the the database. it has all the permissions that a vendor would have, so
you can set up your own food truck and put it on the map. please take the app for a spin.
YIf you'd be so kind as to send any feedback you have to jtflaten@gmail.com, please include
FluctuEat in the subject line.

email: test_vendor@breaklist.com
pass: testvendor

you can also use the spaceFood truck to mess with a vendor that's already networked up

email: spacefood@breaklist.com
pass: spacefood


**__SPECIAL NOTE__**: if you use the simulator to upload data to the firebase database, the Coordinates for the vendor will be -95.3698, -95.3698
which will throw an error. if you use an actual iPhone, the CoreLocation data should be accurate.
