-- PARA VER
exports("AddMoney", function(src, amount, type)
    type = type or "cash"
    amount = tonumber(amount)
    if not amount or amount <= 0 then return false end

    local steam
    for _, id in pairs(GetPlayerIdentifiers(src)) do
        if id:sub(1,6) == "steam:" then steam = id break end
    end
    if not steam then return false end

    if type == "cash" then
        exports.oxmysql:execute(
            "UPDATE player_money SET cash = cash + ? WHERE steam_hex = ?",
            { amount, steam }
        )
        TriggerClientEvent("money:updateCash", src, amount)

    elseif type == "bank" then
        exports.oxmysql:execute(
            "UPDATE player_money SET bank = bank + ? WHERE steam_hex = ?",
            { amount, steam }
        )
        TriggerClientEvent("money:updateBank", src, amount)
    end

    return true
end)

-- PARA ÇEK
exports("RemoveMoney", function(src, amount, type)
    type = type or "cash"
    amount = tonumber(amount)
    if not amount or amount <= 0 then return false end

    local steam
    for _, id in pairs(GetPlayerIdentifiers(src)) do
        if id:sub(1,6) == "steam:" then steam = id break end
    end
    if not steam then return false end

    local column = type == "bank" and "bank" or "cash"

    local result = exports.oxmysql:singleSync(
        "SELECT " .. column .. " FROM player_money WHERE steam_hex = ?",
        { steam }
    )

    if not result or result[column] < amount then
        return false
    end

    exports.oxmysql:execute(
        "UPDATE player_money SET " .. column .. " = " .. column .. " - ? WHERE steam_hex = ?",
        { amount, steam }
    )

    TriggerClientEvent(
        type == "bank" and "money:updateBank" or "money:updateCash",
        src,
        -amount
    )

    return true
end)

-- PARA BİLGİSİ AL
exports("GetMoney", function(src)
    local steam
    for _, id in pairs(GetPlayerIdentifiers(src)) do
        if id:sub(1,6) == "steam:" then steam = id break end
    end
    if not steam then return nil end

    return exports.oxmysql:singleSync(
        "SELECT cash, bank FROM player_money WHERE steam_hex = ?",
        { steam }
    )
end)

-- server.lua

RegisterNetEvent("money:requestSync")
AddEventHandler("money:requestSync", function()
    local src = source

    local steam
    for _, id in pairs(GetPlayerIdentifiers(src)) do
        if id:sub(1,6) == "steam:" then
            steam = id
            break
        end
    end
    if not steam then return end

    local result = exports.oxmysql:singleSync(
        "SELECT cash, bank FROM player_money WHERE steam_hex = ?",
        { steam }
    )

    if result then
        TriggerClientEvent("money:forceSync", src, result.cash, result.bank)
    end
end)
