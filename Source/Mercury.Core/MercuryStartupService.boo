namespace Mercury.Core

import System
import System.Collections.Generic
import System.Text.RegularExpressions
import System.Reflection
import System.Web.Routing
import System.Web.Mvc
import Microsoft.Practices.ServiceLocation

public class MercuryStartupService:
  
  private _uninstantiatedRoutes as IEnumerable of Type;
  private _container as object
  private _viewEngines as ViewEngineCollection
  private _behaviorProcessor as BehaviorProcessor
  
  def constructor(container as IServiceLocator, viewEngines as ViewEngineCollection):
    self._container = container
    self._viewEngines = viewEngines
    
    _behaviorProcessor = BehaviorProcessor()
    
  public def BuildRoutes() as IEnumerable of Route:
    assemblies = System.AppDomain.CurrentDomain.GetAssemblies()
    _uninstantiatedRoutes = ParseAssembliesForUninstantiatedRoutes(assemblies)
    _behaviors = ParseAssembliesForBehaviors(assemblies)
    routes = List of Route()
    notFoundRoute as MercuryRoute
    for routeType in _uninstantiatedRoutes:
      routeAction = routeType.GetConstructor(array(typeof(Type), 0)).Invoke(array(typeof(Type), 0)) as IMercuryRouteAction
      behaviorRouteString = (routeAction.RouteString if not routeAction.RouteString == "{*url}" else "not_found")
      behaviorsForThisRoute = GetBehaviorsForRoute(behaviorRouteString, _behaviors)
      if routeAction.RouteString == "{*url}":
        raise "cannot have multiple not_found routes!" if not notFoundRoute is null
        notFoundRoute = MercuryRoute(routeAction.RouteString, MercuryRouteHandler(_container, routeType, _viewEngines, behaviorsForThisRoute), routeAction.HttpMethod)
      else:
        routes.Add(MercuryRoute(routeAction.RouteString, MercuryRouteHandler(_container, routeType, _viewEngines, behaviorsForThisRoute), routeAction.HttpMethod))
    
    routes.Add(notFoundRoute) if not notFoundRoute is null
    return routes
  
  public def GetBehaviorsForRoute(route as string, allBehaviors as Type*) as Type*:
    allBehaviorsForRoute = GetBehaviorsThatTarget(route, allBehaviors)
    instances = List of IBehavior()
    for i in allBehaviorsForRoute:
      instances.Add(Instantiate(i))
    return GetOrderedTypesFrom(instances)
  
  public def GetOrderedTypesFrom(instances as IBehavior*) as Type*:
    orderedBehaviors = List of Type()
    orderedTemp = _behaviorProcessor.OrderBehaviors(instances)
    for i in orderedTemp:
       orderedBehaviors.Add(i.GetType())
    return orderedBehaviors
  
  public def GetBehaviorsThatTarget(route as string, allBehaviors as Type*) as Type*:
    behaviorsForThisRoute = List of Type()
    for behaviorType in allBehaviors:
      instance = Instantiate(behaviorType)
      isTargetted = false
      for target in instance.Targets:
        isTargetted = true if Regex(target).IsMatch(route)
        break if isTargetted
      behaviorsForThisRoute.Add(behaviorType) if isTargetted
    
    behaviorsForThisRouteWithoutTargetNots = List of Type()
    for behaviorType in behaviorsForThisRoute:
      instance = Instantiate(behaviorType)
      isTargetted = true
      for targetNot in instance.TargetNots:
        isTargetted = false if Regex(targetNot).IsMatch(route)
        break if not isTargetted
      behaviorsForThisRouteWithoutTargetNots.Add(behaviorType) if isTargetted
    
    return behaviorsForThisRouteWithoutTargetNots
  
  public def Instantiate(behaviorType as Type) as IBehavior:
    return behaviorType.GetConstructor(array(typeof(Type), 0)).Invoke(array(typeof(Type), 0)) as IBehavior
  
  public def ParseReferencedAssembliesForTypesThatImplement(assemblies as Assembly*, iface as Type) as Type*:
    types = List of Type();
    for assembly in assemblies:
      for type in assembly.GetTypes():
        if iface in (type.GetInterfaces()):
          types.Add(type)
    return types
  
  public def ParseAssembliesForBehaviors(assemblies as Assembly*) as Type*:
    return ParseReferencedAssembliesForTypesThatImplement(assemblies, typeof(IBehavior))
  
  public def ParseAssembliesForUninstantiatedRoutes(assemblies as Assembly*) as Type*:
    return ParseReferencedAssembliesForTypesThatImplement(assemblies, typeof(IMercuryRouteAction))