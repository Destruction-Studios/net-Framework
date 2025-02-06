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

return nil