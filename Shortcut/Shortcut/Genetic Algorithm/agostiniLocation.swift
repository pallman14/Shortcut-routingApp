//  Price Allman
//  agostiniLocation.swift
//  Shortcut
//
//  Algorithm inspired from https://agostini.tech/2018/01/29/genetic-algorithms-in-swift-solving-tsp/.


import Foundation

/**
 A waypoint represents a characteristic from an individual in the genetic algorithm.
 
 This structure defines a waypoint, which is used to represent a characteristic in the context of a genetic algorithm. Waypoints could correspond to locations or any other elements to be optimized in the problem domain.

 - Note: The `Equatable` conformance allows for comparing waypoints based on their positions.

 - SeeAlso: `GeneticAlgorithm.agostiniMatrix` for distance information between waypoints.
 */
struct agostiniLocation: Equatable {
    // Compares two waypoints for equality based on their positions.
    static func ==(lhs: agostiniLocation, rhs: agostiniLocation) -> Bool {
        return lhs.location == rhs.location
    }
    // The position identifier of the waypoint.
    let location: Int
    
    
    /**
         Calculates distance from this waypoint to another waypoint.
         
         - Parameter waypoint: The destination waypoint to calculate the distance to.
         - Returns: The distance between this waypoint and the destination waypoint, as defined in the `GeneticAlgorithm.agostiniMatrix`.
         */
    func distance(to waypoint: agostiniLocation) -> Double {
        return GeneticAlgorithm.agostiniMatrix[self.location][waypoint.location]
    }
    
}
