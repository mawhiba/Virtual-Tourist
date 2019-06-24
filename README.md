# Virtual-Tourist

### What is it?
Virtual Tourist is an IOS App that allow the users to post pins on the map,
and once they click on that pin, the app will download the photos associated
with these coordinate. The photos are downloaded from Flickr website.
Virtual Tourist is applying the Core Data concept, so the photos associated with
the dropped pin are remains after the user exit the app, and in the next time when
the user revisit the same pin, the app will bring the photos from the core data,
and no need to re-download the photos from the website again.

### How to build?
The app has three view controller :
1. LoginVC:
   Accessing to the app using Udacity credentials.
2. MapViewController:
   Allow the user to drop pins by long press on the map.
3. PhotoCollectionVC:
   Present the photos associated with the pin.
   When tapped on any photo the photo deleted.


### How to make?
- Get familiar with Swift topics such as Networking and Core Data
- Get photos provider API such as Flickr API


### How to try?
- Clone this repo
- Open with Xcode
- Run!

##### Requirements
* Xcode > 10.1
* Swift > 4.2
