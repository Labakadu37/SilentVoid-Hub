-- [[ ZentyHub - Version Forcée ]] --
-- Ce script tente de trouver l'événement de Kick même s'il est caché

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Bouton Auto-Perfect (Code mis à jour)
_G.AutoPerfect = true -- Change en false pour arrêter

task.spawn(function()
    while _G.AutoPerfect do
        task.wait(0.1)
        pcall(function()
            -- Au lieu de chercher un nom fixe, on scanne TOUT le jeu à la recherche du système de Kick
            for _, v in pairs(ReplicatedStorage:GetDescendants()) do
                if v:IsA("RemoteEvent") and (v.Name:lower():find("kick") or v.Name:lower():find("hit")) then
                    -- On envoie la valeur maximale (999 ou 100 selon le système)
                    v:FireServer(100)
                    v:FireServer(true)
                end
            end
        end)
    end
end)

-- Bouton Auto-Collect par "Magnétisme" (Plus discret que la téléportation)
_G.AutoCollect = true

task.spawn(function()
    while _G.AutoCollect do
        task.wait(0.5)
        pcall(function()
            -- On cherche ton terrain de jeu
            for _, zone in pairs(workspace:GetChildren()) do
                if zone.Name:find("Plot") or zone.Name:find("Tycoon") then
                    if zone:FindFirstChild("Owner") and zone.Owner.Value == LocalPlayer then
                        -- On agrandit le bouton de collecte pour qu'il aspire l'argent tout seul sans te faire bouger
                        local pad = zone:FindFirstChild("GreenPad") or zone:FindFirstChild("Collect")
                        if pad then
                            pad.Size = Vector3.new(50, 50, 50) -- Devient géant
                            pad.Transparency = 1 -- Reste invisible pour ne pas gâcher la vue
                            pad.CanCollide = false
                        end
                    end
                end
            end
        end)
    end
end)
