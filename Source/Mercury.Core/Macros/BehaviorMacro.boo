namespace Mercury.Core

import System
import System.Collections.Generic
import Boo.Lang.Compiler
import Boo.Lang.Compiler.Ast

public class BehaviorMacro(AbstractAstMacro):

  def constructor():
    pass
  
  public override def Expand(macro as MacroStatement) as Statement:
    
    raise ArgumentException("A 'safe reference identifier' name (eg something you'd use to name a class, method, local var, etc) is the only valid name for a behavior") if not macro.Arguments[0] isa ReferenceExpression
    target as string = string.Empty
    for i in macro.Body.Statements:
      target = i.ToString() if i["isTarget"]
    raise NoTargetException() if target.Equals(string.Empty)
    
    classDef = [|
      public class Behavior:
        
        public def constructor():
          pass
    |]
    parent as Node = macro
    while not parent isa Module:
      parent = parent.ParentNode
    
    (parent as Module).Members.Add(classDef)