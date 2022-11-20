--[[ Variable(s) ]]--
--//Service(s)
local Players = game:GetService("Players");
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--//Object(s)
--/Player
local player = Players.LocalPlayer;

--/Folder(s)
local mobsFolder = workspace:WaitForChild("Living"):WaitForChild("Mobs");
local RF = ReplicatedStorage:WaitForChild'Knit':WaitForChild'Services':WaitForChild'interactService':WaitForChild'RF';
--//Array(s)
local QUESTLABELS = {} do
    for i,v in pairs(player.PlayerGui.UINoReset.Quests.QuestsFrame:GetChildren()) do
        QUESTLABELS[i] = v:FindFirstChild("Label") or nil;
    end
end

local quests = {
    start = {
        shrooms = {"ShroomSideQuest","begin","Shrooms","Confirm", CFrame = CFrame.new(-343, 146, 330)};
        bandits = {"BanditSideQuest","begin","Bandits","Confirm", CFrame = CFrame.new(-170.759781, 154.134995, 173.60585, -0.622503459, -2.81734263e-08, -0.782617092, -8.66240768e-08, 1, 3.29028857e-08, 0.782617092, 8.8275641e-08, -0.622503459)};
        ["armed bandits"] = {"BanditSideQuest","begin","Armed Bandits","Confirm", CFrame = CFrame.new(-170.759781, 154.134995, 173.60585, -0.622503459, -2.81734263e-08, -0.782617092, -8.66240768e-08, 1, 3.29028857e-08, 0.782617092, 8.8275641e-08, -0.622503459)};
        juniors = {"StudentSideQuest","begin","Juniors","Confirm", CFrame = CFrame.new(1217, 201, 108)};
        seniors = {"StudentSideQuest","begin","Seniors","Confirm", CFrame = CFrame.new(1217, 201, 108)};
        ["fly heads"] = {"EnrolmentCurseQuest","begin","Fly Heads","Confirm", CFrame = CFrame.new(986, 197, 147)};
        ["fire shrooms"] = {"EnrolmentCurseQuest","begin","Fire Shrooms","Confirm", CFrame = CFrame.new(986, 197, 147)};
        ["rogue sorcerers"] = {"MidoriPrimarySideQuests","begin","Rogue Sorcerers","Confirm", CFrame = CFrame.new(190, 119, -867)};
        crabions = {"MidoriPrimarySideQuests","begin","Crabions","Confirm", CFrame = CFrame.new(190, 119, -867)};
        gnashers = {"MidoriPrimarySideQuests","begin","Gnashers","Confirm", CFrame = CFrame.new(190, 119, -867)},
        hanamatos = {"Yuzi2","begin","Gnashers","Confirm", CFrame = CFrame.new(190, 119, -867)}
    },

    complete = {
        shrooms = {"ShroomSideQuest","talk","Bye"};
        bandits = {"BanditSideQuest","talk","Bye"};
        ["armed bandits"] = {"BanditSideQuest","talk","Bye"};
        juniors = {"StudentSideQuest","talk","Bye"};
        seniors = {"StudentSideQuest","talk","Bye"};
        ["fly heads"] = {"EnrolmentCurseQuest","talk","Bye"};
        ["fire shrooms"] = {"EnrolmentCurseQuest","talk","Bye"};
        ["rogue sorcerers"] = {"MidoriPrimarySideQuests","talk","Bye"};
        crabions = {"MidoriPrimarySideQuests","talk","Bye"};
        gnashers = {"MidoriPrimarySideQuests","talk","Bye"},
        hanamatos = {"Yuzi2","talk","Bye"}
    }
}


--//Enviroment(s)
getgenv().MoneyFarmToggled = false
getgenv().Autofarm = false
getgenv().modulesFarm = false
getgenv().notDestroyed = false
getgenv().VERSION = 1.0

--//TEMP_VARIABLE(s)
local selectedTool;
local selectedMobName;

--[[ Function(s) ]]--
-- misc
local function getMob(MobName)
    local dist,mob = math.huge
    for i,v in next, workspace.Living.Mobs:GetChildren() do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v.Name == MobName and v:FindFirstChild("HumanoidRootPart") then
            local mag = (player.Character:FindFirstChild("HumanoidRootPart").Position - v.HumanoidRootPart.Position).magnitude
            if dist > mag then
                dist = mag
                mob = v
            end
        end
    end
    return mob
end

local function questController(completed)
    
    if completed then
        local array = quests.complete[selectedMobName]
        player.Character:FindFirstChild("HumanoidRootPart").CFrame = quests.start[selectedMobName].CFrame;
        task.wait(.25);
        RF.GetInitFunction:InvokeServer(array[1]);                                
        task.wait(.25);
        RF.GetDialogue:InvokeServer(array[1],array[2]);
        task.wait(.25);
        RF.GetOptionData:InvokeServer(array[1],array[3]); 
    else
        local array = quests.start[selectedMobName]
        player.Character:FindFirstChild("HumanoidRootPart").CFrame = array.CFrame;
        task.wait(.25);
        RF.GetInitFunction:InvokeServer(array[1],array[2]);                                
        task.wait(.5);
        RF.GetOptionData:InvokeServer(array[1],array[3]);
        task.wait(.5);
        RF.GetOptionData:InvokeServer(array[1],array[4]);
        task.wait(1.5);
    end
