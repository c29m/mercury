namespace Mercury.Core

import System
import Boo.Lang.Compiler
import Boo.Lang.Compiler.Ast

class PrecedenceMacros:

  def constructor():
    pass
  
  public def RunsBeforeExpand(macro as MacroStatement) as Statement:
    raise "A single argument to runs_before is the only valid syntax: runs_before SomeBehavior" if macro.Arguments.Count != 1
    raise "It is only valid to do a runs_before by naming another behavior as its type: 'runs_before SomeBehavior' or 'runs_before Full.Name.Of.Behavior'" if not macro.Arguments[0] isa ReferenceExpression
    
    body as Block = macro.Body
    body.Annotate("isPrecedence", true)
    body.Annotate("precedenceType", Precedence.RunsBefore)
    body.Annotate("precedenceValue", macro.Arguments[0])
    return body
  
  public def RunsAfterExpand(macro as MacroStatement) as Statement:
    raise "A single argument to runs_after is the only valid syntax: runs_before SomeBehavior" if macro.Arguments.Count != 1
    raise "It is only valid to do a runs_after by naming another behavior as its type: 'runs_after SomeBehavior' or 'runs_after Full.Name.Of.Behavior'" if not macro.Arguments[0] isa MemberReferenceExpression
    
    body as Block = macro.Body
    body.Annotate("isPrecedence", true)
    body.Annotate("precedenceType", Precedence.RunsAfter)
    body.Annotate("precedenceValue", macro.Arguments[0])
    return body
  
  public def MustRunFirstExpand(macro as MacroStatement) as Statement:
    raise "No arguments are allowed to must_run_first" if macro.Arguments.Count != 0
    
    body as Block = macro.Body
    body.Annotate("isPrecedence", true)
    body.Annotate("precedenceType", Precedence.RunFirst)
    return body
  
  public def MustRunLastExpand(macro as MacroStatement) as Statement:
    raise "No arguments are allowed to must_run_last" if macro.Arguments.Count != 0
    
    body as Block = macro.Body
    body.Annotate("isPrecedence", true)
    body.Annotate("precedenceType", Precedence.RunLast)
    return body