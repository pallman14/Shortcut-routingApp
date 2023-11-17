//  Price Allman
//  GeneticAlgorithm.swift
//  Shortcut
//
//  Algorithm inspired from https://agostini.tech/2018/01/29/genetic-algorithms-in-swift-solving-tsp/.


import Foundation
import MapKit


/**
 The genetic algorithm takes an array of waypoints and a matrix with the distances needed to go from each waypoint to every other one and returns a path, which contains the order in which these waypoints(places) need to be visited, so that the distance is minimum.
 
 Every individual is represented by a path. The algorithm generates at the beginning random paths and then it takes only the "fit" ones (in our case, it means with the distance required to complete the path as small as possible) and combines them, creating a new, better generation.
 
 */
class GeneticAlgorithm {
    
    // Static property to store the distances matrix shared among all instances.
    static var agostiniMatrix = [[Double]]()
    
    // Configuration parameters for the genetic algorithm.
    // Number of individuals in each generation.
    let populationOfPathsSize = 750
    
    // Probability of mutation for each individual.
    let mutation = 0.1
    
    // Array to store the populationOfPaths of paths (individuals).
    private var populationOfPaths = [Route]()
    
    // Array to store the waypoints (places to be visited).
    let waypoints: [agostiniLocation]
    
    // Callback closure to be executed when a new generation is created.
    var newerGeneration: ((Route, Int) -> ())?
    
    // Initialize the genetic algorithm with waypoints and distances matrix.
    init(for waypoints: [agostiniLocation], with distancesMatrix: [[Double]]) {
        self.waypoints = waypoints
        
        // Set the shared distances matrix for all instances.
        GeneticAlgorithm.agostiniMatrix = distancesMatrix
        
        // Generate an initial random populationOfPaths of paths.
        self.populationOfPaths = self.randomPopulation(from: self.waypoints)
    }
    
    // Generate a random population of paths.
    private func randomPopulation(from waypoints: [agostiniLocation]) -> [Route] {
        var result = [Route]()
        for _ in 0..<populationOfPathsSize {
            // Shuffle the waypoints to create a random path.
            let randomizedWaypoints = waypoints.shuffle()
            result.append(Route(waypoints: randomizedWaypoints))
        }
        return result
    }
    
    private var algorithmLoop = false
    private var generation = 1
    
    // Start the loop process.
    func startLoop() {
        
        // Flag to control the loop process.
        algorithmLoop = true
        
        // Perform evolution on a background queue.
        DispatchQueue.global().async {
            while self.algorithmLoop {
                
                // Calculate the total distance of the current populationOfPaths.
                let totalDistance = self.populationOfPaths.reduce(0.0, { $0 + $1.distance })
                
                // Define a sorting closure to sort paths by distance in descending order.
                let sortByDistance: (Route, Route) -> Bool =
                { $0.fitness(with: totalDistance) > $1.fitness(with: totalDistance)}
                
                // Sort the current generation of paths by fitness.
                let currentGeneration = self.populationOfPaths.sorted(by: sortByDistance)
                
                // Create a container for the next generation of paths.
                var nextGeneration = [Route]()
                
                // Generate new paths for the next generation.
                for _ in 0..<self.populationOfPathsSize {
                    // Select two parent paths from the current generation.
                    guard
                        let parentOne = self.getParent(from: currentGeneration, with: totalDistance),
                        let parentTwo = self.getParent(from: currentGeneration, with: totalDistance)
                    else { continue }
                    
                    // Produce an offspring path by combining the two parents.
                    let child = self.produceChild(parentOne, parentTwo)
                    
                    // Apply mutation to the child path.
                    let finalChild = self.mutate(child)
                    
                    // Add the final child path to the next generation.
                    nextGeneration.append(finalChild)
                }
                
                // Replace the current populationOfPaths with the next generation.
                self.populationOfPaths = nextGeneration
                
                // Find and notify the best path in the current populationOfPaths.
                if let bestPath = self.populationOfPaths.sorted(by: sortByDistance).first {
                    self.newerGeneration?(bestPath, self.generation)
                }
                
                // Increment the generation counter.
                self.generation += 1
                
                // Check if the maximum number of generations is reached, and stop evolution.
                if self.generation > GeneticAlgorithm.numberOfGenerationsLimit {
                    self.stopLoop()
                }
            }
        }
    }
    