end

-- tools
local function equip()
    if not player.Character:FindFirstChild(selectedTool) then
        
        if player.Backpack:FindFirstChild(selectedTool) then
            player.Character:FindFirstChild("Humanoid"):EquipTool(player.Backpack:FindFirstChild(selectedTool));
        end

    end

    return player.Character:FindFirstChild(selectedTool);
end

local function attack(tool)
    local tool:Tool = equip();

    if tool then
        tool:Activate();
    end
end


-- main
local function autoFarm()

    local enemy;
    while getgenv().Autofarm do
        if player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("Humanoid").Health > 0 then
            print"running";
            equip();
    
            if QUESTLABELS[1].Text:lower():find("5/5") or QUESTLABELS[1].Text:lower():find("1/1") then
                print("finished quest");
                questController(true);
            end
            
            if QUESTLABELS[1].Text:len() <= 0 then
                print"checking quest";
                questController(false);
            end
    
            if not enemy or not enemy:FindFirstChild("HumaoidRootChild") or (enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health <= 0) then
                print"getting new enemy";
                local name = quests.start[selectedMobName][3]
                name = string.sub(name,1,name:len()-1)
                enemy = getMob(name); 
            end
    
            if enemy and player.Character:FindFirstChild("Humanoid").Health > 0 then
                print("got enemy")
                local mobPos = enemy.HumanoidRootPart.Position;
                player.Character:FindFirstChild("HumanoidRootPart").CFrame = CFrame.new((mobPos + Vector3.new(0,-4.75,0)), mobPos)
                attack();
            end
        end
        
        task.wait();    end
end

local function moduleOpen()
    if getgenv().modulesFarm then
        player.Character:FindFirstChild("HumanoidRootPart").CFrame = CFrame.new(1060,203,55);
        task.wait();
        RF.GetInitFunction:InvokeServer("ModuleNPC2");
        task.wait(.25);
        RF.GetDialogue:InvokeServer("ModuleNPC2","start");
        task.wait(.25);
        RF.GetOptionData:InvokeServer("ModuleNPC2","Yes");
        task.wait(.25)
        moduleOpen();
    end
end

--//LAST
local function createGUI()
    local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/oujaboard/cuddly-waddle/main/OrionUILibReuploadNoDiscord')))()
    local Window = OrionLib:MakeWindow({Name = "Kaizen Script by Tetsu", HidePremium = false, SaveConfig = true, ConfigFolder = "Tetsu"})
    getgenv().notDestroyed = true
    local AutofarmTab = Window:MakeTab({
        Name = "Autofarm",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })

    local Section = AutofarmTab:AddSection({
        Name = "Kaizen"
    })

    local function refresh()
        local t = {};
        for i,v in pairs(game.Players.LocalPlayer:WaitForChild("Backpack"):GetChildren()) do 
            table.insert(t, v.Name)
        end
        return t;
    end

    local function getArrayName(value)
        return value:lower():split(" | ")[1]
    end

    invdrpd = AutofarmTab:AddDropdown({
        Name = "Autofarm Tools",
        Default = "",
        Options = refresh(),
        Callback = function(Value)
            selectedTool = Value
        end    
    })

    player.Backpack.Changed:Connect(function(child)
        invdrpd:Refresh(refresh(),true);
    end)

    AutofarmTab:AddDropdown({
        Name = "Select Autofarm",
        Default = "",
        Options = {"Bandits | 5+", "Armed Bandits | 15+", "Shrooms | 30+", "Juniors | 45+", "Seniors | 65+", "Fly Heads | 80+", "Fire Shrooms | 110+", "Rogue Sorcerers | 125+", "Crabions | 140+", "Gnashers | 160+", "Hanamatos | 130+"},
        Callback = function(Value)
            selectedMobName = getArrayName(Value);
            print("Selected "..selectedMobName.." quest for autofarm.")
        end    
    })

    AutofarmTab:AddToggle({
        Name = "Autofarm Toggle",
        Default = false,
        Callback = function(Value)
            getgenv().modulesFarm = false
            getgenv().Autofarm = Value
            if getgenv().Autofarm then
                autoFarm();
            end
        end    
    })

    AutofarmTab:AddToggle({
        Name = "Modules Open Toggle (Make sure to have it out in your hand!)",
        Default = false,
        Callback = function(Value)
            getgenv().Autofarm = false
            getgenv().modulesFarm = Value
            
            if getgenv().modulesFarm then
                moduleOpen();
            end
        end    
    })
    
    AutofarmTab:AddLabel(string.format("V%s",getgenv().VERSION))
    

    task.spawn(function()
        while (getgenv().notDestroyed) do
            invdrpd:Refresh(refresh(),true);
            task.wait(.5);
        end
    end)
end
createGUI();
