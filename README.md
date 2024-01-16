Overview:
Welcome to Shortcut! This application provides a variety of features and functionalities through different view controllers. From route planning using MapKit and Mapbox to emailing invoices, and accessing useful links, this application demonstrates a range of capabilities.

Features:
Route Planning: Utilize the RouteCalculatorViewController to plan the optimal route between multiple locations starting and ending at the same location using MapKit. The app employs a genetic algorithm for route optimization.
MapBox Navigation: The MapBoxNavUIController demonstrates Mapbox integration for turn-by-turn navigation based on MapKit map items.
Email Composition: The EmailViewController allows users to compose emails with predefined subjects and bodies. It uses the MFMailComposeViewController to facilitate email creation.
Useful Links: Access relevant websites for gas prices, toll calculations, and weather radar through the LinksViewController. Each button opens a specific website in the default web browser.

The application provides a user-friendly interface with different functionalities accessible through the various view controllers. Navigate through the app to explore the features and utilize the functionalities available in each section.
View Controllers:
1. RouteCalculatorViewController
Purpose: Plan the optimal route between multiple locations using MapKit.
Key Functionality: Utilizes a genetic algorithm for route optimization.

2. MapBoxNavUIController
Purpose: Display turn-by-turn navigation based on MapKit map items using Mapbox.
Key Functionality: Integrates Mapbox for navigation.

3. EmailViewController
Purpose: Compose emails with predefined subjects and bodies.
Key Functionality: Uses MFMailComposeViewController for email composition.

4. LinksViewController
Purpose: Access useful websites for gas prices, toll calculations, and weather radar.
Key Functionality: Opens specific URLs in the default web browser.

Dependencies:
MapKit: Used for route planning and map-related functionalities.
Mapbox: Integrated for turn-by-turn navigation.
MessageUI Framework: Utilized for email composition.
