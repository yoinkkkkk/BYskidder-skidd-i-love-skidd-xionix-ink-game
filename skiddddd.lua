local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Workspace=game:GetService("Workspace")
local UserInputService=game:GetService("UserInputService")
local CoreGui=game:GetService("CoreGui")
local HttpService=game:GetService("HttpService")
local RunService=game:GetService("RunService")
local SoundService=game:GetService("SoundService")
local Lighting=game:GetService("Lighting")
local TweenService=game:GetService("TweenService")
local Debris=game:GetService("Debris")
local LP=Players.LocalPlayer
local getupvalues=debug.getupvalues or debug.get_upvalues
local setupvalue=debug.setupvalue or debug.setup_value
local getconstants=debug.getconstants or debug.get_constants

local WindUI=loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
if _G.XD_Cleanup then pcall(_G.XD_Cleanup) _G.XD_Cleanup=nil end

local S={} local C={}
S.unloaded=false

local function notify(t,d,dur)
    pcall(function() WindUI:Notify({Title=tostring(t),Content=tostring(d or ""),Duration=tonumber(dur) or 3}) end)
end
local function playToggle() end
local function playError() end
local function playBell() end

local function getChar() return LP.Character end
local function getHum(c) c=c or LP.Character return c and c:FindFirstChildOfClass("Humanoid") end
local function getHRP(c) c=c or LP.Character return c and c:FindFirstChild("HumanoidRootPart") end
local function safeTP(pos) local hrp=getHRP() if hrp then hrp.CFrame=CFrame.new(pos) return true end return false end

local function isGameActive(name)
    if not name then return true end
    local values=Workspace:FindFirstChild("Values")
    local cg=values and values:FindFirstChild("CurrentGame")
    if not cg then return false end
    local v=cg.Value
    if v==name then return true end
    if name=="Pentathlon" then
        if LP:GetAttribute("InPentathlon")==true then return true end
        if Workspace:FindFirstChild("PentathlonMap") then return true end
    end
    if name=="HideAndSeek" and (v=="HideAndSeek" or v=="Hide & Seek") then return true end
    if name=="GlassBridge" and (v=="GlassBridge" or v=="Glass Bridge") then return true end
    if name=="JumpRope" and (v=="JumpRope" or v=="Jump Rope") then return true end
    if name=="SkySquidGame" and (v=="SkySquidGame" or v=="Sky Squid Game") then return true end
    if name=="RedLightGreenLight" and (v=="RedLightGreenLight" or v=="Red Light Green Light" or v=="RLGL") then return true end
    if name=="LastDinner" and (v=="LastDinner" or v=="Last Dinner") then return true end
    return false
end
local function canEnable(game,label) if game and not isGameActive(game) then notify(label,"Wait for "..game.."!",1) return false end return true end

local function isHider(p)
    p=p or LP local f=false
    pcall(function()
        if p:GetAttribute("IsHider")==true or p:GetAttribute("ishider")==true or p:GetAttribute("Hider")==true then f=true end
        local r=p:GetAttribute("Role") or p:GetAttribute("Team")
        if r=="Hider" or r=="hider" then f=true end
        local c=p.Character
        if c then
            if c:GetAttribute("IsHider") or c:GetAttribute("Hider") then f=true end
            if c:FindFirstChild("IsHider") then f=true end
        end
    end)
    return f
end
local function isSeeker(p)
    p=p or LP local f=false
    pcall(function()
        if p:GetAttribute("IsHunter")==true or p:GetAttribute("IsSeeker")==true or p:GetAttribute("ishunter")==true then f=true end
        local r=p:GetAttribute("Role") or p:GetAttribute("Team")
        if r=="Hunter" or r=="Seeker" or r=="hunter" or r=="seeker" then f=true end
        local c=p.Character
        if c then if c:GetAttribute("IsHunter") or c:GetAttribute("IsSeeker") then f=true end end
    end)
    return f
end
local function isGuard(p)
    if not p then return false end local f=false
    pcall(function()
        if p:GetAttribute("IsGuard")==true or p:GetAttribute("isGuard")==true then f=true end
        local c=p.Character
        if c then if c:GetAttribute("IsGuard") or c:GetAttribute("isGuard") then f=true end end
    end)
    return f
end
local function firePrompt(pr)
    if not pr or not pr:IsA("ProximityPrompt") then return false end
    if fireproximityprompt then pcall(function() fireproximityprompt(pr) end) return true end
    if syn and syn.proximityprompt then pcall(function() syn.proximityprompt(pr) end) return true end
    local hd=pr.HoldDuration pr.HoldDuration=0
    pcall(function() pr:InputHoldBegin() task.wait() pr:InputHoldEnd() end)
    pr.HoldDuration=hd return true
end

-- LIGHTS OUT
S.LightsOutSafe={Enabled=false,SavedCFrame=nil}
function S.toggle_lights_out_safezone(arg)
    local enabled=arg and true or false
    S.LightsOutSafe.Enabled=enabled
    local getCharacter=getChar() local humanoidRootPart
    if getCharacter then humanoidRootPart=getCharacter:FindFirstChild("HumanoidRootPart") or getCharacter.PrimaryPart else humanoidRootPart=getCharacter end
    if enabled then
        if humanoidRootPart then
            S.LightsOutSafe.SavedCFrame=humanoidRootPart.CFrame
            pcall(function() humanoidRootPart.CFrame=CFrame.new(178,56,50) notify("Lights Out","Teleported to safezone",0.9) end)
        end
        playToggle() return true
    end
    if humanoidRootPart and S.LightsOutSafe.SavedCFrame then
        pcall(function() humanoidRootPart.CFrame=S.LightsOutSafe.SavedCFrame notify("Lights Out","Returned",0.9) end)
    end
    S.LightsOutSafe.SavedCFrame=nil
    playToggle() return true
end

function S.toggle_vampire_vision(arg)
    local v=arg and true or false
    S.VampireVisionEnabled=v
    local nv=Lighting:FindFirstChild("VampireNightVision")
    if v then
        if not nv then
            local cc=Instance.new("ColorCorrectionEffect")
            cc.Name="VampireNightVision" cc.Parent=Lighting nv=cc
        end
        nv.Brightness=0.16 nv.Contrast=0.06 nv.Saturation=-0.08 nv.TintColor=Color3.fromRGB(255,236,236)
    elseif nv then nv:Destroy() end
    playToggle()
end

-- HIDE AND SEEK
S.FasterSprintEnabled=false S.FasterSprintLoop=nil
function S.toggle_faster_sprint(arg)
    local v=arg and true or false S.FasterSprintEnabled=v
    if S.FasterSprintLoop then pcall(task.cancel,S.FasterSprintLoop) S.FasterSprintLoop=nil end
    if v then
        S.FasterSprintLoop=task.spawn(function()
            while S.FasterSprintEnabled do
                local ch=LP.Character
                if ch and ch.Parent then
                    if not ch:FindFirstChild("FASTERSPRINT") then
                        local f=Instance.new("Folder") f.Name="FASTERSPRINT" f.Parent=ch
                    end
                    local d=ch:FindFirstChild("DelIfGone_Folder") if d then d:Destroy() end
                    local sv=ch:FindFirstChild("StaminaVal") if sv then sv.Value=100 end
                    local x=ch:GetChildren()[36]
                    if x and not ch:FindFirstChild(x.Name) then
                        local f=Instance.new("Folder") f.Name=x.Name f.Parent=ch
                    end
                end
                task.wait()
            end
        end)
    end
    playToggle() return true
end

function S.teleport_to_spawn()
    local c=getChar() if not c then notify("Teleport","Character not found",0.9) playError() return end
    local hrp=getHRP(c) if not hrp then notify("Teleport","Root not found",0.9) playError() return end
    hrp.CFrame=CFrame.new(Vector3.new(196.83342,55.9548,-90.47459))
    playBell()
end
function S.teleport_to_hider()
    if not canEnable("HideAndSeek","HNS") then return end
    local c=getChar() if not c then return end
    local hrp=getHRP(c) if not hrp then return end
    for _,p in pairs(Players:GetPlayers()) do
        if p~=LP and isHider(p) and p.Character then
            local h=p.Character:FindFirstChildOfClass("Humanoid")
            if h and h.Health>0 then
                local hrp2=p.Character:FindFirstChild("HumanoidRootPart")
                if hrp2 then hrp.CFrame=CFrame.new(hrp2.Position.X,hrp2.Position.Y+3,hrp2.Position.Z) notify("HNS","TP to hider: "..p.Name,0.9) return end
            end
        end
    end
    notify("HideAndSeek","No hiders found",0.9)
end
function S.teleport_to_seeker()
    if not canEnable("HideAndSeek","HNS") then return end
    local c=getChar() if not c then return end
    local hrp=getHRP(c) if not hrp then return end
    for _,p in pairs(Players:GetPlayers()) do
        if p~=LP and isSeeker(p) and p.Character then
            local h=p.Character:FindFirstChildOfClass("Humanoid")
            if h and h.Health>0 then
                local hrp2=p.Character:FindFirstChild("HumanoidRootPart")
                if hrp2 then hrp.CFrame=CFrame.new(hrp2.Position.X,hrp2.Position.Y+3,hrp2.Position.Z) notify("HNS","TP to seeker: "..p.Name,0.9) return end
            end
        end
    end
    notify("HideAndSeek","No seekers found",0.9)