    // Stops the genetic algorithm evolution process by setting the algorithmLoop flag to false.
    public func stopLoop() {
        algorithmLoop = false
    }
    
    /**
     Selects a parent path from the given generation based on distance and a random distance value.

     - Parameters:
        - generation: The current generation of paths.
        - totalDistance: The total distance (distance) of the current generation.

     - Returns: A selected parent path or nil if selection fails.
     */
    
    private func getParent(from generation: [Route], with totalDistance: Double) -> Route? {
        // Generate a random fitness value between 0 and 1.
        let fitness = Double(Double(arc4random()) / Double(UINT32_MAX))
        var currentFitness = 0.0
        var result: Route?
        
        // Iterate through the paths in the generation and select a path based on fitness.
        generation.forEach { (path) in
            if currentFitness <= fitness {
                // Increase the current fitness by the path's fitness relative to the total distance
                currentFitness += path.fitness(with: totalDistance)
                // Set the result as the selected path.
                result = path
            }
        }
        return result
    }
    
    /**
     Produces an offspring path by combining two parent paths.

     - Parameters:
        - firstParent: The first parent path.
        - secondParent: The second parent path.

     - Returns: A new Route representing the offspring.
     */
    
    private func produceChild(_ firstParent: Route, _ secondParent: Route) -> Route {
        
        // Select a random slice index to divide the parents' waypoints.
        let slice = Int(arc4random_uniform(UInt32(firstParent.waypoints.count)))
        var locations = [agostiniLocation]()
        
        // Add waypoints from the first parent up to the slice index.
        for index in 0..<slice {
            locations.append(firstParent.waypoints[index])
        }
        
        var index = slice
        
        // Add waypoints from the second parent to the child until all unique waypoints are included.
        while locations.count < secondParent.waypoints.count {
            let waypointToAdd = secondParent.waypoints[index]
            if !locations.contains(waypointToAdd) {
                locations.append(waypointToAdd)
            }
            index = (index + 1) % secondParent.waypoints.count
        }
        
        // Create a new Route with the generated child locations.
        return Route(waypoints: locations)
    }
    
    /**
     Applies mutation to a path with a given probability.

     - Parameters:
        - child: The path to potentially mutate.

     - Returns: The mutated path or the original path if mutation doesn't occur.
     */
    
    private func mutate(_ child: Route) -> Route {
        // Check if mutation should occur based on the mutation probability.
        // arc4random = random number generator
        if self.mutation >= Double(Double(arc4random()) / Double(UINT32_MAX)) {
            
            // Select two random indices to swap waypoints.
            let firstIdx = Int(arc4random_uniform(UInt32(child.waypoints.count)))
            let secondIdx = Int(arc4random_uniform(UInt32(child.waypoints.count)))
            
            // Create a copy of the child's waypoints and swap the waypoints at the selected indices.
            var mutatedWaypoints = child.waypoints
            mutatedWaypoints.swapAt(firstIdx, secondIdx)
            
            // Create a new Route with the mutated waypoints.
            return Route(waypoints: mutatedWaypoints)
        }
        
        // If mutation doesn't occur, return the original child path.
        return child
    }
    
    
    
}

/**
 Shuffles the elements of the array randomly.

 - Returns: A new array with elements randomly shuffled.
 */

extension Array {
    public func shuffle() -> [Element] {
        return sorted(by: { (_, _) -> Bool in
            return arc4random() < arc4random()
        })
    }
}

/**
 The maximum number of generations the genetic algorithm will iterate through.
 */

extension GeneticAlgorithm {
    static let numberOfGenerationsLimit = 3
}
