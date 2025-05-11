local Utils = {}

function Utils.lockDeep<T>(tbl: T): T
	local function freeze(t: { [any]: any })
		for k, v in pairs(t) do
			if type(v) == "table" then
				t[k] = freeze(v)
			end
		end
		return table.freeze(t)
	end
	return freeze(tbl :: any)
end

function Utils.copy<T>(t: T, deep: boolean?): T
	if not deep then
		return (table.clone(t :: any) :: any) :: T
	end
	local function DeepCopy(tbl: { any })
		local tCopy = table.clone(tbl)
		for k, v in tCopy do
			if type(v) == "table" then
				tCopy[k] = DeepCopy(v)
			end
		end
		return tCopy
	end
	return DeepCopy(t :: any) :: T
end

return Utils
