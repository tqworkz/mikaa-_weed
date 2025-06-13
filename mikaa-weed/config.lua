Config = {}

Config.WeedZone = {
    center = vector3(-388.0738, 4324.0596, 54.4503), -- toplama merkezi
    spawnRadius = 40.0,
    interactRadius = 1.2
}

Config.ProcessingInteractRadius = 1.5 

Config.ProcessingZone = vector3(3818.7910, 4474.8936, 2.5) -- işleme yeri

Config.Props = {
    "prop_weed_01",
    "prop_weed_02"
}

Config.MaxProps = 50

Config.Items = {
    GatherItem = "weedplant_branch",      -- Toplanan ham ot itemi
    ProcessedItem = "unpacking_weed"      -- İşlenmiş esrar itemi
}

Config.Amounts = {
    GatherAmount = 1,     -- Her toplamada verilecek ot sayısı
    ProcessedAmount = 3   -- Her işlemde verilecek işlenmiş esrar sayısı
}

Config.DropPlayerOnExploit = true -- hile şüphesi drop player olsunmu?
Config.WebhookURL = "https://discord.com/api/webhooks/1381618360718065715/TRr3FpKwJcoeg-4IwLQcVYUcB63FNuBA18tjbMBkD1QOSCv5VtwFZimpVnYTs3eWfCgc" -- BURAYA kendi webhook URL'ini koy
