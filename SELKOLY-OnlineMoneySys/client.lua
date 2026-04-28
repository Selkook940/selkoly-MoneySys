-- client.lua FINAL (WORKING HUD LOGIC)

local cash = 0
local bank = 0

RegisterNetEvent("money:forceSync")
AddEventHandler("money:forceSync", function(c, b)
    cash = tonumber(c) or 0
    bank = tonumber(b) or 0
    ApplyStats()
end)

function ApplyStats()
    StatSetInt(GetHashKey("BANK_BALANCE"), bank, true)
    StatSetInt(GetHashKey("MP0_WALLET_BALANCE"), cash, true)
end

-- 3 SANİYEDE 1 DATABASE SENKRON
CreateThread(function()
    while true do
        Wait(3000)
        TriggerServerEvent("money:requestSync")
    end
end)

-- HUD GÖSTERME (ALT)
CreateThread(function()
    local showing = false
    while true do
        Wait(0)
        if IsControlPressed(0, 19) then
            if not showing then
                showing = true
                ShowHUD()
            end
        else
            showing = false
        end
    end
end)

RegisterNetEvent("money:load")
AddEventHandler("money:load", function(c, b)
    cash = tonumber(c) or 0
    bank = tonumber(b) or 0
    ApplyStats()
end)

RegisterNetEvent("money:updateCash")
AddEventHandler("money:updateCash", function(amount)
    cash = cash + amount
    ApplyStats()
    ShowHUD()
end)

RegisterNetEvent("money:updateBank")
AddEventHandler("money:updateBank", function(amount)
    bank = bank + amount
    ApplyStats()
    ShowHUD()
end)

function ApplyStats()
    -- BANK (HUD tetikleyici stat)
    StatSetInt(GetHashKey("BANK_BALANCE"), bank, true)

    -- CASH (gerçek wallet)
    StatSetInt(GetHashKey("MP0_WALLET_BALANCE"), cash, true)
end

function ShowHUD()
    N_0x170f541e1cadd1de(true)
    SetMultiplayerWalletCash()
    SetMultiplayerBankCash()
    N_0x170f541e1cadd1de(false)

    Citizen.SetTimeout(5000, function()
        RemoveMultiplayerWalletCash()
        RemoveMultiplayerBankCash()
    end)
end

CreateThread(function()
    local showing = false

    while true do
        Wait(0)
        if IsControlPressed(0, 19) then
            if not showing then
                showing = true
                ShowHUD()
            end
        else
            showing = false
        end
    end
end)
