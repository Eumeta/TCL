UUID = "5970ab74-a8f5-4607-8b34-41d8b5c7df1c"
TCB_config = "TCB.txt"
Original = {}
Altered = {}

function Get(ID_name)
	local value = Mods.BG3MCM.MCMAPI:GetSettingValue(ID_name, ModuleUUID)
	return value
end

function combineTables(t1, t2)
    local result = {}

    for _, v in ipairs(t1) do
        table.insert(result, v)
    end

    for _, v in ipairs(t2) do
        table.insert(result, v)
    end

    return result
end

function UniqueValues(tbl)
    local seen = {}
    local uniqueTbl = {}
    for _, value in ipairs(tbl) do
        if not seen[value] then
            seen[value] = true
            table.insert(uniqueTbl, value)
        end
    end
    return uniqueTbl
end

Ext.Osiris.RegisterListener("RequestTrade",4,"after",function(_,ID2,_,_)
	TimerLaunch(ID2.."prior",1000)
end)

Ext.Osiris.RegisterListener("TradeEnds",2,"before",function(ID,ID2)
	TimerLaunch(ID2.."check",1000)
end)

Ext.Osiris.RegisterListener("TimerFinished",1,"after",function(ID)
	if IsCharacter(string.sub(ID,1,-6)) == 1 and string.sub(ID,-5,-1) == "prior" then
		if Get("Include_sold") == true then
			ID = string.sub(ID,1,-6) 
			local pulled_list = Ext.Entity.Get(ID).InventoryOwner.Inventories[1].InventoryContainer.Items
			for k,v in pairs(pulled_list) do
				local name = ResolveTranslatedString(v.Item.DisplayName.NameKey.Handle.Handle)
				if name ~= "Gold" then
					table.insert(Original,name)
				end
			end
			table.sort(Original)
		end
	end
	if IsCharacter(string.sub(ID,1,-6)) == 1 and string.sub(ID,-5,-1) == "check" then
		ID = string.sub(ID,1,-6)
		local Items = Get("Names")
		local All = Items
		local delete_list = {}
		local pulled_list = Ext.Entity.Get(ID).InventoryOwner.Inventories[1].InventoryContainer.Items
		if Get("Include_sold") == true then
			for k,v in pairs(pulled_list) do
				local name = ResolveTranslatedString(v.Item.DisplayName.NameKey.Handle.Handle)
				if name ~= "Gold" then
					table.insert(Altered,name)
				end
			end
			table.sort(Altered)
			for i = #Altered,1,-1 do
				for k,v in pairs(Original) do
					if Altered[i] == v then
						table.remove(Altered,i)
					end
				end
			end
			if #Altered > 0 then
				All = combineTables(All,Altered)
				All = UniqueValues(All)
			end
			table.sort(All)
			Original = {}
			Altered = {}
		end
		for k, v in pairs(pulled_list) do
			local name = ResolveTranslatedString(v.Item.DisplayName.NameKey.Handle.Handle)
			for x, y in pairs(All) do
				if (name == y and name ~= "Gold" and v.Item.Value.Rarity == 0 and Get("Restriction") == true ) or
					(name == y and name ~= "Gold" and Get("Restriction") == false) then
					table.insert(delete_list,v.Item.Uuid.EntityUuid)
				end
			end
		end
		if #delete_list == 0 then
			goto out
		else	
			for i = #delete_list,1,-1 do
				RequestDelete(delete_list[i])
			end
		end
	end
::out::		
end)