end
function S.teleport_random_exit()
    local c=getChar() c=c and c:FindFirstChild("HumanoidRootPart")
    if not c then notify("Teleport","No character",0.9) return end
    local tbl={}
    local function scan(obj)
        if not obj then return end
        for _,ch in pairs(obj:GetChildren()) do
            if ch.Name=="EXITDOOR" and ch:GetAttribute("ActuallyWorks")==true then
                local pp=ch.PrimaryPart or ch:FindFirstChildWhichIsA("BasePart",true)
                if pp then table.insert(tbl,pp) end
            end
            scan(ch)
        end
    end
    scan(workspace:FindFirstChild("HideAndSeekMap") or workspace)
    if #tbl==0 then notify("Teleport","No exit doors",0.9) return end
    c.CFrame=CFrame.new(tbl[math.random(1,#tbl)].Position+Vector3.new(0,4,0))
    notify("Teleport","Random exit",0.8) playToggle()
end

S.KeyESPEnabled=false S.KeyESPBoxes={} S.KeyESPConnection=nil
function S.toggle_key_esp(v)
    if v then if not canEnable("HideAndSeek","Key ESP") then return false end end
    S.KeyESPEnabled=v
    if S.KeyESPConnection then S.KeyESPConnection:Disconnect() S.KeyESPConnection=nil end
    for _,b in pairs(S.KeyESPBoxes) do if b then pcall(function() b:Destroy() end) end end
    S.KeyESPBoxes={}
    if v then
        task.spawn(function()
            local lp2=LP local W=workspace
            local effects
            repeat effects=W:FindFirstChild("Effects") task.wait(0.1) until effects
            local tbl={}
            local function getKeys()
                local ck=lp2:FindFirstChild("CurrentKeys") if ck then return ck end
                local live=W:FindFirstChild("Live")
                if live then local v3=live:FindFirstChild(lp2.Name) if v3 then local ck2=v3:FindFirstChild("CurrentKeys") if ck2 then return ck2 end end end
                return nil
            end
            local function hasK(k) local ck=getKeys() if not ck then return false end return ck:FindFirstChild(k)~=nil end
            local function mkBox(a)
                local b=Instance.new("BoxHandleAdornment")
                b.Name="KeyESP" b.Adornee=a b.Size=a.Size+Vector3.new(0.5,0.5,0.5)
                b.Color3=Color3.fromRGB(138,43,226) b.Transparency=0.4 b.AlwaysOnTop=true b.ZIndex=10 b.Parent=a return b
            end
            local function delBox(a) if tbl[a] then if tbl[a] and tbl[a].Parent then tbl[a]:Destroy() end tbl[a]=nil end end
            while S.KeyESPEnabled do
                for k in pairs(tbl) do if not k or not k.Parent then delBox(k) end end
                for _,child in ipairs(effects:GetChildren()) do
                    if S.KeyESPEnabled then
                        if child:IsA("Model") and child.Name:match("^DroppedKey") then
                            local s=child.Name:gsub("^DroppedKey","") local pp=child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart")
                            if pp then
                                if not hasK(s) then
                                    if not tbl[child] and not pp:FindFirstChild("KeyESP") then tbl[child]=mkBox(pp) end
                                else
                                    delBox(child) local k2=pp:FindFirstChild("KeyESP") if k2 then k2:Destroy() end
                                end
                            end
                        end
                        continue
                    end
                    break
                end
                task.wait(0.25)
            end
            for _,v3 in pairs(tbl) do if v3 then v3:Destroy() end end
        end)
    end
    playToggle() return true
end

S.ExitDoorESPEnabled=false S.ExitDoorESPThread=nil S.ExitDoorESPObjects={}
function S.toggle_exit_door_esp(arg)
    if arg then if not canEnable("HideAndSeek","Exit Door ESP") then S.ExitDoorESPEnabled=false return end end
    S.ExitDoorESPEnabled=arg and true or false S.ExitDoorESPObjects=S.ExitDoorESPObjects or {}
    local function clear()
        for k,o in pairs(S.ExitDoorESPObjects) do
            pcall(function() if o.box then o.box:Destroy() end end)
            pcall(function() if o.billboard then o.billboard:Destroy() end end)
            S.ExitDoorESPObjects[k]=nil
        end
        S.ExitDoorESPObjects={}
    end
    if S.ExitDoorESPThread then pcall(task.cancel,S.ExitDoorESPThread) S.ExitDoorESPThread=nil end
    pcall(clear)
    if not arg then playToggle() return end
    local function mk(arg2)
        local ok,size=pcall(function() local bb,s=arg2:GetBoundingBox() return s end)
        size=ok and size or Vector3.new(4,6,2)
        local box=Instance.new("BoxHandleAdornment")
        box.Adornee=arg2.PrimaryPart or arg2:FindFirstChildWhichIsA("BasePart")
        if not box.Adornee then return nil end
        box.Size=size box.Color3=Color3.fromRGB(255,255,0) box.Transparency=0.5
        box.AlwaysOnTop=true box.ZIndex=10 box.Parent=box.Adornee
        local bb=Instance.new("BillboardGui")
        bb.Adornee=box.Adornee bb.Size=UDim2.new(0,100,0,50) bb.StudsOffset=Vector3.new(0,3,0) bb.AlwaysOnTop=true bb.Parent=box.Adornee
        local lbl=Instance.new("TextLabel")
        lbl.Size=UDim2.new(1,0,1,0) lbl.BackgroundTransparency=1 lbl.Text="EXIT DOOR"
        lbl.TextColor3=Color3.fromRGB(255,255,0) lbl.TextScaled=true lbl.Font=Enum.Font.SourceSansBold lbl.Parent=bb
        table.insert(S.ExitDoorESPObjects,{box=box,billboard=bb,part=box.Adornee})
    end
    local map=workspace:FindFirstChild("HideAndSeekMap")
    if map then
        local function scan(arg2)
            for _,ch in pairs(arg2:GetChildren()) do
                if ch.Name=="EXITDOOR" and ch:GetAttribute("ActuallyWorks")==true then mk(ch) end
                scan(ch)
            end
        end
        scan(map)
    end
    playToggle()
end

S.SpikesESPObjects={}
function S.toggle_spikes_esp(arg)
    S.SpikesESPEnabled=arg and true or false
    for _,o in pairs(S.SpikesESPObjects or {}) do pcall(function() if type(o)=="table" then for _,x in pairs(o) do if x and x.Destroy then x:Destroy() end end elseif o and o.Destroy then o:Destroy() end end) end
    S.SpikesESPObjects={}
    if not arg then playToggle() return end
    local names={KillingParts=true,killingParts=true,Killingparts=true,killingparts=true}
    for _,d in ipairs(workspace:GetDescendants()) do
        if names[d.Name] or string.lower(tostring(d.Name))=="killingparts" then
            local parts={}
            if d:IsA("BasePart") then table.insert(parts,d) else for _,d2 in ipairs(d:GetDescendants()) do if d2:IsA("BasePart") then table.insert(parts,d2) end end end
            for _,p in ipairs(parts) do
                if not S.SpikesESPObjects[p] then
                    local hl=Instance.new("Highlight")
                    hl.Name="SpikeHL" hl.Adornee=p hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
                    hl.FillColor=Color3.fromRGB(0,0,0) hl.OutlineColor=Color3.fromRGB(40,40,40)
                    hl.FillTransparency=0.35 hl.OutlineTransparency=0 hl.Parent=p
                    S.SpikesESPObjects[p]=hl
                end
            end
        end
    end
    playToggle()
end

S.AntiSpikesEnabled=false S.AntiSpikesPlatforms={} S.AntiSpikesConn=nil
function S.toggle_anti_spikes(arg)
    S.AntiSpikesEnabled=arg and true or false
    for _,p in ipairs(S.AntiSpikesPlatforms) do pcall(function() if p then p:Destroy() end end) end
    S.AntiSpikesPlatforms={}
    if S.AntiSpikesConn then pcall(function() S.AntiSpikesConn:Disconnect() end) S.AntiSpikesConn=nil end
    if not arg then playToggle() return true end
    local m=Workspace:FindFirstChild("HideAndSeekMap") local kp=m and m:FindFirstChild("KillingParts")
    if not kp then notify("Anti-Spikes","KillingParts not found",0.9) playError() S.AntiSpikesEnabled=false return false end
    local n=0
    local function make(p)
        if not p:IsA("BasePart") then return end
        local part=Instance.new("Part")
        part.Name="AntiSpike" part.Anchored=true part.CanCollide=true part.Transparency=0.5
        part.Material=Enum.Material.SmoothPlastic part.Color=Color3.fromRGB(60,60,60)
        part.Size=Vector3.new(math.max(p.Size.X,4),1,math.max(p.Size.Z,4))
        part.CFrame=CFrame.new(p.Position+Vector3.new(0,20,0)) part.Parent=workspace
        table.insert(S.AntiSpikesPlatforms,part) n+=1
    end
    for _,d in ipairs(kp:GetDescendants()) do if d:IsA("BasePart") then make(d) end end
    for _,c in ipairs(kp:GetChildren()) do if c:IsA("BasePart") then make(c) end end
    notify("Anti-Spikes","Enabled ("..n..")",0.9) playToggle() return true
end

-- ==================================================================
-- AUTO DODGE (Xionix HnS - animation-based, всегда StrictOnly)
-- ==================================================================
S._adWatchers={}
S.AutoDodge={
    Enabled=false, Distance=18, Delay=0, MinInterval=0.02,
    AnimWatch=0.4, WatchAfter=0.3,
    StrictOnly=true,
    Hooks={}, Added={},
    cachedDodgeTool=nil, cachedDodgeSlot="1", lastDodgeH=0, ManualSlot="",
}

local HIT_LIST={
    "76323709902827","132207921464999","72649558888714","84036894358514","103062305177426",
    "79649041083405","73242877658272","121147456137931","105341857343164","116839849594540",
    "96924216250322","85793691404836","86197206792061","104041807075625","114928327045353",
    "135690448001690","103355259844069","128452090955120","71000246338579","125906547773381",
    "107989020363293","85623602463927","87978085217719","112950478995075","94443309383954",
    "81766558426599","90654171377736","72128148665361","94960826047243","114769224376981",
    "92844369847738","106908462496291","109822392402606","119784367902126","89439896387299",
    "132070051408308","131235569946744","123834203617100","98785078701251","103318207627541",
    "99844967459345","101703309225906","97863204720378","137824029524579","87041753984253",
    "81533666958052","79549040943367","81392013026663","77595339119545","75611037033634",
    "123370871049938","106756593687295","128733894961951","137659772694747","93105538774923",
    "129324788590686","134675465964672","85285032162865","125283605050829","93373403484012",
    "108262048142532","106370995610424","114617637295467","115386570583557","70775136168849",
    "72557176302052","94215646393565","73150160715773","7052329948932","9915750592076",
    "85743982894847","82579449181823","114687917628569","9915750926076","99157505926076"
}
local BAN_LIST={
    "84075526494569","112693580156198","116089915329773","123441836092792","76593886937703",
    "71214385249268","91345240826151","107476375951001","97049872073368","73421886855742",
    "140302976506103","108126144370302","115836393562566","102891247801142","73748962069265",
    "88654124229687","12214474272195"
}
local HIT_DELAY={
    ["131235569946744"]=0.9,["114687917628569"]=3.4,["115386570583557"]=0.6,
    ["70775136168849"]=0.7,["132207921464999"]=0.4
}
local HIT,BAN={},{}
local S_animEnabled={}
for i=1,#HIT_LIST do HIT[HIT_LIST[i]]=true S_animEnabled[HIT_LIST[i]]=true end
for i=1,#BAN_LIST do BAN[BAN_LIST[i]]=true S_animEnabled[BAN_LIST[i]]=false end

local function isHit(id)
    if not id then return false end
    local n=tostring(id):match("%d+")
    if not n then return false end
    if BAN[n] then return false end
    if HIT[n] then return S_animEnabled[n]~=false end
    for k in pairs(HIT) do
        if S_animEnabled[k]~=false and not BAN[k] and (n:find(k,1,true) or k:find(n,1,true)) then return true end
    end
    return false
end

local SPECIAL_FORCE={
    ["power hold"]=true,["powerhold"]=true,["power_hold"]=true,
    ["pocket sand"]=true,["pocketsand"]=true,["pocket_sand"]=true,["sand"]=true
}
local function isSpecialForce(char)
    if not char then return false end
    for _,c in ipairs(char:GetChildren()) do
        if c:IsA("Tool") then
            local n=string.lower(c.Name)
            for k in pairs(SPECIAL_FORCE) do if n:find(k,1,true) then return true end end
        end
    end
    return false
end
local function hasSandFx(char)
    if not char then return false end
    for _,d in ipairs(char:GetDescendants()) do
        if d:IsA("ParticleEmitter") or d:IsA("Smoke") then
            local n=string.lower(d.Name)
            if n:find("sand",1,true) or n:find("dust",1,true) or n:find("dirt",1,true) then
                if d.Enabled then return true end
            end
        end
    end
    return false
end

local KEYMAP={["1"]=0x31,["2"]=0x32,["3"]=0x33,["4"]=0x34,["5"]=0x35,["6"]=0x36,["7"]=0x37,["8"]=0x38,["9"]=0x39,["0"]=0x30,e=0x45,t=0x54,y=0x59,r=0x52,f=0x46,q=0x51,g=0x47,space=0x20}
local VALID={["1"]=1,["2"]=1,["3"]=1,["4"]=1,["5"]=1,["6"]=1,["7"]=1,["8"]=1,["9"]=1,["0"]=1,E=1,T=1,Y=1,Q=1,F=1,R=1,G=1}
local hasNativePress=(type(keypress)=="function" and type(keyrelease)=="function")

local function press(k)
    if S.unloaded then return end
    k=string.lower(tostring(k or "t"))
    local code=KEYMAP[k] if not code then return end
    local kc=Enum.KeyCode[string.upper(k)] or Enum.KeyCode.T
    if hasNativePress then
        local ok=pcall(function()
            keypress(code)
            task.delay(math.random(40,90)/1000,function() pcall(function() keyrelease(code) end) end)
        end)
        if ok then return end
    end
    pcall(function()
        local vim=game:GetService("VirtualInputManager")
        vim:SendKeyEvent(true,kc,false,game)
        task.delay(math.random(40,90)/1000,function() pcall(function() vim:SendKeyEvent(false,kc,false,game) end) end)
    end)
end

local function mouseClick()
    if S.unloaded then return end
    local cam=workspace.CurrentCamera
    local vp=(cam and cam.ViewportSize) or Vector2.new(800,600)
    local cx=math.floor(vp.X/2) local cy=math.floor(vp.Y/2)
    local done=false
    pcall(function() if mouse1click then mouse1click() done=true end end)
    if done then return end
    pcall(function() if mouse1press and mouse1release then mouse1press() task.wait(0.03) mouse1release() done=true end end)
    if done then return end
    pcall(function()
        local vim=game:GetService("VirtualInputManager")
        vim:SendMouseButtonEvent(cx,cy,0,true,game,1) task.wait(0.03)
        vim:SendMouseButtonEvent(cx,cy,0,false,game,1)
    end)
end

local function isDodgeTool(tool)
    if not tool or not tool:IsA("Tool") then return false end
    local n=string.lower(tool.Name)
    if n:find("ultra",1,true) or n:find("instinct",1,true) then return false end
    return n:find("dodge",1,true)~=nil
end
local function findDodgeTool()
    local function scan(c)
        if not c then return nil end
        for _,cc in ipairs(c:GetChildren()) do if isDodgeTool(cc) then return cc end end
        return nil
    end
    return scan(LP.Character) or scan(LP:FindFirstChild("Backpack"))
end
local function inferSlotFor(toolObj,fallback,manual)
    if manual and manual~="" then
        local up=string.upper(tostring(manual)) if VALID[up] then return up end
    end
    return fallback
end
local function inRange(my,hrp,distMax,extra)
    if not my or not hrp then return false end
    if hrp.Parent==LP.Character then return false end
    local dx=my.Position.X-hrp.Position.X local dz=my.Position.Z-hrp.Position.Z local dy=my.Position.Y-hrp.Position.Y
    if math.abs(dy)>7 then return false end
    local d2h=dx*dx+dz*dz local lim=(distMax or 18)+(extra or 0)
    if d2h>lim*lim then return false end
    return true,math.sqrt(d2h)
end

local function fireH()
    if S.unloaded or not S.AutoDodge.Enabled then return end
    local now=tick()
    if now-S.AutoDodge.lastDodgeH<(S.AutoDodge.MinInterval or 0.02) then return end
    S.AutoDodge.lastDodgeH=now
    local tool=S.AutoDodge.cachedDodgeTool or findDodgeTool()
    local slot=S.AutoDodge.cachedDodgeSlot or "1"
    local pre=S.AutoDodge.Delay or 0
    local function doFire()
        if S.unloaded or not S.AutoDodge.Enabled then return end
        local char=LP.Character local hum=char and char:FindFirstChildOfClass("Humanoid")
        if tool and hum then
            press(slot) task.wait(0.06)
            if tool.Parent~=char then pcall(function() hum:EquipTool(tool) end) task.wait(0.06) end
            pcall(function() tool:Activate() end)
            task.wait(0.02) mouseClick() task.wait(0.04) mouseClick()
        else
            press(slot) task.wait(0.05) mouseClick()
        end
    end
    if pre>0 then task.delay(pre,doFire) else doFire() end
end

local function considerAttack(tr,hrp,force)
    if S.unloaded or not S.AutoDodge.Enabled then return end
    if not hrp or not hrp.Parent then return end
    local w=S._adWatchers[hrp] if not w then w={c=0} S._adWatchers[hrp]=w end
    if w.c>=3 then return end
    w.c=w.c+1
    local extra=force and 8 or 0
    local firedH=false
    local allowH=false
    if S.AutoDodge.StrictOnly then
        if force then allowH=true
        elseif tr and tr.Animation and isHit(tr.Animation.AnimationId) then allowH=true end
    else allowH=true end
    local animDelay=0
    if tr and tr.Animation and not force then
        local aid=tostring(tr.Animation.AnimationId):match("%d+")
        if aid and HIT_DELAY[aid] then animDelay=HIT_DELAY[aid] end
    end
    local animLen=0
    if tr then local ok,l=pcall(function() return tr.Length end) if ok and tonumber(l) and l>0 then animLen=l end end
    if not allowH then w.c=w.c-1 if w.c<=0 then S._adWatchers[hrp]=nil end return end
    local t0=tick()
    local baseH=math.max(S.AutoDodge.AnimWatch or 0.4,animLen+(S.AutoDodge.WatchAfter or 0.3))
    local maxWatch=baseH+animDelay
    local conn
    local function finish()
        if conn then pcall(function() conn:Disconnect() end) conn=nil end
        w.c=w.c-1 if w.c<=0 then S._adWatchers[hrp]=nil end
    end
    local function check()
        if S.unloaded or firedH then finish() return end
        if tick()-t0>maxWatch then finish() return end
        local my=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not my or not hrp or not hrp.Parent then finish() return end
        local el=tick()-t0
        local distH=S.AutoDodge.Distance or 18
        local v=hrp.AssemblyLinearVelocity
        local spd=math.sqrt(v.X*v.X+v.Z*v.Z)
        if spd>15 then
            local dx=my.Position.X-hrp.Position.X local dz=my.Position.Z-hrp.Position.Z
            local dist=math.sqrt(dx*dx+dz*dz)
            if dist>0.5 then
                local dot=(v.X*dx+v.Z*dz)/(dist*spd)
                if dot>0.5 then local reach=spd*0.2 distH=distH+reach end
            end
        end
        if allowH and not firedH and el>=animDelay then
            if inRange(my,hrp,distH,extra) then firedH=true fireH() end
        end
        if firedH then finish() end
    end
    conn=RunService.Heartbeat:Connect(check)
end

local function hookTool(tool,hrp)
    if not tool or S.AutoDodge.Hooks[tool] then return end
    S.AutoDodge.Hooks[tool]=tool.Activated:Connect(function()
        if S.unloaded or not S.AutoDodge.Enabled then return end
        if isSpecialForce(hrp.Parent) then considerAttack(nil,hrp,true) end
    end)
end
local function hookAnim(an,hrp)
    if S.AutoDodge.Hooks[an] or S.unloaded then return end
    S.AutoDodge.Hooks[an]=an.AnimationPlayed:Connect(function(tr)
        if S.unloaded or not S.AutoDodge.Enabled then return end
        if not tr or not tr.Animation then return end
        if hrp.Parent==LP.Character then return end
        local aid=tostring(tr.Animation.AnimationId):match("%d+")
        if aid and BAN[aid] then return end
        if isHit(tr.Animation.AnimationId) then considerAttack(tr,hrp,false) return end
        local char=hrp.Parent
        if isSpecialForce(char) and hasSandFx(char) then considerAttack(tr,hrp,true) end
    end)
end
local function hookChar(char)
    if S.unloaded or not char or char==LP.Character then return end
    local hum=char:FindFirstChildOfClass("Humanoid") local hrp=char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end
    local an=hum:FindFirstChildOfClass("Animator")
    if an then hookAnim(an,hrp)
    else
        local c
        c=hum.ChildAdded:Connect(function(ch)
            if ch:IsA("Animator") then hookAnim(ch,hrp) pcall(function() c:Disconnect() end) end
        end)
        table.insert(S.AutoDodge.Hooks,c)
    end
    for _,t in ipairs(char:GetChildren()) do if t:IsA("Tool") then hookTool(t,hrp) end end
    local ac
    ac=char.ChildAdded:Connect(function(ch) if ch:IsA("Tool") then hookTool(ch,hrp) end end)
    table.insert(S.AutoDodge.Hooks,ac)
end
local function startHooks()
    if S.unloaded then return end
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=LP then
            if plr.Character then hookChar(plr.Character) end
            if not S.AutoDodge.Added[plr] then
                S.AutoDodge.Added[plr]=plr.CharacterAdded:Connect(function(ch) if S.AutoDodge.Enabled and not S.unloaded then task.wait(0.15) hookChar(ch) end end)
            end
        end
    end
    if not S.AutoDodge.Added._j then
        S.AutoDodge.Added._j=Players.PlayerAdded:Connect(function(plr)
            if S.unloaded then return end
            S.AutoDodge.Added[plr]=plr.CharacterAdded:Connect(function(ch) if S.AutoDodge.Enabled and not S.unloaded then task.wait(0.15) hookChar(ch) end end)
        end)
    end
    if not S.AutoDodge.Added._r then
        S.AutoDodge.Added._r=Players.PlayerRemoving:Connect(function(plr)
            if S.AutoDodge.Added[plr] then pcall(function() S.AutoDodge.Added[plr]:Disconnect() end) S.AutoDodge.Added[plr]=nil end
        end)
    end
end
local function unhookAD()
    for _,c in pairs(S.AutoDodge.Hooks) do pcall(function() c:Disconnect() end) end
    table.clear(S.AutoDodge.Hooks)
end
function S.toggle_auto_dodge(arg)
    S.AutoDodge.Enabled=arg and true or false
    if arg then
        S.AutoDodge.cachedDodgeTool=findDodgeTool()
        S.AutoDodge.cachedDodgeSlot=inferSlotFor(S.AutoDodge.cachedDodgeTool,"1",S.AutoDodge.ManualSlot)
        startHooks()
    else unhookAD() end
    playToggle() return true
end
task.spawn(function()
    while not S.unloaded do
        if S.AutoDodge.Enabled then
            S.AutoDodge.cachedDodgeTool=findDodgeTool()
            S.AutoDodge.cachedDodgeSlot=inferSlotFor(S.AutoDodge.cachedDodgeTool,"1",S.AutoDodge.ManualSlot)
        end
        task.wait(0.5)
    end
end)

-- SPIKES KILL
S.SpikesKillFeature={
    Enabled=false,
    AnimationIds={
        "rbxassetid://105341857343164","rbxassetid://95623680038308","rbxassetid://106191977814264",
        "rbxassetid://79549040943367","rbxassetid://138639404847153","rbxassetid://81533666958052",
        "rbxassetid://118039465583394",
    },
    SpikesPosition=nil,PlatformHeightOffset=20,ReturnDelay=0.6,
    OriginalCFrame=nil,ActiveAnimation=false,AnimationStartTime=0,
    AnimationConnection=nil,CharacterAddedConnection=nil,
    AnimationStoppedConnections={},AnimationCheckConnection=nil,
    TrackedAnimations={},SafetyCheckConnection=nil,PlatformPart=nil,PlatformCreated=false,
}
function S.toggle_spikes_kill(arg)
    if arg and not isGameActive("HideAndSeek") then notify("Spikes Kill","Wait for HideAndSeek!",0.9) playError() S.SpikesKillFeature.Enabled=false return end
    local F=S.SpikesKillFeature
    if F.AnimationConnection then F.AnimationConnection:Disconnect() F.AnimationConnection=nil end
    if F.CharacterAddedConnection then F.CharacterAddedConnection:Disconnect() F.CharacterAddedConnection=nil end
    if F.SafetyCheckConnection then F.SafetyCheckConnection:Disconnect() F.SafetyCheckConnection=nil end
    if F.AnimationCheckConnection then F.AnimationCheckConnection:Disconnect() F.AnimationCheckConnection=nil end
    for _,c in ipairs(F.AnimationStoppedConnections) do pcall(function() c:Disconnect() end) end
    F.AnimationStoppedConnections={}
    if F.PlatformPart then pcall(function() F.PlatformPart:Destroy() end) F.PlatformPart=nil end
    F.PlatformCreated=false F.OriginalCFrame=nil F.ActiveAnimation=false F.AnimationStartTime=0
    F.TrackedAnimations={} F.SpikesPosition=nil
    if not arg then F.Enabled=false playToggle() return end
    pcall(function()
        local m=workspace:FindFirstChild("HideAndSeekMap") m=m and m:FindFirstChild("KillingParts")
        if m then for _,c in pairs(m:GetChildren()) do if c:IsA("BasePart") then if not F.SpikesPosition then F.SpikesPosition=c.Position end end end end
    end)
    local function fn4()
        if F.PlatformCreated or not F.SpikesPosition then return end
        pcall(function()
            local p=Instance.new("Part")
            p.Name="SafetyPlatform" p.Size=Vector3.new(20,5,20)
            p.Position=F.SpikesPosition+Vector3.new(0,F.PlatformHeightOffset,0)
            p.Anchored=true p.CanCollide=true p.Transparency=1
            local bv=Instance.new("BoolValue") bv.Name="SafePlatform" bv.Value=true bv.Parent=p
            p.Parent=workspace F.PlatformPart=p F.PlatformCreated=true
        end)
    end
    local function fn5(c)
        if not c or not c:FindFirstChild("HumanoidRootPart") then return end
        if not F.PlatformCreated then fn4() end
        if F.SpikesPosition and F.PlatformPart then
            F.OriginalCFrame=c:GetPrimaryPartCFrame()
            c:SetPrimaryPartCFrame(CFrame.new(F.PlatformPart.Position+Vector3.new(0,2.5,0)))
        end
    end
    local function fn6(c)
        if not c or not c:FindFirstChild("HumanoidRootPart") then return end
        if F.OriginalCFrame then c:SetPrimaryPartCFrame(F.OriginalCFrame) F.OriginalCFrame=nil end
    end
    local function fn7(id) for _,a in ipairs(F.AnimationIds) do if a==id then return true end end return false end
    local function fn8(c)
        F.AnimationConnection=c:WaitForChild("Humanoid").AnimationPlayed:Connect(function(tr)
            if not F.Enabled then return end
            if tr.Animation and fn7(tr.Animation.AnimationId) then
                F.TrackedAnimations[tr]=true
                if not F.ActiveAnimation then
                    F.ActiveAnimation=true F.AnimationStartTime=tick()
                    fn5(c)
                    local conn=tr.Stopped:Connect(function()
                        task.wait(F.ReturnDelay)
                        if F.OriginalCFrame then fn6(c) F.ActiveAnimation=false F.TrackedAnimations={} end
                    end)
                    table.insert(F.AnimationStoppedConnections,conn)
                end
            end
        end)
    end
    local char=LP.Character if char then fn8(char) end
    F.CharacterAddedConnection=LP.CharacterAdded:Connect(function(c) task.wait(1) fn8(c) end)
    F.SafetyCheckConnection=RunService.Heartbeat:Connect(function()
        if not F.Enabled then
            if F.SafetyCheckConnection then F.SafetyCheckConnection:Disconnect() F.SafetyCheckConnection=nil end
            return
        end
        if not isGameActive("HideAndSeek") then F.Enabled=false playError() return end
        if F.PlatformCreated and (not F.PlatformPart or not F.PlatformPart.Parent) then F.PlatformCreated=false F.PlatformPart=nil fn4() end
        local active=F.ActiveAnimation if active then active=tick()-F.AnimationStartTime>=10 end
        if active then
            local v=getChar()
            if v and F.OriginalCFrame then fn6(v) end
            F.ActiveAnimation=false F.TrackedAnimations={}
        end
    end)
    F.Enabled=true playToggle() fn4()
end

S.SpikesPlatformTeleport={Enabled=false,Connection=nil,Platform=nil,OriginalCFrame=nil,SpikesPosition=nil}
function S.toggle_spikes_platform_teleport(arg)
    if not (arg and true or false) then playToggle() return true end
    pcall(function() if not S.AntiSpikesEnabled then S.toggle_anti_spikes(true) end end)
    task.wait(0.35)
    local v3=nil
    if S.AntiSpikesPlatforms then
        for _,p in pairs(S.AntiSpikesPlatforms) do
            if p and p.Parent and p:IsA("BasePart") then v3=p break else v3=nil end
        end
    end
    if not v3 then
        for _,d in ipairs(workspace:GetDescendants()) do
            if d:IsA("BasePart") and (d.Name=="AntiSpikePlatform" or d.Name:find("AntiSpike")) then v3=d break end
        end
    end
    local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if v3 and hrp then hrp.CFrame=CFrame.new(v3.Position+Vector3.new(0,4,0)) notify("Teleport","To spikes",0.9)
    else notify("Teleport","No platform",0.9) end
    playToggle() return true
end

-- JUMP ROPE
S.JumpRopeAntiFall={Enabled=false,Platform=nil,Conn=nil}
function S.toggle_jump_rope_anti_fall(enabled)
    if enabled then if not canEnable("JumpRope","JumpRope") then notify("JumpRope","Wait for JumpRope!",0.9) playError() return end end
    if S.JumpRopeAntiFall.Conn then S.JumpRopeAntiFall.Conn:Disconnect() end
    if S.JumpRopeAntiFall.Platform then S.JumpRopeAntiFall.Platform:Destroy() end
    S.JumpRopeAntiFall.Enabled=enabled
    if enabled then
        local function mk()
            local c=getChar() if not c then return nil end
            local hrp=getHRP(c) if not hrp then return nil end
            local p=Instance.new("Part")
            p.Name=HttpService:GenerateGUID(false) p.Size=Vector3.new(10000,1,10000)
            p.Position=Vector3.new(hrp.Position.X,hrp.Position.Y-5,hrp.Position.Z)
            p.Anchored=true p.CanCollide=true p.Transparency=0.5 p.Parent=workspace return p
        end
        S.JumpRopeAntiFall.Platform=mk()
        S.JumpRopeAntiFall.Conn=RunService.Heartbeat:Connect(function()
            if not S.JumpRopeAntiFall.Enabled then return end
            if not isGameActive("JumpRope") then S.JumpRopeAntiFall.Enabled=false return end
            if not (S.JumpRopeAntiFall.Platform and S.JumpRopeAntiFall.Platform.Parent) then S.JumpRopeAntiFall.Platform=mk() end
        end)
    end
    playToggle() return true
end

S.disable_rope_objects=function(a)
    if not a then return end
    pcall(function()
        if a:IsA("MeshPart") or a:IsA("Part") or a:IsA("BasePart") then
            a.CanCollide=false a.CanTouch=false a.CanQuery=false a.Massless=true
            if a.TouchTransmitter then a.TouchTransmitter:Destroy() end
        end
        if a:IsA("Script") or a:IsA("LocalScript") or a:IsA("ModuleScript") then
            local s=a.Name:lower()
            if s:find("rope") or s:find("jump") or s:find("carry") or s:find("damage") or s:find("hurt") then a.Disabled=true end
        end
        if a:IsA("RopeConstraint") then a:Destroy() end
        local n=a.Name or ""
        if n=="PlayingJumpRope" or n=="RopeCarryPrompt" then a:Destroy() end
    end)
end
S.search_and_destroy_rope=function(a)
    if not a then return end
    for _,d in pairs(a:GetDescendants()) do
        if d.Name and d.Name:lower():find("rope") then S.disable_rope_objects(d) end
        if d:IsA("RopeConstraint") then S.disable_rope_objects(d) end
        if d.Name=="PlayingJumpRope" or d.Name=="RopeCarryPrompt" then S.disable_rope_objects(d) end
    end
end
S.destroy_all_ropes=function()
    S.search_and_destroy_rope(workspace)
    pcall(function() S.search_and_destroy_rope(ReplicatedStorage) end)
    pcall(function()
        for _,p in pairs(Players:GetPlayers()) do
            if p.Character then S.search_and_destroy_rope(p.Character) end
            if p.PlayerGui then S.search_and_destroy_rope(p.PlayerGui) end
        end
    end)
end
S.disable_damage_scripts=function()
    pcall(function()
        for _,d in pairs(ReplicatedStorage:GetDescendants()) do
            if d:IsA("Script") or d:IsA("LocalScript") or d:IsA("ModuleScript") then
                local s=d.Name:lower()
                if s:find("rope") or s:find("jump") or s:find("carry") or s:find("damage") or s:find("hurt") then d.Disabled=true end
            end
        end
    end)
end

S.JumpRopeAntiHit={Enabled=false,Connection=nil,RopeDestroyed=false}
function S.toggle_jump_rope_anti_hit(enabled)
    if enabled then if not canEnable("JumpRope","JumpRope") then return false end end
    if S.JumpRopeAntiHit.Connection then S.JumpRopeAntiHit.Connection:Disconnect() S.JumpRopeAntiHit.Connection=nil end
    S.JumpRopeAntiHit.Enabled=enabled S.JumpRopeAntiHit.RopeDestroyed=false
    if enabled then
        S.disable_damage_scripts()
        S.destroy_all_ropes()
        S.JumpRopeAntiHit.Connection=RunService.Heartbeat:Connect(function()
            if not S.JumpRopeAntiHit.Enabled then return end
            if not isGameActive("JumpRope") then S.toggle_jump_rope_anti_hit(false) return end
            if not S.JumpRopeAntiHit.RopeDestroyed then S.destroy_all_ropes() end
        end)
    end
    playToggle() return true
end

S.JumpRopeFakeBalance={Enabled=false,Connection=nil,AnimationId="rbxassetid://105677261748140",AnimationDuration=0.4,CurrentAnimation=nil,StopTimer=nil,WasJumping=false}
function S.play_land_animation_fake_balance()
    if not S.JumpRopeFakeBalance.Enabled then return end
    local c=getChar() if not c then return end
    local h=getHum(c) if not h then return end
    if S.JumpRopeFakeBalance.CurrentAnimation then pcall(function() S.JumpRopeFakeBalance.CurrentAnimation:Stop() end) end
    if S.JumpRopeFakeBalance.StopTimer then S.JumpRopeFakeBalance.StopTimer:Disconnect() S.JumpRopeFakeBalance.StopTimer=nil end
    local a=Instance.new("Animation") a.AnimationId=S.JumpRopeFakeBalance.AnimationId
    S.JumpRopeFakeBalance.CurrentAnimation=h:LoadAnimation(a)
    pcall(function() S.JumpRopeFakeBalance.CurrentAnimation:Play() end)
    S.JumpRopeFakeBalance.StopTimer=RunService.Stepped:Connect(function()
        task.wait(S.JumpRopeFakeBalance.AnimationDuration)
        if S.JumpRopeFakeBalance.CurrentAnimation then pcall(function() S.JumpRopeFakeBalance.CurrentAnimation:Stop() end) S.JumpRopeFakeBalance.CurrentAnimation=nil end
        if S.JumpRopeFakeBalance.StopTimer then S.JumpRopeFakeBalance.StopTimer:Disconnect() S.JumpRopeFakeBalance.StopTimer=nil end
    end)
end
function S.setup_jump_rope_fake_balance()
    local c=getChar() if not c then return end
    local h=getHum(c) if not h then return end
    S.JumpRopeFakeBalance.WasJumping=false
    h.StateChanged:Connect(function(o,n)
        if not S.JumpRopeFakeBalance.Enabled then return end
        if n==Enum.HumanoidStateType.Jumping then S.JumpRopeFakeBalance.WasJumping=true end
        if S.JumpRopeFakeBalance.WasJumping and (n==Enum.HumanoidStateType.Running or n==Enum.HumanoidStateType.Landed or n==Enum.HumanoidStateType.GettingUp) then
            S.play_land_animation_fake_balance() S.JumpRopeFakeBalance.WasJumping=false
        end
    end)
end
function S.toggle_jump_rope_fake_balance(enabled)
    if enabled then if not canEnable("JumpRope","JumpRope") then return false end end
    if S.JumpRopeFakeBalance.Connection then S.JumpRopeFakeBalance.Connection:Disconnect() S.JumpRopeFakeBalance.Connection=nil end
    if S.JumpRopeFakeBalance.CurrentAnimation then pcall(function() S.JumpRopeFakeBalance.CurrentAnimation:Stop() end) S.JumpRopeFakeBalance.CurrentAnimation=nil end
    if S.JumpRopeFakeBalance.StopTimer then S.JumpRopeFakeBalance.StopTimer:Disconnect() S.JumpRopeFakeBalance.StopTimer=nil end
    S.JumpRopeFakeBalance.Enabled=enabled
    if enabled then
        S.setup_jump_rope_fake_balance()
        S.JumpRopeFakeBalance.Connection=RunService.Heartbeat:Connect(function()
            if not S.JumpRopeFakeBalance.Enabled then return end
            if not isGameActive("JumpRope") then S.toggle_jump_rope_fake_balance(false) return end
        end)
    end
    playToggle() return true
end

S.FreezeRopeEnabled=false
function S.toggle_freeze_rope(v)
    S.FreezeRopeEnabled=v
    local rope=workspace:FindFirstChild("Effects") and workspace.Effects:FindFirstChild("rope")
    if not rope then return end
    if v then
        for _,d in ipairs(rope:GetDescendants()) do
            if d:IsA("BasePart") then d.Anchored=true d.Velocity=Vector3.zero d.RotVelocity=Vector3.zero
            elseif d:IsA("Constraint") or d:IsA("RopeConstraint") or d:IsA("Motor6D") then d.Enabled=false end
        end
    else
        for _,d in ipairs(rope:GetDescendants()) do
            if d:IsA("BasePart") then d.Anchored=false
            elseif d:IsA("Constraint") or d:IsA("RopeConstraint") or d:IsA("Motor6D") then d.Enabled=true end
        end
    end
    playToggle()
end
function S.remove_balance_mini_game()
    local pj=LP:FindFirstChild("PlayingJumpRope")
    if pj then pcall(function() pj:Destroy() end) playToggle()
    else notify("Jump Rope","PlayingJumpRope not found",0.9) playError() end
end
function S.jr_delete_rope()
    if not canEnable("JumpRope","JumpRope") then return end
    for _,d in pairs(workspace:GetDescendants()) do
        if d.Name=="Rope" and (d:IsA("Model") or d:IsA("Part")) then d:Destroy() notify("JumpRope","Rope deleted",0.9) playToggle() return end
    end
    notify("JumpRope","Rope not found",0.9) playError()
end
function S.jr_tp_start()
    if not canEnable("JumpRope","JumpRope") then return end
    safeTP(Vector3.new(615.2844,192.27428,920.9525)) notify("JumpRope","TP Start",0.9) playToggle()
end
function S.jr_tp_end()
    if not canEnable("JumpRope","JumpRope") then return end
    safeTP(Vector3.new(720.89606,198.62831,921.17065)) notify("JumpRope","TP End",0.9) playToggle()
end

-- TUG OF WAR
S.TugOfWarAutoQTEMiss=false S.TugOfWarAutoQTEMissConnection=nil
local function findCircleBase()
    local pg=LP:FindFirstChild("PlayerGui")
    if not pg then return nil end
    local tbl2={} tbl2[1]=pg:FindFirstChild("TugOfWarUIV2") tbl2[2]=pg:FindFirstChild("TugOfWarUI")
    do local v=table.pack(pg.FindFirstChild(pg,"TugofWarRemake")) table.move(v,1,v.n,3,tbl2) end
    for _,v3 in ipairs(tbl2) do
        if v3 then
            local cb=(v3:FindFirstChild("TugofWarRemake") or v3):FindFirstChild("CircleBase")
            if cb then return cb end
            local cb2=v3:FindFirstChild("CircleBase",true)
            if cb2 then return cb2 end
        end
    end
    for _,d in ipairs(pg:GetDescendants()) do
        if d.Name=="CircleBase" and d:FindFirstChild("Arrow") and d:FindFirstChild("Medium") then return d end
    end
    return nil
end
function S.toggle_tug_of_war_auto_qte_miss(v)
    S.TugOfWarAutoQTEMiss=v
    if S.TugOfWarAutoQTEMissConnection then S.TugOfWarAutoQTEMissConnection:Disconnect() S.TugOfWarAutoQTEMissConnection=nil end
    if v then
        S.TugOfWarAutoQTEMissConnection=RunService.RenderStepped:Connect(function()
            if not S.TugOfWarAutoQTEMiss then return end
            if LP:GetAttribute("TugOfWarPhase")~="QTE" then return end
            local v3=findCircleBase() if not v3 then return end
            local arrow=v3:FindFirstChild("Arrow") local medium=v3:FindFirstChild("Medium")
            if not arrow or not medium then return end
            medium.Rotation=arrow.Rotation
        end)
    end
    playToggle()
end
S.AutoPullV2=S.AutoPullV2 or {Enabled=false,Remote=nil,CapturedArgs=nil,Conn=nil,LastFire=0,_hooked=false,_orig=nil}
function S.toggle_tug_auto_pull_op(arg)
    local enabled=arg and true or false
    S.AutoPullV2=S.AutoPullV2 or {}
    S.AutoPullV2.Enabled=enabled
    if S.AutoPullV2.Conn then pcall(function() S.AutoPullV2.Conn:Disconnect() end) S.AutoPullV2.Conn=nil end
    if S.AutoPullV2._pressTask then pcall(task.cancel,S.AutoPullV2._pressTask) S.AutoPullV2._pressTask=nil end
    if not enabled then S.AutoPullV2._didPress=false S.AutoPullV2.CapturedArgs=nil playToggle() return true end
    S.AutoPullV2._didPress=false S.AutoPullV2.CapturedArgs=nil
    local function fn11()
        local pg=LP:FindFirstChild("PlayerGui")
        if not pg then return nil end
        for _,d in ipairs(pg:GetDescendants()) do
            if d.Name=="CircleBase" and d:FindFirstChild("Arrow") and d:FindFirstChild("Medium") then return d end
        end
        return nil
    end
    local function fn12(a)
        pcall(function()
            local ar=a:FindFirstChild("Arrow") local me=a:FindFirstChild("Medium")
            if ar and me then me.Rotation=ar.Rotation end
        end)
    end
    local function fn13(a)
        pcall(function()
            local btn=a if a then btn=a:FindFirstChild("TextButton") or a:FindFirstChildWhichIsA("TextButton",true) end
            if btn and firesignal then firesignal(btn.MouseButton1Click) end
        end)
        pcall(function()
            local r=ReplicatedStorage:FindFirstChild("Remotes") r=r and r:FindFirstChild("TemporaryReachedBindable")
            if r then r:FireServer({GameQTE=true}) r:FireServer({IHateYou=true}) end
        end)
    end
    S.AutoPullV2._pressTask=task.spawn(function()
        local n=0
        while true do
            if S.AutoPullV2.Enabled and n<20 then
                local v2=fn11()
                if v2 then fn12(v2) fn13(v2) n+=1 end
                if S.AutoPullV2.CapturedArgs and #S.AutoPullV2.CapturedArgs>0 then S.AutoPullV2._didPress=true break
                else task.wait(0.12) continue end
            end
            break
        end
        S.AutoPullV2._didPress=true
    end)
    S.AutoPullV2.Conn=RunService.Heartbeat:Connect(function()
        if not S.AutoPullV2.Enabled or not S.AutoPullV2._didPress then return end
        local now=tick()
        if now-(S.AutoPullV2.LastFire or 0)<0.04 then return end
        S.AutoPullV2.LastFire=now
        pcall(function()
            local r=ReplicatedStorage:FindFirstChild("Remotes") local trb=r and r:FindFirstChild("TemporaryReachedBindable")
            if trb then trb:FireServer({GameQTE=true}) trb:FireServer({IHateYou=true}) end
        end)
    end)
    playToggle() return true
end

-- PENTATHLON
S.PentathlonThreads={} S.PentathlonConns={}
local function findPenInstance()
    local c=LP.Character if not c then return nil end
    local ok,res=pcall(function()
        for _,v3 in ipairs(getgc(true)) do
            if type(v3)=="table" and rawget(v3,"GUID") and rawget(v3,"Players") and rawget(v3,"Active") then
                local v=rawget(v3,"Players") if type(v)~="table" then continue end
                for _,v4 in pairs(v) do if v4==c then return v3 end end
            end
        end
        return nil
    end)
    return ok and res or nil
end
local penCache=nil
local function getPenInstance() if penCache then return penCache end penCache=findPenInstance() return penCache end
local function inPentathlon() return LP:GetAttribute("InPentathlon")==true or Workspace:FindFirstChild("PentathlonMap")~=nil end
local function getPenClient() local ok,r=pcall(function() return require(ReplicatedStorage.Modules.Games.PentathlonClient) end) return ok and r or nil end
local function stopPen(name)
    if S.PentathlonThreads[name] then pcall(task.cancel,S.PentathlonThreads[name]) S.PentathlonThreads[name]=nil end
    if S.PentathlonConns[name] and typeof(S.PentathlonConns[name])=="RBXScriptConnection" then pcall(function() S.PentathlonConns[name]:Disconnect() end) end
    S.PentathlonConns[name]=nil
end
task.spawn(function() while true do task.wait(1) if penCache and not inPentathlon() then penCache=nil end end end)

S.AutoDdakji=false
function S.toggle_auto_ddakji(on)
    if on and not isGameActive("Pentathlon") then notify("Auto Ddakji","Wait for Pentathlon!",0.9) playError() return end
    stopPen("Ddakji") S.AutoDdakji=on
    if on then
        local cl=getPenClient() if not cl then playToggle() return end
        local pw=0.95123884995606622 local ps=Vector3.new(-147.3337,6001.0757,-19.965336) local last=0
        S.PentathlonThreads.Ddakji=task.spawn(function()
            while S.AutoDdakji do
                if inPentathlon() then
                    if tick()-last>=1.5 then
                        local inst=getPenInstance()
                        if inst and inst.Active and inst.CurrentPlayer==LP.Character then
                            pcall(function() cl.RunServerGame(inst,"Thrown",{Power=pw,Position=ps}) end) last=tick()
                        end
                    end
                    task.wait(0.1) continue
                end
                break
            end
            stopPen("Ddakji")
        end)
    end
    playToggle()
end
S.AutoFlyingStone=false
function S.toggle_auto_flying_stone(on)
    if on and not isGameActive("Pentathlon") then notify("Auto Flying Stone","Wait for Pentathlon!",0.9) playError() return end
    stopPen("FlyingStone") S.AutoFlyingStone=on
    if on then
        local cl=getPenClient() if not cl then playToggle() return end
        local last=0 local cache={stand=nil,game=nil}
        S.PentathlonThreads.FlyingStone=task.spawn(function()
            while S.AutoFlyingStone do
                if inPentathlon() then
                    if tick()-last>=1.5 then
                        local inst=getPenInstance()
                        if inst and inst.Active and inst.CurrentPlayer==LP.Character then
                            local hrp=getHRP()
                            if hrp then
                                if not cache.stand or cache.game~=inst then
                                    cache.game=inst local pm=Workspace:FindFirstChild("PentathlonMap") cache.stand=pm and pm:FindFirstChild("Stand",true)
                                end
                                local target
                                if cache.stand and cache.stand:FindFirstChild("Target") then target=cache.stand.Target.Position
                                else target=hrp.Position+hrp.CFrame.LookVector*20 end
                                local origin=hrp.Position+Vector3.new(0,1.5,0)
                                local dir=(target-origin).Unit
                                pcall(function() cl.RunServerGame(inst,"Thrown",{ThrowPower="Perfect",Origin=origin,Direction=dir}) end) last=tick()
                            end
                        end
                    end
                    task.wait(0.1) continue
                end
                break
            end
            stopPen("FlyingStone")
        end)
    end
    playToggle()
end
S.AutoGonggi=false
function S.toggle_auto_gonggi(on)
    if on and not isGameActive("Pentathlon") then notify("Auto Gonggi","Wait for Pentathlon!",0.9) playError() return end
    stopPen("Gonggi") S.AutoGonggi=on
    if on then
        local cl=getPenClient() if not cl then playToggle() return end
        local last=0 local taken={} local instCache=nil
        S.PentathlonThreads.Gonggi=task.spawn(function()
            while S.AutoGonggi do
                if inPentathlon() then
                    local inst=getPenInstance()
                    if inst and inst.Active and inst.CurrentPlayer==LP.Character and tick()-last>=2.5 then
                        if inst~=instCache then instCache=inst table.clear(taken) end
                        local pm=Workspace:FindFirstChild("PentathlonMap")
                        if pm then
                            local target=nil
                            for _,d in ipairs(pm:GetDescendants()) do
                                if d:IsA("BasePart") and d:FindFirstChild("GrabHighlight") and not taken[d.Name] then target=d break end
                            end
                            if target then
                                taken[target.Name]=true last=tick()
                                task.spawn(function()
                                    task.wait(0.4)
                                    if inst and inst.Active then pcall(function() cl.RunServerGame(inst,"GotPiece",{Name=target.Name}) end) end
                                    task.wait(0.3)
                                    if inst and inst.Active then
                                        local done=true
                                        for _,d in ipairs(pm:GetDescendants()) do
                                            if d:IsA("BasePart") and d:FindFirstChild("GrabHighlight") and not taken[d.Name] then done=false break end
                                        end
                                        if done then pcall(function() cl.RunServerGame(inst,"TimeSlowFinish") end) end
                                    end
                                end)
                            end
                        end
                    end
                    task.wait(0.1) continue
                end
                break
            end
            stopPen("Gonggi")
        end)
    end
    playToggle()
end
S.AutoSpinningTop=false
function S.toggle_auto_spinning_top(on)
    if on and not isGameActive("Pentathlon") then notify("Auto Spinning Top","Wait for Pentathlon!",0.9) playError() return end
    stopPen("SpinningTop") S.AutoSpinningTop=on
    if on then
        local cl=getPenClient() if not cl then playToggle() return end
        local state="Tie" local hooked=false local last=0 local instCache=nil
        local function hook(inst)
            if hooked or not inst or not inst.HandleRequest then return end
            local orig=inst.HandleRequest
            inst.HandleRequest=function(self,action,...)
                if action=="Aim" then state="Aim"
                elseif action=="SetPlayer" or action=="Restart" then state="Tie"
                elseif action=="Reset" then state=nil end
                local args=table.pack(...)
                args.n=3+args.n-1
                table.move(args,1,args.n,3,args)
                args[1]=self args[2]=action
                return orig(table.unpack(args,1,args.n))
            end
            hooked=true
        end
        S.PentathlonThreads.SpinningTop=task.spawn(function()
            while S.AutoSpinningTop do
                if inPentathlon() then
                    local inst=getPenInstance()
                    if inst and inst.Active then
                        if inst~=instCache then instCache=inst hooked=false state="Tie" hook(inst) end
                        if inst.CurrentPlayer==LP.Character then
                            local now=tick()
                            if state=="Tie" and now-last>0.3 then pcall(function() cl.RunServerGame(inst,"Tied",{}) end) last=now
                            elseif state=="Aim" and now-last>1.5 then pcall(function() cl.RunServerGame(inst,"Thrown",{}) end) last=now end
                        end
                    end
                    task.wait(0.1) continue
                end
                break
            end
            stopPen("SpinningTop")
        end)
    end
    playToggle()
end
S.AutoJegi=false
function S.toggle_auto_jegi(on)
    if on and not isGameActive("Pentathlon") then notify("Auto Jegi","Wait for Pentathlon!",0.9) playError() return end
    stopPen("Jegi") S.AutoJegi=on
    if on then
        local cl=getPenClient() if not cl then playToggle() return end
        local last=0
        S.PentathlonThreads.Jegi=task.spawn(function()
            while S.AutoJegi do
                if inPentathlon() then
                    if tick()-last>=0.8 then
                        local inst=getPenInstance()
                        if inst and inst.Active and inst.CurrentPlayer==LP.Character then
                            pcall(function() cl.RunServerGame(inst,"Kick",{Lose=false}) end) last=tick()
                        end
                    end
                    task.wait(0.1) continue
                end
                break
            end
            stopPen("Jegi")
        end)
    end
    playToggle()
end

-- DALGONA
S.DalgonaAutoRelax=false S.DalgonaAutoRelaxConnection=nil S.DalgonaLastRelax=0
function S.toggle_dalgona_auto_relax(on)
    S.DalgonaAutoRelax=on
    if S.DalgonaAutoRelaxConnection then S.DalgonaAutoRelaxConnection:Disconnect() S.DalgonaAutoRelaxConnection=nil end
    if on then
        S.DalgonaLastRelax=0
        S.DalgonaAutoRelaxConnection=RunService.Heartbeat:Connect(function()
            if not S.DalgonaAutoRelax then return end
            if tick()-S.DalgonaLastRelax<5 then return end
            local pg=LP:FindFirstChild("PlayerGui") if not pg then return end
            local dui=pg:FindFirstChild("DalgonaUI") if not dui then return end
            local br=dui:FindFirstChild("Breathing") if not br or not br.Visible then return end
            local breath=br:FindFirstChild("Breath") if not breath then return end
            local cpb=br:FindFirstChild("CrackProgressBar") if not cpb then return end
            local cs=cpb:FindFirstChild("ChanceShadow") cs=cs and cs:FindFirstChild("Chance")
            local n=tonumber((cs and cs.Text or "0%"):match("(%d+)")) or 0
            if n<=0 or n>=95 then return end
            pcall(function() firesignal(breath.MouseButton1Click) end) S.DalgonaLastRelax=tick()
        end)
    end
    playToggle()
end
function S.AntiCrack()
    local e=workspace:FindFirstChild("Effects")
    if e then
        for _,c in ipairs(e:GetChildren()) do
            if c.Name and c.Name:find("Outline") then
                for _,d in ipairs(c:GetDescendants()) do
                    if d:IsA("BasePart") and d.Name~="DalgonaClickPart" then
                        pcall(function()
                            local cl=d:Clone() cl.Name="DalgonaClickPart" cl.Parent=d.Parent
                            cl.Size=Vector3.one cl.Transparency=1 cl.CanCollide=false cl.Anchored=true cl.Position=d.Position
                        end)
                    end
                end
            end
        end
    end
end
function S.toggle_anti_crack() S.AntiCrack() playToggle() return true end
function S.shitahhdalgonaez()
    if not getgc or not getupvalues or not setupvalue then return end
    for _,v3 in ipairs(getgc()) do
        if type(v3)=="function" then
            local v4=nil
            if getconstants then local ok,r=pcall(getconstants,v3) v4=ok and r or nil end
            local flag=false
            if type(v4)=="table" then
                for _,v5 in pairs(v4) do
                    if v5=="Completed" or v5=="Progress" then flag=true break
                    elseif type(v5)=="string" and v5:find("%%",1,true) then flag=true break end
                end
            end
            if flag then
                local ok,ups=pcall(getupvalues,v3)
                if ok and type(ups)=="table" then
                    for k,v5 in pairs(ups) do
                        if type(v5)=="number" and v5==v5 and v5>=0 and v5<50000 then pcall(setupvalue,v3,k,100000) end
                    end
                end
            end
        end
    end
end
function S.dalgona_lighter()
    if isGameActive("Dalgona") then LP:SetAttribute("HasLighter",true) else notify("Dalgona","Wait for Dalgona!",0.9) playError() end
    playToggle()
end

-- GLASS BRIDGE
function S.gb_tp_end()
    if isGameActive("GlassBridge") then safeTP(Vector3.new(-196.37247,522.19214,-1534.2098)) notify("GlassBridge","TP End",0.9)
    else notify("GlassBridge","Wait for GlassBridge!",0.9) playError() end
    playToggle()
end
S.AntiBreakEnabled=false S.AntiBreakConn=nil
function S.toggle_anti_break(arg)
    S.AntiBreakEnabled=arg and true or false
    if S.AntiBreakConn then pcall(function() S.AntiBreakConn:Disconnect() end) S.AntiBreakConn=nil end
    local function remove()
        local gb=Workspace:FindFirstChild("GlassBridge") if not gb then return end
        local gh=gb:FindFirstChild("GlassHolder") if not gh then return end
        for _,d in ipairs(gh:GetDescendants()) do
            if d:IsA("TouchTransmitter") then pcall(function() d:Destroy() end)
            elseif d:IsA("ProximityPrompt") then pcall(function() d:Destroy() end)
            elseif type(d.Name)=="string" and d.Name:lower():find("touch") then pcall(function() d:Destroy() end)
            elseif d:IsA("BasePart") then
                for _,c in ipairs(d:GetChildren()) do
                    if c.ClassName=="TouchInterest" then pcall(function() c:Destroy() end) end
                end
            end
        end
    end
    if S.AntiBreakEnabled then
        remove()
        S.AntiBreakConn=RunService.Heartbeat:Connect(function()
            if not S.AntiBreakEnabled then return end
            local now=tick()
            if now<(S._ABLast or 0)+1 then return end
            S._ABLast=now pcall(remove)
        end)
    end
    playToggle()
end

-- MINGLE
S.MingleVoidKillEnabled=false S.MingleConns={}
function S.toggle_mingle_void_kill(on)
    if on and not isGameActive("Mingle") then notify("Mingle Void Kill","Wait for Mingle!",0.9) playError() return end
    for _,c in pairs(S.MingleConns) do pcall(function() c:Disconnect() end) end
    S.MingleConns={} S.MingleVoidKillEnabled=on
    if on then
        local animId="rbxassetid://71318091779666" local plat=nil
        local function attach(arg)
            local hum=arg:FindFirstChildOfClass("Humanoid") or arg:WaitForChild("Humanoid",5)
            if not hum then return end
            local c=hum.AnimationPlayed:Connect(function(tr)
                if not S.MingleVoidKillEnabled then return end
                if not tr.Animation or tr.Animation.AnimationId~=animId then return end
                local hrp=arg:FindFirstChild("HumanoidRootPart") if not hrp then return end
                local saved=hrp.CFrame
                if plat then pcall(function() plat:Destroy() end) plat=nil end
                plat=Instance.new("Part") plat.Name=HttpService:GenerateGUID(false)
                plat.Size=Vector3.new(40,2,40) plat.Position=Vector3.new(196.83342,52.9548,-90.47459)
                plat.Anchored=true plat.CanCollide=true plat.Transparency=1 plat.Parent=workspace
                hrp.AssemblyLinearVelocity=Vector3.zero
                hrp.CFrame=CFrame.new(Vector3.new(196.83342,55.9548,-90.47459))
                if arg.PrimaryPart then pcall(function() arg:SetPrimaryPartCFrame(CFrame.new(Vector3.new(196.83342,55.9548,-90.47459))) end) end
                local c2=tr.Stopped:Connect(function()
                    task.wait(0.6)
                    if arg and arg.Parent and S.MingleVoidKillEnabled then
                        local h2=arg:FindFirstChild("HumanoidRootPart")
                        if h2 then
                            h2.AssemblyLinearVelocity=Vector3.zero h2.CFrame=saved
                            if arg.PrimaryPart then pcall(function() arg:SetPrimaryPartCFrame(saved) end) end
                        end
                    end
                    if plat then pcall(function() plat:Destroy() end) plat=nil end
                    c2:Disconnect()
                end)
            end)
            table.insert(S.MingleConns,c)
        end
        if LP.Character then attach(LP.Character) end
        table.insert(S.MingleConns,LP.CharacterAdded:Connect(function(c) task.wait(0.5) attach(c) end))
    end
    playToggle() return true
end

-- SKYSQUID
S.AutoRespawnOnFall={Enabled=false,Connection=nil,FallHeight=950,TeleportPosition=Vector3.new(0,966,-6),HasTeleported=false}
function S.toggle_auto_respawn_on_fall(enabled)
    if enabled and not isGameActive("SkySquidGame") then notify("Auto Respawn","Wait for SkySquidGame!",0.9) playError() return end
    S.AutoRespawnOnFall.Enabled=enabled S.AutoRespawnOnFall.HasTeleported=false
    if S.AutoRespawnOnFall.Connection then S.AutoRespawnOnFall.Connection:Disconnect() S.AutoRespawnOnFall.Connection=nil end
    if enabled then
        S.AutoRespawnOnFall.Connection=RunService.Heartbeat:Connect(function()
            if not S.AutoRespawnOnFall.Enabled then return end
            if not isGameActive("SkySquidGame") then return end
            local v=getChar() if not v then return end
            local hrp=getHRP(v) if not hrp then return end
            local y=hrp.Position.Y
            if y<=S.AutoRespawnOnFall.FallHeight and not S.AutoRespawnOnFall.HasTeleported then
                hrp.CFrame=CFrame.new(S.AutoRespawnOnFall.TeleportPosition) S.AutoRespawnOnFall.HasTeleported=true
            end
            if S.AutoRespawnOnFall.FallHeight<y then S.AutoRespawnOnFall.HasTeleported=false end
        end)
    end
    playToggle()
end
S.VoidKillSettings={Enabled=false,Conn=nil,CharConn=nil,Platform=nil,BackupPlatform=nil}
S.VoidAnimIds={"rbxassetid://107989020363293","rbxassetid://71619354165195"}
function S.toggle_void_kill(enabled)
    if enabled and not isGameActive("SkySquidGame") then notify("Void Kill","Wait for SkySquidGame!",0.9) playError() return end
    local V=S.VoidKillSettings
    if not enabled then
        if V.Conn then V.Conn:Disconnect() V.Conn=nil end
        if V.CharConn then V.CharConn:Disconnect() V.CharConn=nil end
        if V.Platform then V.Platform:Destroy() V.Platform=nil end
        if V.BackupPlatform then V.BackupPlatform:Destroy() V.BackupPlatform=nil end
        playToggle() return true
    end
    V.Enabled=true
    local function attach(arg)
        local hum=arg:FindFirstChildOfClass("Humanoid") or arg:WaitForChild("Humanoid",5)
        if not hum then return end
        V.Conn=hum.AnimationPlayed:Connect(function(tr)
            if not V.Enabled then return end
            if tr.Animation and table.find(S.VoidAnimIds,tr.Animation.AnimationId) then
                local hrp=arg:FindFirstChild("HumanoidRootPart") if not hrp then return end
                local saved=hrp.CFrame
                local plat=Instance.new("Part") plat.Name=HttpService:GenerateGUID(false)
                plat.Size=Vector3.new(10,1,10) plat.Position=Vector3.new(-95.1,960.6,67.6)
                plat.Anchored=true plat.CanCollide=true plat.Transparency=1 plat.Parent=workspace
                arg:SetPrimaryPartCFrame(CFrame.new(-95.1,964.6,67.6))
                tr.Stopped:Connect(function()
                    task.wait(1)
                    if saved then arg:SetPrimaryPartCFrame(saved) end
                    plat:Destroy()
                end)
            end
        end)
    end
    if LP.Character then attach(LP.Character) end
    V.CharConn=LP.CharacterAdded:Connect(function(c) task.wait(1) attach(c) end)
    playToggle() return true
end
S.SkySquidAntiFall={Enabled=false,Platform=nil,Conn=nil}
function S.toggle_sky_squid_anti_fall(enabled)
    if S.SkySquidAntiFall.Conn then S.SkySquidAntiFall.Conn:Disconnect() end
    if S.SkySquidAntiFall.Platform then S.SkySquidAntiFall.Platform:Destroy() end
    S.SkySquidAntiFall.Enabled=enabled
    if enabled then
        local function mk()
            local c=getChar() if not c then return nil end
            local hrp=getHRP(c) if not hrp then return nil end
            local p=Instance.new("Part") p.Name=HttpService:GenerateGUID(false)
            p.Size=Vector3.new(10000,1,10000) p.Position=Vector3.new(hrp.Position.X,hrp.Position.Y-5,hrp.Position.Z)
            p.Anchored=true p.CanCollide=true p.Transparency=0.5 p.Parent=workspace return p
        end
        S.SkySquidAntiFall.Platform=mk()
        S.SkySquidAntiFall.Conn=RunService.Heartbeat:Connect(function()
            if not S.SkySquidAntiFall.Enabled then return end
            if not (S.SkySquidAntiFall.Platform and S.SkySquidAntiFall.Platform.Parent) then S.SkySquidAntiFall.Platform=mk() end
        end)
    end
    playToggle() return true
end

S.OrbitKillauraEnabled=false S.OrbitKillauraConn=nil S.OrbitRadius=3 S.OrbitSpeed=10
S._DeathAnimId="rbxassetid://82747596610040" S._DeathAnimConns={}
function S.StartDeathAnimGuard(arg,arg2)
    if S._DeathAnimConns[arg] then pcall(function() S._DeathAnimConns[arg]:Disconnect() end) S._DeathAnimConns[arg]=nil end
    local function fn(arg3)
        if not arg3 then return end
        local hum=arg3:FindFirstChildOfClass("Humanoid") if not hum then return end
        if S._DeathAnimConns[arg] then pcall(function() S._DeathAnimConns[arg]:Disconnect() end) end
        S._DeathAnimConns[arg]=hum.AnimationPlayed:Connect(function(tr)
            local ok,r=pcall(function() return tr.Animation end)
            if not ok or not r then return end
            local s=tostring(r.AnimationId or "")
            if s==S._DeathAnimId or s:find("82747596610040") then
                if S[arg] then
                    S[arg]=false
                    pcall(function() if arg2 then arg2() end end)
                    pcall(function() notify("Feature disabled to prevent death","",1.2) end)
                end
            end
        end)
    end
    fn(LP.Character)
    S._DeathAnimConns[arg.."_ca"]=LP.CharacterAdded:Connect(function(c) task.wait(0.2) if S[arg] then fn(c) end end)
end
function S.StopDeathAnimGuard(arg)
    if S._DeathAnimConns[arg] then pcall(function() S._DeathAnimConns[arg]:Disconnect() end) S._DeathAnimConns[arg]=nil end
    if S._DeathAnimConns[arg.."_ca"] then pcall(function() S._DeathAnimConns[arg.."_ca"]:Disconnect() end) S._DeathAnimConns[arg.."_ca"]=nil end
end
local function findNearestEnemy()
    local c=LP.Character if not c or not c:FindFirstChild("HumanoidRootPart") then return nil end
    local pos=c.HumanoidRootPart.Position local bd=math.huge local res=nil
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP and p.Character then
            local hrp=p.Character:FindFirstChild("HumanoidRootPart") local h=p.Character:FindFirstChild("Humanoid")
            if hrp and h and h.Health>0 and not p.Character:FindFirstChild("Dead") then
                local d=(pos-hrp.Position).Magnitude
                if d<bd then bd=d res=p end
            end
        end
    end
    return res
end
function S.toggle_orbit_killaura(arg)
    local on=arg and true or false
    if on then
        local flag=false
        pcall(function() flag=isGameActive("SkySquidGame") or isGameActive("SquidGame") end)
        if not flag then
            pcall(function()
                local v=workspace:FindFirstChild("Values") v=v and v:FindFirstChild("CurrentGame")
                if (v and tostring(v.Value) or ""):lower():find("squid") then flag=true end
            end)
        end
        if not flag then notify("Orbit Kill Aura","Only SkySquidGame/SquidGame",1.2) playError() return false end
    end
    S.OrbitKillauraEnabled=on
    if S.OrbitKillauraConn then pcall(function() S.OrbitKillauraConn:Disconnect() end) S.OrbitKillauraConn=nil end
    if not on then S.StopDeathAnimGuard("OrbitKillauraEnabled") playToggle() return true end
    S.StartDeathAnimGuard("OrbitKillauraEnabled",function()
        if S.OrbitKillauraConn then pcall(function() S.OrbitKillauraConn:Disconnect() end) S.OrbitKillauraConn=nil end
    end)
    S.OrbitKillauraConn=RunService.Heartbeat:Connect(function()
        if not S.OrbitKillauraEnabled then return end
        local tgt=findNearestEnemy() if not tgt or not tgt.Character then return end
        local hrp=tgt.Character:FindFirstChild("HumanoidRootPart") local hum=tgt.Character:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health<=0 then return end
        local c=LP.Character if not c then return end
        local hrp2=c:FindFirstChild("HumanoidRootPart") if not hrp2 then return end
        local n=tick()*(S.OrbitSpeed or 10)%6.2831853071795862
        local r=S.OrbitRadius or 3 local pos=hrp.Position local yOff=0
        if S.OrbitAntiHitEnabled then
            local t3={["79649041083405"]=true,["73242877658272"]=true,["85793691404836"]=true,["86197206792061"]=true,["99157505926076"]=true}
            local function match(id) local m=tostring(id or ""):match("(%d+)") return m and t3[m] or false end
            local flag=false
            pcall(function()
                local c2=tgt.Character if not c2 then return end
                local h2=c2:FindFirstChildOfClass("Humanoid")
                local function check(tracks)
                    for _,tr in pairs(tracks or {}) do
                        local ok,r=pcall(function() return tr.IsPlaying end)
                        if ok and r then
                            local ok2,r2=pcall(function() return tr.Animation end)
                            if ok2 and r2 and match(r2.AnimationId) then return true end
                            local ok3,r3=pcall(function() return tr.AnimationId end)
                            if ok3 and match(r3) then return true end
                        end
                    end
                    return false
                end
                if h2 then
                    flag=check(h2:GetPlayingAnimationTracks())
                    if not flag then
                        local an=h2:FindFirstChildOfClass("Animator")
                        if an then flag=check(an:GetPlayingAnimationTracks()) end
                    end
                end
            end)
            if flag then yOff=16 end
        end
        hrp2.CFrame=CFrame.new(Vector3.new(pos.X+math.cos(n)*r,pos.Y+yOff,pos.Z+math.sin(n)*r),hrp.Position)
    end)
    playToggle() return true
end
function S.set_orbit_radius(v) S.OrbitRadius=math.clamp(tonumber(v) or 3,1,10) end
function S.set_orbit_speed(v) S.OrbitSpeed=math.clamp(tonumber(v) or 10,1,10) end

-- POWER ESP
S.ESPPowersEnabled=false S.ESPPowersDrawings={} S.ESPPowersConnection=nil
C.PowerESPColor=Color3.fromRGB(255,255,255) C.PowerESPFont=2 C.PowerESPSize=16
function S.clear_esp_powers()
    for _,d in pairs(S.ESPPowersDrawings) do pcall(function() if d.Remove then d:Remove() elseif d.Destroy then d:Destroy() end end) end
    S.ESPPowersDrawings={}
    if S.ESPPowersConnection then pcall(function() S.ESPPowersConnection:Disconnect() end) S.ESPPowersConnection=nil end
end
function S.toggle_esp_powers(arg)
    S.ESPPowersEnabled=arg and true or false S.clear_esp_powers()
    if not arg then playToggle() return true end
    local function getPow(p)
        if not p then return nil end
        local attrs={"_EquippedPower","EquippedPower","Power","CurrentPower","Ability"}
        for _,a in ipairs(attrs) do local v=p:GetAttribute(a) if v~=nil and v~=false and v~="" and v~=0 then return tostring(v) end end
        local c=p.Character
        if c then
            for _,a in ipairs(attrs) do local v=c:GetAttribute(a) if v~=nil and v~=false and v~="" and v~=0 then return tostring(v) end end
            for _,d in ipairs(c:GetDescendants()) do
                if d.Name=="_EquippedPower" or d.Name=="EquippedPower" or d.Name=="Power" then
                    if d:IsA("StringValue") or d:IsA("NumberValue") then return tostring(d.Value) end
                    local v=d:GetAttribute("Value") or d:GetAttribute("Name") if v then return tostring(v) end
                end
            end
        end
        return nil
    end
    S.ESPPowersConnection=RunService.RenderStepped:Connect(function()
        if not S.ESPPowersEnabled then return end
        local cam=workspace.CurrentCamera if not cam then return end
        local active={}
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=LP and p.Character then
                local pow=getPow(p)
                if pow then
                    local head=p.Character:FindFirstChild("Head") or p.Character:FindFirstChild("HumanoidRootPart")
                    if head then
                        local pos,on=cam:WorldToViewportPoint(head.Position+Vector3.new(0,2.2,0))
                        active[p.UserId]=true
                        local d=S.ESPPowersDrawings[p.UserId]
                        if not d then d=Drawing.new("Text") d.Center=true d.Outline=true S.ESPPowersDrawings[p.UserId]=d end
                        d.Color=C.PowerESPColor d.Font=C.PowerESPFont d.Size=C.PowerESPSize d.OutlineColor=Color3.new(0,0,0)
                        if on and pos.Z>0 then d.Visible=true d.Position=Vector2.new(pos.X,pos.Y) d.Text=pow
                        else d.Visible=false end
                    end
                end
            end
        end
        for k,d in pairs(S.ESPPowersDrawings) do
            if not active[k] then pcall(function() if d.Remove then d:Remove() end end) S.ESPPowersDrawings[k]=nil end
        end
    end)
    playToggle() return true
end

-- H&S ESP (2D box)
S.HNSEspEnabled=false S.HNSEspDrawings={} S.HNSEspConn=nil
C.HNSSafeColor=Color3.fromRGB(0,255,0) C.HNSSeekerColor=Color3.fromRGB(255,0,0) C.HNSGuardColor=Color3.fromRGB(255,255,0) C.HNSTracerColor=Color3.fromRGB(0,255,0)
function S.clearHNSEsp()
    for _,o in pairs(S.HNSEspDrawings) do
        if type(o)=="table" then
            pcall(function() if o.box then o.box:Remove() end end)
            pcall(function() if o.name then o.name:Remove() end end)
            pcall(function() if o.tracer then o.tracer:Remove() end end)
        else pcall(function() if o.Remove then o:Remove() end end) end
    end
    S.HNSEspDrawings={}
    if S.HNSEspConn then pcall(function() S.HNSEspConn:Disconnect() end) S.HNSEspConn=nil end
end
function S.toggle_hns_esp(on)
    S.HNSEspEnabled=on and true or false S.clearHNSEsp()
    if not on then playToggle() return end
    if not isGameActive("HideAndSeek") then notify("H&S ESP","Wait for HideAndSeek!",0.9) playError() return end
    S.HNSEspConn=RunService.RenderStepped:Connect(function()
        if not S.HNSEspEnabled then return end
        if not isGameActive("HideAndSeek") then return end
        local cam=workspace.CurrentCamera if not cam then return end
        local hrp=getHRP() if not hrp then return end
        local from=cam:WorldToViewportPoint(hrp.Position) local fromV=Vector2.new(from.X,from.Y)
        local active={}
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=LP and p.Character then
                local hum=p.Character:FindFirstChildOfClass("Humanoid")
                local root=p.Character:FindFirstChild("HumanoidRootPart")
                local head=p.Character:FindFirstChild("Head")
                if hum and hum.Health>0 and root and head then
                    local color
                    if isGuard(p) then color=C.HNSGuardColor
                    elseif isSeeker(p) then color=C.HNSSeekerColor
                    elseif isHider(p) then color=C.HNSSafeColor
                    else color=Color3.fromRGB(255,255,255) end
                    active[p.UserId]=true
                    local top=cam:WorldToViewportPoint(head.Position+Vector3.new(0,0.6,0))
                    local bot=cam:WorldToViewportPoint(root.Position-Vector3.new(0,1.2,0))
                    local rootPos,on=cam:WorldToViewportPoint(root.Position)
                    if on and top.Z>0 and bot.Z>0 then
                        local h=math.abs(top.Y-bot.Y) local w=h*0.55
                        local d=S.HNSEspDrawings[p.UserId]
                        if not d then
                            d={}
                            d.box=Drawing.new("Square") d.box.Thickness=1.5 d.box.Filled=false
                            d.name=Drawing.new("Text") d.name.Center=true d.name.Outline=true d.name.Size=14 d.name.Font=2
                            d.tracer=Drawing.new("Line") d.tracer.Thickness=1.5
                            S.HNSEspDrawings[p.UserId]=d
                        end
                        d.box.Visible=true d.box.Position=Vector2.new(bot.X-w/2,top.Y) d.box.Size=Vector2.new(w,h) d.box.Color=color
                        d.name.Visible=true d.name.Position=Vector2.new(top.X,top.Y-16) d.name.Color=color d.name.Text=p.Name
                        d.tracer.Visible=true d.tracer.Color=C.HNSTracerColor d.tracer.From=fromV d.tracer.To=Vector2.new(rootPos.X,rootPos.Y)
                    else
                        local d=S.HNSEspDrawings[p.UserId]
                        if d then d.box.Visible=false d.name.Visible=false d.tracer.Visible=false end
                    end
                end
            end
        end
        for k,d in pairs(S.HNSEspDrawings) do
            if not active[k] then
                pcall(function() if d.box then d.box:Remove() end end)
                pcall(function() if d.name then d.name:Remove() end end)
                pcall(function() if d.tracer then d.tracer:Remove() end end)
                S.HNSEspDrawings[k]=nil
            end
        end
    end)
    playToggle()
end

-- EXTRA
S.CustomGravityEnabled=false S.CustomGravityValue=196.2 S.CustomGravityConn=nil
function S.toggle_custom_gravity(on)
    S.CustomGravityEnabled=on
    if S.CustomGravityConn then S.CustomGravityConn:Disconnect() S.CustomGravityConn=nil end
    if on then
        Workspace.Gravity=S.CustomGravityValue
        S.CustomGravityConn=RunService.Heartbeat:Connect(function() if S.CustomGravityEnabled then Workspace.Gravity=S.CustomGravityValue end end)
    else Workspace.Gravity=196.2 end
    playToggle()
end
function S.set_custom_gravity(v)
    local n=tonumber(v)
    if n and n>=50 and n<=500 then S.CustomGravityValue=n if S.CustomGravityEnabled then Workspace.Gravity=n end
    else notify("Custom Gravity","Invalid (50-500)",0.9) playError() end
end
S.CustomJumpPowerEnabled=false S.CustomJumpPowerValue=50 S.CustomJumpPowerConn=nil
function S.toggle_custom_jump_power(on)
    S.CustomJumpPowerEnabled=on
    if S.CustomJumpPowerConn then S.CustomJumpPowerConn:Disconnect() S.CustomJumpPowerConn=nil end
    if on then
        local c=getChar() if c then local h=getHum(c) if h then S.OriginalJumpPower=h.JumpPower h.JumpPower=S.CustomJumpPowerValue end end
        S.CustomJumpPowerConn=RunService.Heartbeat:Connect(function()
            if S.CustomJumpPowerEnabled then
                local c2=getChar() if c2 then local h=getHum(c2) if h and h.JumpPower~=S.CustomJumpPowerValue then h.JumpPower=S.CustomJumpPowerValue end end
            end
        end)
    else local c=getChar() if c then local h=getHum(c) if h then h.JumpPower=S.OriginalJumpPower or 50 end end end
    playToggle()
end
function S.set_custom_jump_power(v)
    local n=tonumber(v)
    if n and n>=20 and n<=200 then
        S.CustomJumpPowerValue=n
        if S.CustomJumpPowerEnabled then local c=getChar() if c then local h=getHum(c) if h then h.JumpPower=n end end end
    else notify("Custom Jump Power","Invalid (20-200)",0.9) playError() end
end
S.CustomLevelEnabled=false S.CustomLevelValue=1 S.CustomLevelConn=nil
function S.toggle_custom_level(on)
    S.CustomLevelEnabled=on
    if S.CustomLevelConn then S.CustomLevelConn:Disconnect() S.CustomLevelConn=nil end
    if on then
        LP:SetAttribute("_CurrentLevel",S.CustomLevelValue)
        S.CustomLevelConn=RunService.Heartbeat:Connect(function() if S.CustomLevelEnabled then LP:SetAttribute("_CurrentLevel",S.CustomLevelValue) end end)
    end
    playToggle()
end
function S.set_custom_level(v)
    local n=tonumber(v)
    if n and n>=1 and n<=999999 then
        S.CustomLevelValue=math.floor(n)
        if S.CustomLevelEnabled then LP:SetAttribute("_CurrentLevel",S.CustomLevelValue) end
    else notify("Custom Level","Invalid (1-999999)",0.9) playError() end
end
S.CustomWinstreakEnabled=false S.CustomWinstreakValue=0 S.CustomWinstreakConn=nil
function S.toggle_custom_winstreak(on)
    S.CustomWinstreakEnabled=on
    if S.CustomWinstreakConn then S.CustomWinstreakConn:Disconnect() S.CustomWinstreakConn=nil end
    if on then
        LP:SetAttribute("_ConsecutiveWins",S.CustomWinstreakValue)
        S.CustomWinstreakConn=RunService.Heartbeat:Connect(function() if S.CustomWinstreakEnabled then LP:SetAttribute("_ConsecutiveWins",S.CustomWinstreakValue) end end)
    end
    playToggle()
end
function S.set_custom_winstreak(v)
    local n=tonumber(v)
    if n and n>=0 and n<=999999 then
        S.CustomWinstreakValue=math.floor(n)
        if S.CustomWinstreakEnabled then LP:SetAttribute("_ConsecutiveWins",S.CustomWinstreakValue) end
    else notify("Custom Winstreak","Invalid",0.9) playError() end
end

C.ClothesColor=Color3.fromRGB(255,255,255) C.VFXColor=Color3.fromRGB(0,255,255)
C.ClothesColorEnabled=false C.VFXColorEnabled=false
C.FakeSettings={["Custom Clothing Color"]=false,["Custom Ability Color"]=false}
S._SettingData=nil
function S.InitSettingDataSpoof()
    local ok,sd=pcall(function()
        local e=ReplicatedStorage:FindFirstChild("Effects") local m=e and e:FindFirstChild("Modules")
        local s=m and m:FindFirstChild("SettingData") if not s then return nil end return require(s)
    end)
    if not ok or type(sd)~="table" then return end
    S._SettingData=sd
    local function upd(t)
        for k,v in pairs(t) do
            if k=="Custom Clothing Color" then t[k]=C.FakeSettings["Custom Clothing Color"]
            elseif k=="Custom Ability Color" then t[k]=C.FakeSettings["Custom Ability Color"]
            elseif typeof(v)=="table" and v~=t then upd(v) end
        end
    end
    S._updateGameTables=upd
    for k,v in pairs(sd) do
        if typeof(v)=="function" then
            local orig=v
            sd[k]=function(a,...)
                local pack=table.pack(...) local args={...}
                if typeof(a)=="string" and C.FakeSettings[a]~=nil then return C.FakeSettings[a] end
                if typeof(args[1])=="string" and C.FakeSettings[args[1]]~=nil then return C.FakeSettings[args[1]] end
                return orig(a,table.unpack(pack,1,pack.n))
            end
        end
    end
end
function S.UpdateVIPClothes()
    C.FakeSettings["Custom Clothing Color"]=C.ClothesColorEnabled
    pcall(function() if S._updateGameTables and S._SettingData then S._updateGameTables(S._SettingData) end end)
    _G.UniformColorValue=C.ClothesColor _G.SetUniformSkinEnabled=C.ClothesColorEnabled
    pcall(function()
        if C.ClothesColorEnabled then
            LP:SetAttribute("ClothingColor",C.ClothesColor)
            LP:SetAttribute("UniformColorValue",C.ClothesColor)
            LP:SetAttribute("ClothingColorToggle",true)
            LP:SetAttribute("SetUniformSkinEnabled",true)
        else
            LP:SetAttribute("ClothingColor",nil) LP:SetAttribute("UniformColorValue",nil)
            LP:SetAttribute("ClothingColorToggle",false) LP:SetAttribute("SetUniformSkinEnabled",false)
        end
    end)
end
function S.toggle_custom_uniform_color(on) C.ClothesColorEnabled=on S.UpdateVIPClothes() playToggle() return true end
function S.set_uniform_color(c) if typeof(c)=="Color3" then C.ClothesColor=c if C.ClothesColorEnabled then S.UpdateVIPClothes() end end end
function S.UpdateVIPVFX()
    C.FakeSettings["Custom Ability Color"]=C.VFXColorEnabled
    pcall(function() if S._updateGameTables and S._SettingData then S._updateGameTables(S._SettingData) end end)
end
task.spawn(function() pcall(S.InitSettingDataSpoof) end)

S._OpFly={flying=false,keyDown=nil,keyUp=nil,m1=nil,m2=nil,velName="OpFlyVel",gyroName="OpFlyGyro",speed=1}
S.FlySpeed=50
function S.toggle_fly(on)
    on=on and true or false
    local opFly=S._OpFly
    local function clean()
        opFly.flying=false
        if opFly.keyDown then pcall(function() opFly.keyDown:Disconnect() end) opFly.keyDown=nil end
        if opFly.keyUp then pcall(function() opFly.keyUp:Disconnect() end) opFly.keyUp=nil end
        if opFly.m1 then pcall(function() opFly.m1:Disconnect() end) opFly.m1=nil end
        if opFly.m2 then pcall(function() opFly.m2:Disconnect() end) opFly.m2=nil end
        pcall(function()
            local hrp=getHRP()
            if hrp then
                local v=hrp:FindFirstChild(opFly.velName) if v then v:Destroy() end
                local g=hrp:FindFirstChild(opFly.gyroName) if g then g:Destroy() end
            end
            local h=getHum() if h then h.PlatformStand=false h.AutoRotate=true end
        end)
    end
    clean()
    if not on then playToggle() return true end
    local isMobile=UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    local c=getChar() local hum=getHum(c) local hrp=getHRP(c)
    if not hrp or not hum then playToggle() return false end
    if isMobile then
        opFly.flying=true
        local bv=Instance.new("BodyVelocity") bv.Name=opFly.velName bv.MaxForce=Vector3.zero bv.Velocity=Vector3.new() bv.Parent=hrp
        local bg=Instance.new("BodyGyro") bg.Name=opFly.gyroName bg.MaxTorque=Vector3.new(9e9,9e9,9e9) bg.P=1000 bg.D=50 bg.Parent=hrp
        local cm=nil pcall(function() cm=require(LP.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule")) end)
        opFly.m2=RunService.RenderStepped:Connect(function()
            if not opFly.flying then return end
            local h2=getHRP() if not h2 then return end
            local v=h2:FindFirstChild(opFly.velName) local g=h2:FindFirstChild(opFly.gyroName) local hu=getHum()
            if not (v and g and hu) then return end
            v.MaxForce=Vector3.new(9e9,9e9,9e9) g.MaxTorque=Vector3.new(9e9,9e9,9e9) hu.PlatformStand=true
            local cam=workspace.CurrentCamera g.CFrame=cam.CFrame v.Velocity=Vector3.new()
            local vec=Vector3.new() pcall(function() if cm then vec=cm:GetMoveVector() end end)
            local n=S.FlySpeed*5
            if vec.X~=0 then v.Velocity=v.Velocity+cam.CFrame.RightVector*vec.X*n end
            if vec.Z~=0 then v.Velocity=v.Velocity-cam.CFrame.LookVector*vec.Z*n end
        end)
    else
        local keys={F=0,B=0,L=0,R=0,Q=0,E=0} local lastKeys={F=0,B=0,L=0,R=0,Q=0,E=0}
        local n=0 local speed=S.FlySpeed/100 opFly.flying=true
        local bg=Instance.new("BodyGyro") local bv=Instance.new("BodyVelocity")
        bg.P=90000 bg.Parent=hrp bv.Parent=hrp
        bg.MaxTorque=Vector3.new(9e9,9e9,9e9) bg.CFrame=hrp.CFrame
        bv.Velocity=Vector3.zero bv.MaxForce=Vector3.new(9e9,9e9,9e9)
        task.spawn(function()
            while true do
                task.wait()
                local cam=workspace.CurrentCamera hum.PlatformStand=true
                if keys.L+keys.R~=0 or keys.F+keys.B~=0 or keys.Q+keys.E~=0 then n=50 elseif n~=0 then n=0 end
                if keys.L+keys.R~=0 or keys.F+keys.B~=0 or keys.Q+keys.E~=0 then
                    local pos=cam.CFrame.Position
                    bv.Velocity=(cam.CFrame.LookVector*(keys.F+keys.B)+cam.CFrame*CFrame.new(keys.L+keys.R,(keys.F+keys.B+keys.Q+keys.E)*0.2,0).Position-pos)*n
                    lastKeys={F=keys.F,B=keys.B,L=keys.L,R=keys.R,Q=keys.Q,E=keys.E}
                elseif n~=0 then
                    local pos=cam.CFrame.Position
                    bv.Velocity=(cam.CFrame.LookVector*(lastKeys.F+lastKeys.B)+cam.CFrame*CFrame.new(lastKeys.L+lastKeys.R,(lastKeys.F+lastKeys.B+lastKeys.Q+lastKeys.E)*0.2,0).Position-pos)*n
                else bv.Velocity=Vector3.zero end
                bg.CFrame=cam.CFrame
                if not (not opFly.flying or not S.FlySpeed) then continue end
                break
            end
            pcall(function() bg:Destroy() end) pcall(function() bv:Destroy() end)
            pcall(function() hum.PlatformStand=false end)
        end)
        opFly.keyDown=UserInputService.InputBegan:Connect(function(input,gp)
            if gp then return end
            if input.KeyCode==Enum.KeyCode.W then keys.F=speed
            elseif input.KeyCode==Enum.KeyCode.S then keys.B=-speed
            elseif input.KeyCode==Enum.KeyCode.A then keys.L=-speed
            elseif input.KeyCode==Enum.KeyCode.D then keys.R=speed
            elseif input.KeyCode==Enum.KeyCode.E then keys.Q=speed*2
            elseif input.KeyCode==Enum.KeyCode.Q then keys.E=-speed*2 end
        end)
        opFly.keyUp=UserInputService.InputEnded:Connect(function(input)
            if input.KeyCode==Enum.KeyCode.W then keys.F=0
            elseif input.KeyCode==Enum.KeyCode.S then keys.B=0
            elseif input.KeyCode==Enum.KeyCode.A then keys.L=0
            elseif input.KeyCode==Enum.KeyCode.D then keys.R=0
            elseif input.KeyCode==Enum.KeyCode.E then keys.Q=0
            elseif input.KeyCode==Enum.KeyCode.Q then keys.E=0 end
        end)
    end
    playToggle() return true
end

-- REBEL
S.AutoBecomeGuardEnabled=false S.AutoBecomeGuardTier="Circle" S.AutoBecomeGuardTask=nil
S.set_guard_tier=function(a)
    local t=tostring(a or "Circle")
    if t~="Circle" and t~="Triangle" and t~="Square" then t="Circle" end
    S.AutoBecomeGuardTier=t
end
do
    local badWords={"buy","playable","one.time","onetime","temporary","onetim","time.playable","time.guard","playable.guard","one.time.guard","temporary.guard","playable.one.time"}
    local function gatherText(el)
        local t={}
        pcall(function() if el.Text then table.insert(t,string.lower(tostring(el.Text))) end end)
        pcall(function() for _,d in ipairs(el:GetDescendants()) do if d:IsA("TextLabel") or d:IsA("TextButton") then table.insert(t,string.lower(tostring(d.Text or ""))) end end end)
        pcall(function()
            table.insert(t,string.lower(el.Name or ""))
            local p=el.Parent for i=1,4 do if p then table.insert(t,string.lower(p.Name or "")) p=p.Parent else break end end
        end)
        return table.concat(t," ")
    end
    local function isBad(el) local s=gatherText(el) for _,w in ipairs(badWords) do if string.find(s,w,1,true) then return true end end return false end
    local function fireBtn(el)
        if not el or isBad(el) then return false end
        local fired=false
        pcall(function() if firesignal then pcall(firesignal,el.MouseButton1Click) pcall(firesignal,el.Activated) pcall(firesignal,el.MouseButton1Down) pcall(firesignal,el.MouseButton1Up) fired=true end end)
        pcall(function()
            if getconnections then
                for _,sig in ipairs({el.MouseButton1Click,el.Activated,el.MouseButton1Down,el.MouseButton1Up}) do
                    if sig then
                        for _,c in pairs(getconnections(sig)) do pcall(function() if c.Fire then c:Fire() end end) fired=true end
                    end
                end
            end
        end)
        return fired
    end
    local function byPath(parts)
        local pg=LP:FindFirstChild("PlayerGui") if not pg then return {} end
        local res={}
        for _,d in ipairs(pg:GetDescendants()) do
            if d:IsA("GuiButton") or d:IsA("TextButton") or d:IsA("ImageButton") then
                local chain={} local p=d
                for i=1,8 do if p and p~=pg then table.insert(chain,1,string.lower(p.Name or "")) p=p.Parent else break end end
                local s=table.concat(chain,"/") local ok=true
                for _,k in ipairs(parts) do if not string.find(s,string.lower(k),1,true) then ok=false break end end
                if ok then table.insert(res,d) end
            end
        end
        return res
    end
    local function byText(keys)
        local pg=LP:FindFirstChild("PlayerGui") if not pg then return {} end
        local res={}
        for _,d in ipairs(pg:GetDescendants()) do
            if d:IsA("GuiButton") or d:IsA("TextButton") or d:IsA("ImageButton") then
                local s=gatherText(d)
                for _,k in ipairs(keys) do if string.find(s,string.lower(k),1,true) then table.insert(res,d) break end end
            end
        end
        return res
    end
    local function doOnce()
        pcall(function() LP:SetAttribute("__OwnsPermGuard",true) end)
        local tiers=({Circle={"worker","circle","tier1","EquipTier1"},Triangle={"soldier","triangle","tier2","EquipTier2"},Square={"manager","square","tier3","EquipTier3"}})[S.AutoBecomeGuardTier] or {"worker","circle"}
        for _,v in ipairs(byPath({"RankSelection",tiers[4] or "EquipTier1"})) do fireBtn(v) end
        for _,k in ipairs(tiers) do for _,v in ipairs(byText({k})) do if not isBad(v) then fireBtn(v) end end end
        for _,v in ipairs(byText({"equip","lock in","lockin"})) do if not isBad(v) then fireBtn(v) end end
        for _,v in ipairs(byPath({"RankConfirmation","Green"})) do fireBtn(v) end
        for _,v in ipairs(byText({"confirm","lock in","green"})) do if not isBad(v) then fireBtn(v) end end
    end
    S.toggle_auto_become_guard=function(arg)
        S.AutoBecomeGuardEnabled=arg and true or false
        if S.AutoBecomeGuardTask then pcall(task.cancel,S.AutoBecomeGuardTask) S.AutoBecomeGuardTask=nil end
        if not S.AutoBecomeGuardEnabled then playToggle() return end
        S.AutoBecomeGuardTask=task.spawn(function()
            while S.AutoBecomeGuardEnabled do
                if not LP:GetAttribute("IsGuard") then doOnce() task.wait(0.12) continue end
                break
            end
        end)
        playToggle()
    end
end

-- ================== UI ==================
local Window=WindUI:CreateWindow({
    Title="Xionix_Dewamp v 2.1",
    Author="Xionix",
    Folder="Xionix_Dewamp_v21",
    Size=UDim2.fromOffset(560,460),
    Theme="Dark",
    Resizable=true,
})

local function T(tab,cfg,setter)
    local last=cfg.Default or false
    local obj=tab:Toggle({
        Title=cfg.Title, Desc=cfg.Desc, Default=last,
        Callback=function(v) last=v setter(v) end,
    })
    task.spawn(function()
        while not S.unloaded do task.wait(0.15)
            pcall(function() local v=obj.Value if type(v)=="boolean" and v~=last then last=v setter(v) end end)
        end
    end)
    return obj
end

-- LIGHTS OUT TAB
local TabLO=Window:Tab({Title="Lights Out",Icon="moon"})
TabLO:Section({Title="Lights Out"})
T(TabLO,{Title="Safezone TP",Default=false},function(v) S.toggle_lights_out_safezone(v) end)
T(TabLO,{Title="Vampire Lightning",Default=false},function(v) S.toggle_vampire_vision(v) end)

-- HIDE AND SEEK TAB
local TabHNS=Window:Tab({Title="Hide and Seek",Icon="eye-off"})
TabHNS:Section({Title="Teleports"})
TabHNS:Button({Title="TP to Spawn",Callback=function() S.teleport_to_spawn() end})
TabHNS:Button({Title="TP to Hider",Callback=function() S.teleport_to_hider() end})
TabHNS:Button({Title="TP to Seeker",Callback=function() S.teleport_to_seeker() end})
TabHNS:Button({Title="TP Random Exit",Callback=function() S.teleport_random_exit() end})
TabHNS:Section({Title="ESP"})
T(TabHNS,{Title="ESP Dropped Keys",Default=false},function(v) S.toggle_key_esp(v) end)
T(TabHNS,{Title="ESP Exit Doors",Default=false},function(v) S.toggle_exit_door_esp(v) end)
T(TabHNS,{Title="ESP Spikes",Default=false},function(v) S.toggle_spikes_esp(v) end)
TabHNS:Section({Title="Utilities"})
T(TabHNS,{Title="Infinite Faster Sprint",Default=false},function(v) S.toggle_faster_sprint(v) end)
T(TabHNS,{Title="Auto Dodge (HnS)",Desc="Strict mode: only dodges real hit animations",Default=false},function(v) S.toggle_auto_dodge(v) end)
TabHNS:Slider({Title="Dodge Radius",Value={Min=1,Max=95,Default=18},Step=1,Callback=function(v) S.AutoDodge.Distance=v end})
TabHNS:Slider({Title="Dodge Delay",Value={Min=0,Max=0.25,Default=0},Step=0.01,Callback=function(v) S.AutoDodge.Delay=v end})
TabHNS:Slider({Title="Dodge Min Interval",Value={Min=0.02,Max=1.0,Default=0.02},Step=0.01,Callback=function(v) S.AutoDodge.MinInterval=v end})
TabHNS:Slider({Title="Anim Watch Min",Value={Min=0.05,Max=2.0,Default=0.4},Step=0.05,Callback=function(v) S.AutoDodge.AnimWatch=v end})
TabHNS:Slider({Title="Watch After Anim",Value={Min=0,Max=1.5,Default=0.3},Step=0.05,Callback=function(v) S.AutoDodge.WatchAfter=v end})
TabHNS:Input({Title="Manual Slot (empty=auto)",Value="",Callback=function(v) S.AutoDodge.ManualSlot=string.upper(v) end})
T(TabHNS,{Title="Spikes Kill",Default=false},function(v) S.toggle_spikes_kill(v) end)
T(TabHNS,{Title="TP to Spikes",Default=false},function(v) S.toggle_spikes_platform_teleport(v) end)
T(TabHNS,{Title="Anti-Spikes",Default=false},function(v) S.toggle_anti_spikes(v) end)

-- JUMP ROPE TAB
local TabJR=Window:Tab({Title="Jump Rope",Icon="activity"})
TabJR:Section({Title="Jump Rope"})
T(TabJR,{Title="Anti Fall",Default=false},function(v) S.toggle_jump_rope_anti_fall(v) end)
T(TabJR,{Title="Anti Hit",Default=false},function(v) S.toggle_jump_rope_anti_hit(v) end)
T(TabJR,{Title="Fake Balance",Default=false},function(v) S.toggle_jump_rope_fake_balance(v) end)
T(TabJR,{Title="Freeze Rope",Default=false},function(v) S.toggle_freeze_rope(v) end)
TabJR:Button({Title="Remove Balance Mini Game",Callback=function() S.remove_balance_mini_game() end})
TabJR:Button({Title="Remove Rope",Callback=function() S.jr_delete_rope() end})
TabJR:Button({Title="TP to Start",Callback=function() S.jr_tp_start() end})
TabJR:Button({Title="TP to End",Callback=function() S.jr_tp_end() end})

-- TUG OF WAR TAB
local TabTug=Window:Tab({Title="Tug of War",Icon="swords"})
TabTug:Section({Title="Tug of War"})
T(TabTug,{Title="Anti Miss QTE",Default=false},function(v) S.toggle_tug_of_war_auto_qte_miss(v) end)
T(TabTug,{Title="Auto Pull (OP)",Default=false},function(v) S.toggle_tug_auto_pull_op(v) end)

-- GLASS BRIDGE TAB
local TabGB=Window:Tab({Title="Glass Bridge",Icon="layers"})
TabGB:Section({Title="Utilities"})
TabGB:Button({Title="TP to End",Callback=function() S.gb_tp_end() end})
T(TabGB,{Title="AntiBreak Glass",Default=false},function(v) S.toggle_anti_break(v) end)

-- MINGLE TAB
local TabM=Window:Tab({Title="Mingle",Icon="users"})
TabM:Section({Title="Mingle"})
T(TabM,{Title="Void Kill",Default=false},function(v) S.toggle_mingle_void_kill(v) end)

-- SKYSQUID TAB
local TabSS=Window:Tab({Title="SkySquid / Squid",Icon="cloud"})
TabSS:Section({Title="SkySquid"})
T(TabSS,{Title="Auto TP on Fall",Default=false},function(v) S.toggle_auto_respawn_on_fall(v) end)
T(TabSS,{Title="Void Kill",Default=false},function(v) S.toggle_void_kill(v) end)
T(TabSS,{Title="Anti Fall",Default=false},function(v) S.toggle_sky_squid_anti_fall(v) end)
TabSS:Section({Title="Orbit Kill Aura"})
T(TabSS,{Title="Enable Orbit",Default=false},function(v) S.toggle_orbit_killaura(v) end)
TabSS:Slider({Title="Orbit Radius",Value={Min=1,Max=10,Default=3},Step=1,Callback=function(v) S.set_orbit_radius(v) end})
TabSS:Slider({Title="Orbit Speed",Value={Min=1,Max=10,Default=10},Step=1,Callback=function(v) S.set_orbit_speed(v) end})
T(TabSS,{Title="Orbit AntiHit",Default=false},function(v) S.OrbitAntiHitEnabled=v end)

-- PENTATHLON TAB
local TabPen=Window:Tab({Title="Pentathlon",Icon="trophy"})
TabPen:Section({Title="Auto Minigames"})
T(TabPen,{Title="Auto Ddakji",Default=false},function(v) S.toggle_auto_ddakji(v) end)
T(TabPen,{Title="Auto Flying Stone",Default=false},function(v) S.toggle_auto_flying_stone(v) end)
T(TabPen,{Title="Auto Gonggi",Default=false},function(v) S.toggle_auto_gonggi(v) end)
T(TabPen,{Title="Auto Spinning Top",Default=false},function(v) S.toggle_auto_spinning_top(v) end)
T(TabPen,{Title="Auto Jegi",Default=false},function(v) S.toggle_auto_jegi(v) end)

-- DALGONA TAB
local TabD=Window:Tab({Title="Dalgona",Icon="cookie"})
TabD:Section({Title="Dalgona"})
TabD:Button({Title="Anti Crack",Callback=function() S.toggle_anti_crack() end})
TabD:Button({Title="Complete Dalgona Shape",Callback=function() S.shitahhdalgonaez() end})
TabD:Button({Title="Free Lighter",Callback=function() S.dalgona_lighter() end})
T(TabD,{Title="Auto Relax Breathing",Default=false},function(v) S.toggle_dalgona_auto_relax(v) end)

-- ESP TAB
local TabESP=Window:Tab({Title="ESP",Icon="eye"})
TabESP:Section({Title="Power ESP"})
T(TabESP,{Title="Power ESP",Default=false},function(v) S.toggle_esp_powers(v) end)
TabESP:Colorpicker({Title="Power Color",Default=C.PowerESPColor,Callback=function(c) C.PowerESPColor=c end})
TabESP:Dropdown({Title="Power Font",Values={"UI","System","Plex","Monospace"},Value="Plex",Callback=function(v) C.PowerESPFont=({UI=0,System=1,Plex=2,Monospace=3})[v] or 2 end})
TabESP:Slider({Title="Power Size",Value={Min=10,Max=40,Default=16},Step=1,Callback=function(v) C.PowerESPSize=v end})
TabESP:Section({Title="Hide and Seek ESP"})
TabESP:Paragraph({Title="Seekers=red, Hiders=green, Guards=yellow"})
T(TabESP,{Title="Enable H&S ESP",Default=false},function(v) S.toggle_hns_esp(v) end)
TabESP:Colorpicker({Title="Hider Color",Default=C.HNSSafeColor,Callback=function(c) C.HNSSafeColor=c end})
TabESP:Colorpicker({Title="Seeker Color",Default=C.HNSSeekerColor,Callback=function(c) C.HNSSeekerColor=c end})
TabESP:Colorpicker({Title="Guard Color",Default=C.HNSGuardColor,Callback=function(c) C.HNSGuardColor=c end})
TabESP:Colorpicker({Title="Tracer Color",Default=C.HNSTracerColor,Callback=function(c) C.HNSTracerColor=c end})

-- REBEL TAB
local TabR=Window:Tab({Title="Rebel",Icon="shield"})
TabR:Section({Title="Rebel"})
T(TabR,{Title="Auto Become Guard",Default=false},function(v) S.toggle_auto_become_guard(v) end)
TabR:Dropdown({Title="Guard Tier",Values={"Circle","Triangle","Square"},Value="Circle",Callback=function(v) S.set_guard_tier(v) end})

-- EXTRA TAB
local TabEx=Window:Tab({Title="Extra",Icon="sparkles"})
TabEx:Section({Title="Custom Gravity"})
T(TabEx,{Title="Custom Gravity",Default=false},function(v) S.toggle_custom_gravity(v) end)
TabEx:Slider({Title="Gravity",Value={Min=50,Max=500,Default=196.2},Step=1,Callback=function(v) S.set_custom_gravity(v) end})
TabEx:Section({Title="Custom Jump Power"})
T(TabEx,{Title="Custom Jump Power",Default=false},function(v) S.toggle_custom_jump_power(v) end)
TabEx:Slider({Title="Jump Power",Value={Min=20,Max=200,Default=50},Step=1,Callback=function(v) S.set_custom_jump_power(v) end})
TabEx:Section({Title="Flight"})
T(TabEx,{Title="Enable Flight",Default=false},function(v) S.toggle_fly(v) end)
TabEx:Slider({Title="Fly Speed",Value={Min=10,Max=300,Default=50},Step=1,Callback=function(v) S.FlySpeed=v end})
TabEx:Section({Title="Custom Clothes Color"})
T(TabEx,{Title="Custom Clothes Color",Default=false},function(v) S.toggle_custom_uniform_color(v) end)
TabEx:Colorpicker({Title="Clothes Color",Default=C.ClothesColor,Callback=function(c) S.set_uniform_color(c) end})
TabEx:Section({Title="Custom Level"})
T(TabEx,{Title="Custom Level",Default=false},function(v) S.toggle_custom_level(v) end)
TabEx:Input({Title="Level Value",Value="1",Callback=function(v) S.set_custom_level(tonumber(v) or 1) end})
TabEx:Section({Title="Custom Winstreak"})
T(TabEx,{Title="Custom Winstreak",Default=false},function(v) S.toggle_custom_winstreak(v) end)
TabEx:Input({Title="Winstreak Value",Value="0",Callback=function(v) S.set_custom_winstreak(tonumber(v) or 0) end})

-- MAIN
local TabMain=Window:Tab({Title="Main",Icon="home"})
TabMain:Section({Title="Unload"})
TabMain:Button({Title="Full Unload",Icon="trash-2",Callback=function()
    S.unloaded=true
    S.clearHNSEsp()
    S.clear_esp_powers()
    pcall(function() if Window and Window.Destroy then Window:Destroy() end end)
end})

-- ================== KEYBIND N ==================
-- Метод 1: официальный API WindUI
pcall(function() Window:SetToggleKey(Enum.KeyCode.N) end)

-- Метод 2: UIS fallback (на случай если SetToggleKey не сработал)
UserInputService.InputBegan:Connect(function(input,gp)
    if gp then return end
    if input.KeyCode~=Enum.KeyCode.N then return end
    if UserInputService:GetFocusedTextBox() then return end
    pcall(function()
        if Window.Toggle then Window:Toggle()
        elseif Window.SetVisibility then
            if not S._menuVisible then S._menuVisible=true else S._menuVisible=false end
            Window:SetVisibility(S._menuVisible)
        elseif Window.Open and Window.Close then
            if S._menuOpen then S._menuOpen=false Window:Close()
            else S._menuOpen=true Window:Open() end
        end
    end)
end)

_G.XD_Cleanup=function()
    S.unloaded=true
    pcall(function() if Window and Window.Destroy then Window:Destroy() end end)
end

print("[Xionix_Dewamp v 2.1] Loaded. Auto Dodge = strict always. Menu: N")