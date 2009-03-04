namespace Mercury.Core

import System
import System.Collections.Generic
import Boo.Lang.Compiler
import Boo.Lang.Compiler.Ast

public class MercuryRouteBuilder:
"""Description of MercuryRouteBuilder"""
  def constructor():
    pass

  public static def BuildRouteClass(method as string, routeString as string, module as Module, body as Block) as ClassDefinition:
    rand = Random().Next()
      
    classDef = [|
      public class Mercury_route(IMercuryRouteAction):
        public def constructor():
          pass
          
        public def Execute():
          $(body)
        
        public HttpMethod as string:
          get:
            return $(method)
        public RouteString as string:
          get:
            return $(routeString)
    |]
    
    rawDependencies = GetDependenciesForClass(body, module)
    
    
    classDef = PopulateClassDefinitionWithFieldsAndConstructorParamsFromDependencies(classDef, rawDependencies)
    classDef.Name = classDef.Name  + rand
    
    return classDef
  
  public static def GetDependenciesForClass(body as Block, module as Module) as Dictionary[of string, ParameterDeclaration]:
    inActionDependencies = PullDependenciesFromMacroBody(body)
    moduleLevelDependencies = PullDependenciesFromModule(module)
    
    return MergeDependencyDictionaries(inActionDependencies, moduleLevelDependencies)
    
  
  public static def PullDependenciesFromMacroBody(body as Block) as Dictionary [of string, ParameterDeclaration]:
    dict = Dictionary[of string, ParameterDeclaration]()
    foo = [| foo as IMercuryRoute |]
    field = Field(foo.Type, [| null |])
    return dict
  
  public static def PullDependenciesFromModule(module as Module) as Dictionary [of string,ParameterDeclaration]:
    dict = Dictionary[of string, ParameterDeclaration]()
    return dict
    
  public static def MergeDependencyDictionaries(inAction as Dictionary [of string, ParameterDeclaration], moduleLevel as Dictionary [of string, ParameterDeclaration]) as Dictionary [of string, ParameterDeclaration]:
    return Dictionary[of string, ParameterDeclaration]()
  
  public static def PopulateClassDefinitionWithFieldsAndConstructorParamsFromDependencies(classDef as ClassDefinition, deps as Dictionary[of string, ParameterDeclaration]) as ClassDefinition:
    theType = [| typeof(System.String) |]
    classDef.GetConstructor(0).Parameters.Add(ParameterDeclaration("foo", theType.Type))
    
    return classDef