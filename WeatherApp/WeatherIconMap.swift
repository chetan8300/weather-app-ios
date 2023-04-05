//
//  WeatherIconMap.swift
//  Lab3
//
//  Created by Chetan Godhani on 04/04/23.
//

import Foundation
import UIKit

struct CodeIcon {
    let day: String
    let night: String
    
    func generateDayImage() -> UIImage {
        return UIImage(systemName: day) ?? UIImage(systemName: "sun.max.fill")!
    }
    
    func generateNightImage() -> UIImage {
        return UIImage(systemName: night) ?? UIImage(systemName: "sun.max.fill")!
    }
}

var weatherIconDictionary: [Int:CodeIcon] = [
    // day: Sunny, night: Clear
    1000: CodeIcon(day: "sun.max.fill", night: "moon.fill"),

    // day: Partly cloudy, night: Partly cloudy
    1003: CodeIcon(day: "cloud.sun.fill", night: "cloud.moon.fill"),

    // day: Cloudy, night: Cloudy
    1006: CodeIcon(day: "cloud.fill", night: "cloud.fill"),

    // day: Overcast, night: Overcast
    1009: CodeIcon(day: "cloud.fill", night: "cloud.fill"),

    // day: Mist, night: Mist
    1030: CodeIcon(day: "sun.haze.fill", night: "moon.haze.fill"),

    // day: Patchy rain possible, night: Patchy rain possible
    1063: CodeIcon(day: "cloud.rain.fill", night: "cloud.rain.fill"),

    // day: Patchy snow possible, night: Patchy snow possible
    1066: CodeIcon(day: "cloud.snow.fill", night: "cloud.snow.fill"),

    // day: Patchy sleet possible, night: Patchy sleet possible
    1069: CodeIcon(day: "cloud.hail.fill", night: "cloud.hail.fill"),

    // day: Patchy freezing drizzle possible, night: Patchy freezing drizzle possible
    1072: CodeIcon(day: "snowflake", night: "snowflake"),

    // day: Thundery outbreaks possible, night: Thundery outbreaks possible
    1087: CodeIcon(day: "cloud.sun.bolt.fill", night: "cloud.moon.bolt.fill"),

    // day: Blowing snow, night: Blowing snow
    1114: CodeIcon(day: "wind.snow", night: "wind.snow"),

    // day: Blizzard, night: Blizzard
    1117: CodeIcon(day: "cloud.sleet.fill", night: "cloud.sleet.fill"),

    // day: Fog, night: Fog
    1135: CodeIcon(day: "cloud.fog.fill", night: "cloud.fog.fill"),

    // day: Freezing fog, night: Freezing fog
    1147: CodeIcon(day: "cloud.fog.fill", night: "cloud.fog.fill"),

    // day: Patchy light drizzle, night: Patchy light drizzle
    1150: CodeIcon(day: "cloud.drizzle.fill", night: "cloud.drizzle.fill"),

    // day: Light drizzle, night: Light drizzle
    1153: CodeIcon(day: "cloud.drizzle.fill", night: "cloud.drizzle.fill"),

    // day: Freezing drizzle, night: Freezing drizzle
    1168: CodeIcon(day: "cloud.drizzle.fill", night: "cloud.drizzle.fill"),

    // day: Heavy freezing drizzle, night: Heavy freezing drizzle
    1171: CodeIcon(day: "cloud.drizzle.fill", night: "cloud.drizzle.fill"),

    // day: Patchy light rain, night: Patchy light rain
    1180: CodeIcon(day: "cloud.sun.rain.fill", night: "cloud.moon.rain.fill"),

    // day: Light rain, night: Light rain
    1183: CodeIcon(day: "cloud.sun.rain.fill", night: "cloud.moon.rain.fill"),

    // day: Moderate rain at times, night: Moderate rain at times
    1186: CodeIcon(day: "cloud.sun.rain.fill", night: "cloud.moon.rain.fill"),

    // day: Moderate rain, night: Moderate rain
    1189: CodeIcon(day: "cloud.sun.rain.fill", night: "cloud.moon.rain.fill"),

    // day: Heavy rain at times, night: Heavy rain at times
    1192: CodeIcon(day: "cloud.sun.rain.fill", night: "cloud.moon.rain.fill"),

    // day: Heavy rain, night: Heavy rain
    1195: CodeIcon(day: "cloud.bolt.rain.fill", night: "cloud.bolt.rain.fill"),

    // day: Light freezing rain, night: Light freezing rain
    1198: CodeIcon(day: "cloud.rain", night: "cloud.rain"),

    // day: Moderate or heavy freezing rain, night: Moderate or heavy freezing rain
    1201: CodeIcon(day: "cloud.hail.fill", night: "cloud.hail.fill"),

    // day: Light sleet, night: Light sleet
    1204: CodeIcon(day: "cloud.sleet", night: "cloud.sleet"),

    // day: Moderate or heavy sleet, night: Moderate or heavy sleet
    1207: CodeIcon(day: "cloud.sleet.fill", night: "cloud.sleet.fill"),

    // day: Patchy light snow, night: Patchy light snow
    1210: CodeIcon(day: "cloud.snow", night: "cloud.snow"),

    // day: Light snow, night: Light snow
    1213: CodeIcon(day: "cloud.snow", night: "cloud.snow"),

    // day: Patchy moderate snow, night: Patchy moderate snow
    1216: CodeIcon(day: "cloud.snow.circle", night: "cloud.snow.circle"),

    // day: Moderate snow, night: Moderate snow
    1219: CodeIcon(day: "cloud.snow.fill", night: "cloud.snow.fill"),

    // day: Patchy heavy snow, night: Patchy heavy snow
    1222: CodeIcon(day: "cloud.snow.fill", night: "cloud.snow.fill"),

    // day: Heavy snow, night: Heavy snow
    1225: CodeIcon(day: "cloud.snow.fill", night: "cloud.snow.fill"),

    // day: Ice pellets, night: Ice pellets
    1237: CodeIcon(day: "cloud.hail.fill", night: "cloud.hail.fill"),

    // day: Light rain shower, night: Light rain shower
    1240: CodeIcon(day: "cloud.sun.rain", night: "cloud.moon.rain"),

    // day: Moderate or heavy rain shower, night: Moderate or heavy rain shower
    1243: CodeIcon(day: "cloud.sun.rain.fill", night: "cloud.moon.rain.fill"),

    // day: Torrential rain shower, night: Torrential rain shower
    1246: CodeIcon(day: "cloud.sun.rain.fill", night: "cloud.moon.rain.fill"),

    // day: Light sleet showers, night: Light sleet showers
    1249: CodeIcon(day: "cloud.sleet", night: "cloud.sleet"),

    // day: Moderate or heavy sleet showers, night: Moderate or heavy sleet showers
    1252: CodeIcon(day: "cloud.sleet", night: "cloud.sleet"),

    // day: Light snow showers, night: Light snow showers
    1255: CodeIcon(day: "cloud.snow.circle", night: "cloud.snow.circle"),

    // day: Moderate or heavy snow showers, night: Moderate or heavy snow showers
    1258: CodeIcon(day: "cloud.snow.circle", night: "cloud.snow.circle"),

    // day: Light showers of ice pellets, night: Light showers of ice pellets
    1261: CodeIcon(day: "cloud.snow.circle.fill", night: "cloud.snow.circle.fill"),

    // day: Moderate or heavy showers of ice pellets, night: Moderate or heavy showers of ice pellets
    1264: CodeIcon(day: "cloud.snow.circle.fill", night: "cloud.snow.circle.fill"),

    // day: Patchy light rain with thunder, night: Patchy light rain with thunder
    1273: CodeIcon(day: "cloud.bolt.rain.circle", night: "cloud.bolt.rain.circle"),

    // day: Moderate or heavy rain with thunder, night: Moderate or heavy rain with thunder
    1276: CodeIcon(day: "cloud.bolt.rain.circle", night: "cloud.bolt.rain.circle"),

    // day: Patchy light snow with thunder, night: Patchy light snow with thunder
    1279: CodeIcon(day: "cloud.snow.circle.fill", night: "cloud.snow.circle.fill"),

    // day: Moderate or heavy snow with thunder, night: Moderate or heavy snow with thunder
    1282: CodeIcon(day: "cloud.snow.circle.fill", night: "cloud.snow.circle.fill"),
]
