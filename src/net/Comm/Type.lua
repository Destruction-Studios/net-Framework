export type PromiseLike = {
    andThen:(self:PromiseLike, ...any) -> PromiseLike,
    catch:(self:PromiseLike, err:any) -> PromiseLike,
}

export type RemoteEventClass = {
    _instance:RemoteEvent,

    FireAll:(self:RemoteEventClass, ...any) -> nil,
    FireTo:(self:RemoteEventClass, Players:Player, ...any) -> nil,
    FireFor:(self:RemoteEventClass, players:{Player}, ...any) -> nil,
    FireExcept:(self:RemoteEventClass, except:Player, ...any) -> nil,
    FireFilter:(self:RemoteEventClass, predicate:(player:Player) -> boolean, ...any) -> nil,

    Fire:(self:RemoteEventClass, ...any) -> nil,

    ClientEvent:RBXScriptSignal,
    ServerEvent:RBXScriptSignal,
}

export type PropertyClass<T> = {
    _instance:StringValue,

    Get:(self:PropertyClass<T>) -> T,

    Set:(self:PropertyClass<T>) -> T,

    Changed:RBXScriptSignal
}

export type TablePropertyClass = {
    _value:{any},
    _isDict:boolean,
    _remote:RemoteEvent,
    _ready:boolean,

    Get:(self:TablePropertyClass) -> any,

    OnReady:(self:TablePropertyClass) -> PromiseLike,

    Key:<T>(self:TablePropertyClass, key:string, value:T) -> T,
    Insert:<T>(self:TablePropertyClass, value:T) -> T,
    Find:(self:TablePropertyClass, value:any, init:number?) -> number?,
    Remove:(self:TablePropertyClass, index:number?) -> any?,
}

export type FunctionClass = {
    _instance:RemoteFunction,

    Invoke:(self:FunctionClass, ...any) -> any,
    SetInvokeFunction:(self:FunctionClass, fn:(player:Player, ...any)->any) -> nil,
}

return nil