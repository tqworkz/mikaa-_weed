local QBCore = exports['qb-core']:GetCoreObject()
local spawnedProps = {}
local isSpawned = false
local isProcessing = false

local function SpawnPropsAround(center, radius)
    local currentCount = #spawnedProps

    if currentCount >= Config.MaxProps then
        print("Zaten maksimum prop sayısına ulaşıldı.")
        return
    end
    local remaining = Config.MaxProps - currentCount
    for i = 1, remaining do
        local offsetX = math.random(-radius, radius)
        local offsetY = math.random(-radius, radius)
        local pos = vector3(center.x + offsetX, center.y + offsetY, center.z)
        local model = Config.Props[math.random(1, #Config.Props)]
        RequestModel(model)
        while not HasModelLoaded(model) do Wait(10) end
        local obj = CreateObject(model, pos.x, pos.y, pos.z - 1.0, false, false, false)
        PlaceObjectOnGroundProperly(obj)
        FreezeEntityPosition(obj, true)
        table.insert(spawnedProps, obj)
    end
end

local function DeleteSpawnedProps()
    for _, obj in pairs(spawnedProps) do
        if DoesEntityExist(obj) then
            DeleteObject(obj)
        end
    end
    spawnedProps = {}
end

-- Toplama yaparken efrontenin anasini sikiyorum
CreateThread(function()
    while true do
        Wait(1000)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local center = Config.WeedZone.center
        local distance = #(playerCoords - center)

        if distance < Config.WeedZone.spawnRadius and not isSpawned then
            local facewear = GetPedDrawableVariation(playerPed, 1)
            if facewear == 0 then
                QBCore.Functions.Notify("Maske takmadan bu bölgeye girmen riskli!", "error")
            end
            SpawnPropsAround(center, Config.WeedZone.spawnRadius)
            isSpawned = true
        elseif distance >= Config.WeedZone.spawnRadius and isSpawned then
            DeleteSpawnedProps()
            isSpawned = false
        end
    end
end)

-- Toplama işlemi
CreateThread(function()
    while true do
        Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        for i, obj in pairs(spawnedProps) do
            if DoesEntityExist(obj) then
                local objCoords = GetEntityCoords(obj)
                local distance = #(playerCoords - objCoords)

                if distance < Config.WeedZone.interactRadius then
                    QBCore.Functions.DrawText3D(objCoords.x, objCoords.y, objCoords.z + 1.0, "[E] Ot Topla")

                    if IsControlJustPressed(0, 38) then
                        RequestAnimDict("amb@world_human_gardener_plant@male@base")
                        while not HasAnimDictLoaded("amb@world_human_gardener_plant@male@base") do Wait(10) end
                        TaskPlayAnim(playerPed, "amb@world_human_gardener_plant@male@base", "base", 8.0, -8, -1, 1, 0, false, false, false)

                        QBCore.Functions.Progressbar("efronte_anasik", "Toplanıyor...", 5000, false, true, {
                            disableMovement = true,
                            disableCarMovement = true,
                            disableMouse = false,
                            disableCombat = true,
                        }, {}, {}, {}, function()
                            ClearPedTasks(playerPed)
                            TriggerServerEvent("mikababa:otver")
                            DeleteObject(obj)
                            table.remove(spawnedProps, i)
                        end, function()
                            ClearPedTasks(playerPed)
                            QBCore.Functions.Notify("Toplama iptal edildi!", "error")
                        end)
                    end
                end
            end
        end
    end
end)

-- Efrontenin anasini sikme işlemi
CreateThread(function()
    while true do
        Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local distance = #(playerCoords - Config.ProcessingZone)

        if distance < 5.0 then
            QBCore.Functions.DrawText3D(Config.ProcessingZone.x, Config.ProcessingZone.y, Config.ProcessingZone.z + 1.0, "[E] Esrar işle")

            if IsControlJustPressed(0, 38) and not isProcessing then
                QBCore.Functions.TriggerCallback("mikababa:üzerimdeotvarmi", function(hasItem)
                    if hasItem then
                        isProcessing = true

                        RequestAnimDict("amb@prop_human_parking_meter@male@idle_a")
                        while not HasAnimDictLoaded("amb@prop_human_parking_meter@male@idle_a") do Wait(10) end
                        TaskPlayAnim(playerPed, "amb@prop_human_parking_meter@male@idle_a", "idle_a", 8.0, -8.0, -1, 1, 0, false, false, false)

                        QBCore.Functions.Progressbar("esrar_isleme", "Esrar işleniyor...", 5000, false, true, {
                            disableMovement = true,
                            disableCarMovement = true,
                            disableMouse = false,
                            disableCombat = true,
                        }, {}, {}, {}, function()
                            ClearPedTasks(playerPed)
                            TriggerServerEvent("mikababa:otisle")
                            isProcessing = false
                        end, function()
                            ClearPedTasks(playerPed)
                            QBCore.Functions.Notify("İşleme iptal edildi!", "error")
                            isProcessing = false
                        end)
                    else
                        QBCore.Functions.Notify("Üzerinde esrar yok!", "error")
                    end
                end)
            end
        end
    end
end)
