export type RemoteEventClass = {
    _instance:RemoteEvent,

    FireAll:(self:RemoteEventClass, ...any) -> nil,
    FireTo:(self:RemoteEventClass, Players:Player, ...any) -> nil,
    FireFor:(self:RemoteEventClass, players:{Player}, ...any) -> nil,
    FireExcept:(self:RemoteEventClass, except:Player, ...any) -> nil,
    FireFilter:(self:RemoteEventClass, predicate:(player:Player) -> boolean, ...any) -> nil,

    ClientEvent:RBXScriptSignal,
    ServerEvent:RBXScriptSignal,
}


return nil