//  Price Allman
//  makeRoute.swift
//  Shortcut


import Foundation
import MapboxMaps
import MapboxNavigation
import MapboxCoreNavigation
import MapboxDirections
import MapKit

// A delegate-protocol used to pass errors to a view controller.
protocol ErrorDelegate: class {
    func catchError(_ error: Error)
}

class makeRoute {
    
    weak var errorDelegate: ErrorDelegate?
    
    // An array where all the places that need to be visited are stored.Position 0 represents the starting point.
    
    var locationsToVisit: [MKMapItem]
    
    // The matrix where all the routes from each place to every other one are stored.
    lazy var routesMatrix: [[MKRoute]] = {
        // Initialize as a n*n matrix, where n is the number of elements from the array with map items.
        var matrixReturn = [[MKRoute]]()
        
        // Initialize as a n*n matrix, where n is the number of elements from the array with map items.
        var n = locationsToVisit.count
        var row = [MKRoute]()
        for _ in 0...n {
            row.append(MKRoute())
        }
        for _ in 0...n {
            matrixReturn.append(row)
        }
        return matrixReturn
    }()
    
    
    var totalCalculatedRoutes = 0
    // The DispatchGroup that tracks if the routes Matrix is ready to use.
    let rmDispatchGroup = DispatchGroup()
    
    init (with locationsToVisit: [MKMapItem]) {
        self.locationsToVisit = locationsToVisit
    }
    
    //Calculate all the routes from each place to every other one and save them in the routesMatrix.Each route calculation process is asynchronous. Must be used only within rmDispatchGroup.notify(), otherwise, the matrix might be either empty or not completed.
    
    func addToMatrix() {
        for rowIndex in 0...(locationsToVisit.count-1) {
            for columnIndex in 0...(locationsToVisit.count-1) {
                // We don't need to calculate the distance from a place to itself.
                if rowIndex != columnIndex {
                    calculateRouteAddToMatrix(from: locationsToVisit[rowIndex], to: locationsToVisit[columnIndex], at: (row: rowIndex, column: columnIndex))
                }
            }
        }
    }
    
    // Return, through a completion handler, the routes and the names of the places, in the optimal order. Will be passed to the ViewController as the final result.
    
    func findBestPath(completionHandler: @escaping ([MKRoute], [String]) -> Void) {
       
        // Enter the DispatchGroup to start monitoring route calculations.
        rmDispatchGroup.enter()
        
        // Start calculating the routes for all possible combinations of places.
        addToMatrix()
        
        // Wait until the routesMatrix is completed and ready to use.
        rmDispatchGroup.notify(queue: .main, execute: {
            
            // At this point, we know that the matrix is ready to use.
            
            // Create an array of waypoints representing each place to visit.
            var waypoints = [agostiniLocation]()
            for index in 0..<self.locationsToVisit.count {
                let waypoint = agostiniLocation(location: index)
                waypoints.append(waypoint)
            }
            
            // Create a matrix with distances between places.
            var distancesMatrix = [[Double]](repeating:[Double](repeating:0, count: self.locationsToVisit.count), count: self.locationsToVisit.count)

            for rowIndex in 0...(self.locationsToVisit.count-1) {
                for columnIndex in 0...(self.locationsToVisit.count-1) {
                    // We don't need to calculate the distance from a place to itself.
                    if rowIndex != columnIndex {
                        distancesMatrix[rowIndex][columnIndex] = self.routesMatrix[rowIndex][columnIndex].distance
                    }
                    else {
                        distancesMatrix[rowIndex][columnIndex] = 0
                    }
                }
            }
            
                // Initialize a genetic algorithm with waypoints and distancesMatrix.
                let ga = GeneticAlgorithm(for: waypoints, with: distancesMatrix)
                // Define a closure to execute when a new generation is created.
                ga.newerGeneration = {
                    (path, generation) in
                    DispatchQueue.main.async {
                        // When the algorithm has finished, process the result and send it to the VC
                        if generation == GeneticAlgorithm.numberOfGenerationsLimit {
                            let (bestRoute, orderedBestRouteNames) = self.getBestPath(of: self.locationsToVisit, accordingTo: path)
                            completionHandler(bestRoute, orderedBestRouteNames)
                        }
                    }
                }
                // Start the genetic algorithm.
                ga.startLoop()
            
        })
    }
    
