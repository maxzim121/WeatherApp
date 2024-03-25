# WeatherApp
[ScreenCastRussian](https://disk.yandex.ru/i/3LNX9zoFURj-kg),
[ScreenCastEnglish](https://disk.yandex.ru/i/SjjXaHIOBdQOsg)

##### Layout type - by code

##### MVP architecture

## Application description

 
  WeatherApp provides users with up-to-date weather forecasts, both for today and the next 7 days. Utilizing the device's geolocation, users receive accurate weather information based on their current location. Additionally, users can search for weather forecasts in other locations by city name, facilitated through a search bar and a dedicated search screen. The app also displays the user's current location, enhancing convenience and usability.

## Functional Requirements:
1. **Today's Weather Forecast:** Display temperature, wind speed, cloudiness, visibility, and humidity for day in a single large block. Use the user's geolocation to obtain coordinates.
2. **7-Day Weather Forecast:** Present the weather forecast for the next 7 days in a UITableView or UICollectionView format.

**Additional Features:**
- Format the date.
- Display the name of the city or location where the user is located using CLGeocoder.
- Implement city search functionality to allow users to view weather forecasts based on city names. Include a search bar and a separate screen for searching using MKLocalSearch.

## Technical Requirements:
- Minimum iOS version: 16.0.
- App must be written in Swift and use UIKit.
- Implement layout programmatically without using XIB or Storyboard.
- Use only standard Apple libraries; external libraries are not allowed.
