# Description:

Make an app to download maps.

Prototype – [Figma](https://www.figma.com/proto/B5GM80kuHy9c1eSImjyqL01l/Download-Maps---Test-Task?node-id=6108-3153&viewport=424%2C232%2C0.5&t=Bz34clHeT7qdpwDu-1&scaling=scale-down&content-scaling=fixed&starting-point-node-id=6108%3A3153&page-id=354%3A0). 
UI – [Figma](https://www.figma.com/design/B5GM80kuHy9c1eSImjyqL01l/Download-Maps---Test-Task?node-id=6108-3153&m=dev)

Recommendation: limit the implementation stack to Foundation and UIKit only

Implement sequential map loading, one after another (with a sequential queue).
API: HTTP REST map download, e.g.: 
https://download.osmand.net/download?standard=yes&file=Denmark_europe_2.obf.zip
https://download.osmand.net/download?standard=yes&file=Germany_berlin_europe_2.obf.zip
https://download.osmand.net/download?standard=yes&file=France_corse_europe_2.obf.zip

The complete list of maps and active links is available here: https://download.osmand.net/list. This resource can be used to test the link generation algorithm

How to get the link
Map information is stored in an XML file named: [regions.xml](https://drive.google.com/open?id=1vu1Pf3tcIc6RxXdJF-PGaN1N1tWU6TUc)
This file should be stored on the client
The map="yes" or map="no" attribute, along with the type="map" attribute, determines whether a map is available for download (see line 24 for a detailed description).
Append _2.obf.zip to the filename.  Capitalize the first letter of the map name in the filename. For example: 
denmark_europe_2.obf.zip becomes Denmark_europe_2.obf.zip
france_corse_europe_2.obf.zip becomes France_corse_europe_2.obf.zip


UI & Interactions
A banner displaying information about available free space on the device.
A list of European regions.

Region item: 
Display the region name
Display a download icon if the region has no nested elements
Tapping the download icon should display a progress indicator 
Change the icon color after the download is complete
Display a chevron if the region has nested items
Tapping the item should open the next screen, which displays a list of regions

Resources
Icons –  [Download](https://drive.google.com/file/d/1ROGqeuYW1qXnOwZERsk5uHOjeRpZ3RM4/view?usp=drive_link)
Nav bar color –  Use system default NavBars
View background color – #F2F2F3
TabelCell background color – #FFFFFF
Separator color – #CBC7D1
Use grouped list style
Text –  use Dynamic type: Body style, Typography | Apple Developer Documentation
Icon map  – default color #BEB9C5
Downloaded map icon color – #14CC9E


You can complete the test assignment partially, skipping sections that are challenging. We will still review your submission and provide feedback.
The assignment's goal is to assess your coding skills and your familiarity with the full application development lifecycle.