    /**
     Calculate the optimal route based on map items and a genetic algorithm-generated path.
     
     - Parameters:
        - mapItems: An array of MKMapItem objects representing places to visit.
        - path: The genetic algorithm-generated path with waypoints.

     - Returns: A tuple containing an array of MKRoute objects representing the optimal route,
                and an array of place names in the order of the route.
     */
    
    func getBestPath(of mapItems: [MKMapItem], accordingTo path: Route) -> ([MKRoute], [String]) {
        
        // Create a new path, keeping the same order, but having the waypoint with the position 0 (which represents the starting point) as the first and also the last item in the path in a shift-like way.
        
        let newPath = Route(waypoints: [agostiniLocation(location: 0)])
        newPath.waypoints.removeAll()
         var startingIndex = 0
        
        // Find the waypoint with the position 0.
        for index in 0..<path.waypoints.count {
            if path.waypoints[index].location == 0 {
                startingIndex = index
            }
        }
        
        // Add it and all his right elements at the beginning of the new path.
        for index in startingIndex..<path.waypoints.count {
            newPath.waypoints.append(path.waypoints[index])
        }
        // Append the rest of the elements.
        for index in 0..<startingIndex {
            newPath.waypoints.append(path.waypoints[index])
        }
        
        // Add the starting point element one more time, at the end, to have a cycle.
        newPath.waypoints.append(path.waypoints[startingIndex])
        
        // Create a new array with routes, in an optimal "traveling salesman" order.
        var routes = [MKRoute]()
        var names = [String]()
        
        // Loop through each waypoint in the newPath
        for index in 0..<newPath.waypoints.count-1 {
            // Extract the source location of the current path segment
            let pathSource = newPath.waypoints[index].location
            // Get the name associated with the source location from the mapItems
            let pathSourceName = mapItems[pathSource].name
            // Extract the destination location of the current path segment
            let pathDestination = newPath.waypoints[index+1].location
            // Retrieve the route from the routesMatrix based on the source and destination locations
            routes.append(routesMatrix[pathSource][pathDestination])
            // Add the name of the source location to the names array
            names.append(pathSourceName!)
        }
        // Add the name of the last waypoint's location to the names array
        names.append(mapItems[(newPath.waypoints.last?.location)!].name!)
        // Return a tuple containing the routes and names arrays
        return (routes, names)
    }
    
    /**
     
     Calculate the route between two map items and add it to the routesMatrix.
     
     The rmDispatchGroup will be notified after the last required distance is
     calculated.
     */
    func calculateRouteAddToMatrix(from source: MKMapItem, to destination: MKMapItem, at position: (row: Int, column: Int)) {
        
        // Create a request for route directions
        let routeDirectionRequest = MKDirections.Request()
        // Set the source of the route to the specified MKMapItem
        routeDirectionRequest.source = source
        // Set the destination of the route to the specified MKMapItem
        routeDirectionRequest.destination = destination
        // Specify the preferred transport type for the route, in this case, .automobile (car)
        routeDirectionRequest.transportType = .automobile
        // Specify whether to request alternate routes in addition to the primary route
        routeDirectionRequest.requestsAlternateRoutes = true
        // Create a MKDirections object with the specified request
        let directions = MKDirections(request: routeDirectionRequest)
        // Calculate the route using the specified directions
        directions.calculate(completionHandler: {
            (response, error) in
            
            // Check if there is a response
            guard let response = response else {
                // If there's an error, print the source and destination, notify the errorDelegate, and log the error
                if let error = error {
                    print(source, destination)
                    // pass the error to the view controller
                    self.errorDelegate?.catchError(error) //pass the error to the view controller
                    print("Error: \(error)")
                }
                return
            }
            
            // Get the first route from the response
            let route = response.routes[0]
            // Add the calculated route to the routesMatrix at the specified position
            self.routesMatrix[position.row][position.column] = route
            // Increment the totalCalculatedRoutes counter
            self.totalCalculatedRoutes += 1
            // Notify the DispatchGroup that the last route was calculated
            // and the routesMatrix is ready to use
            let requiredNumberOfDistances = self.locationsToVisit.count * self.locationsToVisit.count - self.locationsToVisit.count
            if self.totalCalculatedRoutes == requiredNumberOfDistances {
                self.rmDispatchGroup.leave()
            }
        })
    }
}


