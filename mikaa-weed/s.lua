local QBCore = exports['qb-core']:GetCoreObject()

local function SendWebhookLog(title, description)
    if not Config.WebhookURL or Config.WebhookURL == "" then return end
    PerformHttpRequest(Config.WebhookURL, function(err, text, headers) end, 'POST', json.encode({
        username = "Mikababa AntiCheat",
        embeds = {{
            ["title"] = title,
            ["description"] = description,
            ["color"] = 16711680,
            ["footer"] = {
                ["text"] = "Mikababa Weed Sistemi"
            },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }), { ['Content-Type'] = 'application/json' })
end

RegisterNetEvent("mikababa:otver", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local distance = #(coords - Config.WeedZone.center)

    if distance <= 50.0 then 
        Player.lastWeedGather = Player.lastWeedGather or 0
        if GetGameTimer() - Player.lastWeedGather >= 5000 then
            Player.Functions.AddItem(Config.Items.GatherItem, Config.Amounts.GatherAmount)
            Player.lastWeedGather = GetGameTimer()
            TriggerClientEvent("QBCore:Notify", src, "Bir adet ot topladın!", "success")
        else
            TriggerClientEvent("QBCore:Notify", src, "Bu kadar hızlı toplayamazsın!", "error")
        end
    else
        local msg = ("🧨 **%s** (%s) toplama alanı dışında item almaya çalıştı!\nKoordinat: `%s`"):format(GetPlayerName(src), src, coords)
        print("[MİKABABA-ANTİCHEAT] " .. msg)
        SendWebhookLog("Hile Tespiti - Toplama", msg)
        if Config.DropPlayerOnExploit then
            DropPlayer(src, "Hile tespit edildi: izinsiz ot toplama.")
        end
    end
end)

RegisterServerEvent("mikababa:otisle")
AddEventHandler("mikababa:otisle", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local distance = #(coords - Config.ProcessingZone)

    if distance <= 15.0 then 
        Player.lastWeedProcess = Player.lastWeedProcess or 0
        if GetGameTimer() - Player.lastWeedProcess >= 5000 then
            if Player.Functions.RemoveItem(Config.Items.GatherItem, 1) then
                Player.Functions.AddItem(Config.Items.ProcessedItem, Config.Amounts.ProcessedAmount)
                Player.lastWeedProcess = GetGameTimer()
                TriggerClientEvent("QBCore:Notify", src, "Esrar işlendi!", "success")
            else
                TriggerClientEvent("QBCore:Notify", src, "Üzerinde esrar yok!", "error")
            end
        else
            TriggerClientEvent("QBCore:Notify", src, "Bu kadar hızlı işleyemezsin!", "error")
        end
    else
        local msg = ("🧨 **%s** (%s) işleme alanı dışında işlem yapmaya çalıştı!\nKoordinat: `%s`"):format(GetPlayerName(src), src, coords)
        print("[MİKABABA-ANTİCHEAT] " .. msg)
        SendWebhookLog("Hile Tespiti - İşleme", msg)
        if Config.DropPlayerOnExploit then
            DropPlayer(src, "Hile tespit edildi: izinsiz işleme.")
        end
    end
end)

QBCore.Functions.CreateCallback("mikababa:üzerimdeotvarmi", function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    local item = Player.Functions.GetItemByName(Config.Items.GatherItem)
    cb(item and item.amount > 0)
end)