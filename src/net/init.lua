---@diagnostic disable: undefined-type
local RunService = game:GetService("RunService")

local Type = require(script.Comm.Type)

type UniqueKey = {}
type PromiseLike = Type.PromiseLike

export type Type = {
	Controller: UniqueKey,
	Service: UniqueKey?,
}

export type ControllerInfo = {
	Name: string,
}

export type ServiceInfo = {
	Name: string,
	Network: {},
}

export type Controller = {
	_init: (self: Controller) -> nil,
	_start: (self: Controller) -> nil,

	Name: string,
}
export type Service = {
	Name: string,

	_init: (self: Service) -> nil,
	_start: (self: Service) -> nil,

	Name: string,
	Network: { [string]: any },

	GetEvent: (self: Service, eventName: string) -> Type.RemoteEventClass,
	GetProperty: (self: Service, propertyName: string) -> Type.PropertyClass,
	GetTableProperty: (self: Service, propertyName: string) -> Type.TablePropertyClass,
	GetFunction: (self: Service, functionName: string) -> Type.FunctionClass,
}
export type Network = {
	Event: (isUnreliable: boolean) -> UniqueKey,
	Property: (initValue: any, tableType: "Dictionary" | "Array"?) -> UniqueKey,
	Function: () -> UniqueKey,
}
export type Flag = {
	setFlag: (flagName: string, studio: boolean?, server: boolean?) -> nil,
	isFlagEnabled: (flagName: string) -> boolean,
	runIfFlag: <T>(flagName: string, fn: (...any) -> T?, ...any) -> T?,
	runIfNotFlag: <T>(flagName: string, fn: (...any) -> T?, ...any) -> T?,
}

export type Net = {
	Type: Type,

	Controller: (self: Net, controller: ControllerInfo) -> Controller,
	Service: (self: Net, service: ServiceInfo) -> Service,

	Network: Network,
	Flag: Flag,

	GetService: (self: Net, serviceName: string) -> Service,
	GetController: (self: Net, controllerName: string) -> Controller,

	OnLoad: (self: Service, services: { [string]: UniqueKey }) -> { [string]: Service | Controller },
	OnStart: (self: Net) -> PromiseLike,

	StartNet: (self: Net) -> PromiseLike,
}

export type NetworkEvent = Type.RemoteEventClass
export type NetworkProperty = Type.PropertyClass

if RunService:IsServer() then
	return require(script.Server) :: Net
else
	return require(script.Client) :: Net
end
