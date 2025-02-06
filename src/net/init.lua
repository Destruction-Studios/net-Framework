---@diagnostic disable: undefined-type
local RunService = game:GetService("RunService")

type UniqueKey = {}
type PromiseLike = {
    andThen:(self:PromiseLike, ...any) -> PromiseLike,
    catch:(self:PromiseLike, err:any) -> PromiseLike,
}

export type ModuleInfo = {
    Name:string
}
export type ControllerInfo = ModuleInfo
export type ServiceInfo = ModuleInfo & {
    Network: {[string]:any}
}
export type ModuleBase = ModuleInfo & {
    _init:(self:ModuleBase) -> nil,
    _start:(self:ModuleBase) -> nil,
}
export type Controller = ModuleBase & {
    Name:string,
}
export type Service = ModuleBase & {
    Name:string,
    Network: {[string]:any},
}
export type Network = {
    Event:(isUnreliable:boolean) -> UniqueKey,
    Property:() -> UniqueKey,
    Function:() -> UniqueKey,
}

export type Net = {
    Controller:(controller:ControllerInfo) -> Controller,
    Service:(service:ServiceInfo) -> Service,
    Network:Network,

    GetService:(serviceName:string) -> Service,
    GetController:(ServiceInfo:string) -> Controller,

    StartAll:(self:Net) -> PromiseLike,
}

local Type = require(script.Comm.Type)

export type NetworkEvent = Type.RemoteEventClass
export type NetworkProperty = Type.PropertyClass

if RunService:IsServer() then
    return require(script.Server) :: Net
else
    return require(script.Client) :: Net
end