//  Price Allman
//  Route.swift
//  Shortcut
//
//  Algorithm inspired from https://agostini.tech/2018/01/29/genetic-algorithms-in-swift-solving-tsp/.


import Foundation

/**
 A path represents an individual in the genetic algorithm.
 
 This class represents a path in a genetic algorithm. A path is an ordered sequence of waypoints, and the genetic algorithm aims to optimize these paths. Paths can be individuals or potential solutions to a problem, and they are evaluated based on their distance and fitness.

 - Note: The `Route` class calculates its distance and fitness based on the order of waypoints and the associated distances.

 - SeeAlso: `agostiniLocation` for the individual waypoints, `calculateDistance()` for distance calculation, and `fitness(with:)` for calculating the fitness of the path.
 */

class Route {
    // An array of waypoints that define the sequence of the path.
    var waypoints: [agostiniLocation]
    // The total distance of the path, which is calculated based on the order of waypoints.
    var distance: Double {
        return calculateDistance()
    }
    
    /**
         Initializes a path with an array of waypoints.
         
         - Parameter waypoints: An array of waypoints representing the order of the path.
         */
    init(waypoints: [agostiniLocation]) {
        self.waypoints = waypoints
    }
    
    /**
         Calculates the total distance of the path by summing the distances between consecutive waypoints.
         
         - Returns: The total distance of the path based on the order of waypoints.
         */
    private func calculateDistance() -> Double {
        // Initialize the result variable to store the total distance.
        var totalDistance = 0.0
        // Initialize a variable to keep track of the previousLocation during iteration.
        var previousLocation: agostiniLocation?
        
        // Iterate through each waypoint in the waypoints array.
        waypoints.forEach { (waypoint) in
            // Check if there is a previousLocation to calculate the distance.
            if let previous = previousLocation {
                // Accumulate the distance between the current and previous locations.
                totalDistance += previous.distance(to: waypoint)
            }
            // Update the previousLocation variable for the next iteration.
            previousLocation = waypoint
        }
        // If there are waypoints, connect the last and first waypoints.
        guard let first = waypoints.first, let last = waypoints.last else { return totalDistance }
        // Add the distance between the last and first waypoints to close the route loop.
        return totalDistance + first.distance(to: last)
    }
    
    /**
         Calculates the fitness of the path based on its distance and total distance.
         
         - Parameter totalEffort: The sum of all distances or distances in the problem domain.
         - Returns: The fitness of the path, a value between 0 and 1, where higher values indicate better solutions.
         */
    func fitness(with totalEffort: Double) -> Double {
        return 1 - (distance/totalEffort)
    }
}
