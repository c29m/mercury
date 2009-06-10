namespace Mercury.Specs.RoutingEngine

import System
import Mercury.Core
import Mercury.Routing
import Msb
import Machine.Specifications
import System.Collections.Generic
import System.Linq.Enumerable from System.Core

when "having a stored route with a handler for foo/bar and receiving a request for /foo/bar", MatchingRequestsToRoutesInTheRouteTree:
  it "should return the route handler stored in the route"
  it "should have no parameters stored in the Values"

when "having a stored route with a handler for foo/bar/{baz} and receiving a request for foo/bar/42", MatchingRequestsToRoutesInTheRouteTree:
  it "should return the route handler stored in the route"
  it "should have a parameter in the Values named 'baz'"
  it "should have the baz parameter have a value of '42' as a string"

when "there is a route matching foo/{bar}/baz and a route matching foo/blah/baz and receiving a request for foo/blah/baz", MatchingRequestsToRoutesInTheRouteTree:
  it "should return the route handler for the foo/blah/baz route"
  it "should have no parameters in the Values"

when "there is a route matching foo/{bar}/baz and a route matching foo/blah/baz and receiving a request for foo/barf/baz", MatchingRequestsToRoutesInTheRouteTree:
  it "should return the route handler for the foo/{bar}/baz route"
  it "should have a parameter in Values named 'bar'"
  it "should have the 'bar' parameter have a value of 'barf'"

public class MatchingRequestsToRoutesInTheRouteTree:
  context_ as Establish = def():
    routeStringParser = RouteStringParser()
    routeTree = RouteTree()