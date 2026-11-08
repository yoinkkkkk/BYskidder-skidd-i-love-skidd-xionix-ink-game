local WindUI=loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Players=game:GetService("Players")
local Workspace=game:GetService("Workspace")
local UIS=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local HttpService=game:GetService("HttpService")
local TweenService=game:GetService("TweenService")
local SoundService=game:GetService("SoundService")
local Lighting=game:GetService("Lighting")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local InsertService=game:GetService("InsertService")
local ProximityPromptService=game:GetService("ProximityPromptService")
local LP=Players.LocalPlayer
while not LP do task.wait(0.1) LP=Players.LocalPlayer end
if not game:IsLoaded() then game.Loaded:Wait() end
local Camera=Workspace.CurrentCamera
local SCRIPT_NAME="Xionix_Dewamp"
local SCRIPT_VERSION="v 1.2"
local S={}
S.FILE=(function()
    local env=(getgenv and getgenv()) or _G
    local function pick(n)
        local g=_G[n] or rawget(_G,n)
        if g then return g end
        if env and env[n] then return env[n] end
        return nil
    end
    return {writefile=pick("writefile"),readfile=pick("readfile"),isfile=pick("isfile"),
        isfolder=pick("isfolder"),makefolder=pick("makefolder"),
        listfiles=pick("listfiles"),delfile=pick("delfile")}
end)()
S.running=true S.unloaded=false
S.conns={} S.hooks={} S.added={}
S.oneClickDalgona=false S.dalgonaConn=nil
S.cachedSlot="T" S.cachedDodgeSlot="1" S.cachedUITool=nil S.cachedDodgeTool=nil
S.lastDodgeUI=0 S.lastDodgeH=0
S.combatHooked=false S.origFiredGun=nil S.origGetBuffs=nil S.gunMod=nil
S.fovGui=nil S.fovFrame=nil S.fovStroke=nil S.fovRainbowConn=nil
S.fbInst=nil S.fogBackup=nil
S.currentConfigName="default"
S.animEnabled={}
S.handCache={} S.legCache={} S.torsoCache={} S.origTransparency={} S.handsConn=nil
S.brewLoopConn=nil
S.btAnimConn=nil S.btLastIdTime={} S.btLastShot=0
S.aimbotConn=nil S.aimbotTarget=nil S.aimbotTargetTime=0
S.morphRate={lastMorph=0,session=0,nickTimes={}}
S.morphCache={userId={},models={},modelOrder={}}
S.morph={korbloxSaved={},headSaved=nil,activeKorblox=false,activeHeadless=false,
    korbloxManual=false,headlessManual=false,
    savedMorph={shirt=0,pants=0,graphic=0,headMesh=nil},
    active=false,_busy=false,_lastNick="",_watchConn=nil,_watchDebounce=false}
S.hiddenNicks={} S.nickNameCache={} S.perCharConns={} S.watchedKeys={}
S._halloween={active=false,objects={}}
_G.__adEspDone=0 _G.__adEspTotal=0
_G.__dalgonaCache={} _G.__adWatchers={}
_G.__rlglLast=0 _G.__rlglRedStartAt=0 _G.__rlglWasRed=false
_G.__rlglLastSec=nil _G.__rlglTimerEndedAt=0 _G.__rlglLastFire=0
_G.__adUnloaded=false
do
    if getgenv and getgenv().__ui_dodge and getgenv().__ui_dodge.shutdown then
        pcall(function() getgenv().__ui_dodge.shutdown() end)
    end
    local h={}
    if gethui then pcall(function() table.insert(h,gethui()) end) end
    pcall(function() table.insert(h,game:GetService("CoreGui")) end)
    if LP then pcall(function() table.insert(h,LP:FindFirstChildOfClass("PlayerGui")) end) end
    for _,hh in ipairs(h) do
        if hh and typeof(hh)=="Instance" then
            for _,ch in ipairs(hh:GetChildren()) do
                if ch:IsA("ScreenGui") and (tostring(ch.Name):find("^XD_") or tostring(ch.Name):find("^Xionix_")) then
                    pcall(function() ch:Destroy() end)
                end
            end
        end
    end
end
local SHOT_ANIMS={
    ["rbxassetid://124637626540536"]="HK416",["rbxassetid://138748957635848"]="G3SG1",
    ["rbxassetid://96837363717592"]="Deagle",["rbxassetid://88111250846452"]="Glock 17",
    ["rbxassetid://87593987526528"]="FN Fal",["rbxassetid://76674339459544"]="MP5K",
    ["rbxassetid://122334383661670"]="M4A1",["rbxassetid://93906174064273"]="Five Seven",
    ["rbxassetid://84089564531020"]="Thompson M1A1",["rbxassetid://78301729996106"]="P90",
    ["rbxassetid://94523642657060"]="Uzi",["rbxassetid://83718615035368"]="Colt M1911",
    ["rbxassetid://129874518877211"]="MP5",
}
local SHOT_IDS={}
for k,v in pairs(SHOT_ANIMS) do SHOT_IDS[k]=v local num=k:match("%d+") if num then SHOT_IDS[num]=v end end
local function mkGrad5(a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p)
    return ColorSequence.new({
        ColorSequenceKeypoint.new(0,Color3.fromRGB(a,b,c)),
        ColorSequenceKeypoint.new(0.25,Color3.fromRGB(d,e,f)),
        ColorSequenceKeypoint.new(0.5,Color3.fromRGB(g,h,i)),
        ColorSequenceKeypoint.new(0.75,Color3.fromRGB(j,k,l)),
        ColorSequenceKeypoint.new(1,Color3.fromRGB(m,n,o)),
    })
end
local C={
    Enabled=false,Distance=18,Delay=0,MinInterval=0.02,AnimWatch=0.4,WatchAfter=0.3,
    RadiusVis=false,RadiusTransparency=0.55,RadiusR=255,RadiusG=70,RadiusB=160,
    GuardESP=false,GuardESP_HP=true,GuardESP_Name=true,GuardESP_Tool=true,GuardESP_ForceAll=false,
    GuardESP_Highlight=true,GuardESP_Tracer=false,GuardESP_Box=false,
    GuardESP_HPBarThickness=8,GuardESP_HPBarLength=1.5,GuardESP_HPBarRoundness=3,
    GuardESP_ColorR=255,GuardESP_ColorG=50,GuardESP_ColorB=50,
    GuardESP_TracerR=255,GuardESP_TracerG=50,GuardESP_TracerB=50,
    GuardESP_BoxR=255,GuardESP_BoxG=50,GuardESP_BoxB=50,
    GuardESP_BoxThickness=2,GuardESP_NameSize=17,
    GuardESP_Distance=false,GuardESP_MaxDist=500,
    GuardESP_HP_TopR=80,GuardESP_HP_TopG=255,GuardESP_HP_TopB=80,
    GuardESP_HP_M1R=180,GuardESP_HP_M1G=255,GuardESP_HP_M1B=60,
    GuardESP_HP_M2R=255,GuardESP_HP_M2G=200,GuardESP_HP_M2B=40,
    GuardESP_HP_M3R=255,GuardESP_HP_M3G=120,GuardESP_HP_M3B=60,
    GuardESP_HP_BotR=255,GuardESP_HP_BotG=40,GuardESP_HP_BotB=40,
    GuardESP_HP_State1_R=74,GuardESP_HP_State1_G=222,GuardESP_HP_State1_B=74,
    GuardESP_HP_State2_R=255,GuardESP_HP_State2_G=210,GuardESP_HP_State2_B=60,
    GuardESP_HP_State3_R=255,GuardESP_HP_State3_G=130,GuardESP_HP_State3_B=40,
    GuardESP_HP_State4_R=255,GuardESP_HP_State4_G=55,GuardESP_HP_State4_B=55,
    GuardESP_HP_Outline=false,GuardESP_HP_ChipBg=true,
    PlayerESP=false,PlayerESP_HP=true,PlayerESP_Name=true,PlayerESP_Tool=true,
    PlayerESP_Highlight=true,PlayerESP_Tracer=false,PlayerESP_Box=false,
    PlayerESP_HPBarThickness=8,PlayerESP_HPBarLength=1.5,PlayerESP_HPBarRoundness=3,
    PlayerESP_ColorR=80,PlayerESP_ColorG=255,PlayerESP_ColorB=120,
    PlayerESP_TracerR=80,PlayerESP_TracerG=255,PlayerESP_TracerB=120,
    PlayerESP_BoxR=80,PlayerESP_BoxG=255,PlayerESP_BoxB=120,
    PlayerESP_BoxThickness=2,PlayerESP_NameSize=17,
    PlayerESP_Distance=false,PlayerESP_MaxDist=500,
    PlayerESP_HP_TopR=80,PlayerESP_HP_TopG=255,PlayerESP_HP_TopB=80,
    PlayerESP_HP_M1R=180,PlayerESP_HP_M1G=255,PlayerESP_HP_M1B=60,
    PlayerESP_HP_M2R=255,PlayerESP_HP_M2G=200,PlayerESP_HP_M2B=40,
    PlayerESP_HP_M3R=255,PlayerESP_HP_M3G=120,PlayerESP_HP_M3B=60,
    PlayerESP_HP_BotR=255,PlayerESP_HP_BotG=40,PlayerESP_HP_BotB=40,
    PlayerESP_HP_State1_R=74,PlayerESP_HP_State1_G=222,PlayerESP_HP_State1_B=74,
    PlayerESP_HP_State2_R=255,PlayerESP_HP_State2_G=210,PlayerESP_HP_State2_B=60,
    PlayerESP_HP_State3_R=255,PlayerESP_HP_State3_G=130,PlayerESP_HP_State3_B=40,
    PlayerESP_HP_State4_R=255,PlayerESP_HP_State4_G=55,PlayerESP_HP_State4_B=55,
    PlayerESP_HP_Outline=false,PlayerESP_HP_ChipBg=true,
    PlayerESP_CustomName="",PlayerESP_NameRainbow=false,PlayerESP_NameRainbowSpeed=1.0,
    InstantInteract=false,
    MenuKey=Enum.KeyCode.N,
    RemoveLegs=false,RemoveHands=false,RemoveTorso=false,Headless=false,Korblox=false,
    HideNick=false,HideOtherNames=false,FullBright=false,FullBrightIntensity=0.3,RemoveFog=false,
    ESP_FontIdx=1,
    FOVRainbow=false,FOVRainbowMode=1,FOVUseCustom=false,FOVCustomIdx=1,
    FOVCustomR1=255,FOVCustomG1=60,FOVCustomB1=60,FOVCustomR2=60,FOVCustomG2=255,FOVCustomB2=60,
    FOVCustomR3=60,FOVCustomG3=140,FOVCustomB3=255,FOVCustomR4=255,FOVCustomG4=255,FOVCustomB4=60,
    FOVCustomR5=255,FOVCustomG5=60,FOVCustomB5=255,FOVCustomR6=60,FOVCustomG6=255,FOVCustomB6=255,
    FOVCustomR7=255,FOVCustomG7=180,FOVCustomB7=60,FOVCustomR8=255,FOVCustomG8=255,FOVCustomB8=255,
    FOVCustomR9=180,FOVCustomG9=60,FOVCustomB9=255,
    AutoBrew=false,AutoBrewSlot="E",AutoBrewInterval=1,AutoBrewBrewDelay=1.8,
    BulletTracer=false,
    BulletTracerR=255,BulletTracerG=147,BulletTracerB=255,
    BulletTracerThickness=0.20,BulletTracerSpeed=800,BulletTracerLifetime=2.00,
    BulletTracerRange=1050,BulletTracerStartOffset=0.30,BulletTracerEndOffset=0.00,
    BulletTracerOpacity=0.00,BulletTracerGlow=true,BulletTracerWhiteCore=true,
    BulletTracerFadeIdx=1,BulletTracerCooldown=0.03,
    ManualUISlot="",ManualHnSSlot="",
    GuiR=200,GuiG=60,GuiB=255,
    AnimSpeed=false,AnimSpeedValue=2.5,
    RLGL_AutoDodge=false,RLGL_OnlyRedLight=true,
    RLGL_MinInterval=0.75,RLGL_RedDelay=0.55,RLGL_VelThreshold=0.1,
    RLGL_TimerEndDodge=true,RLGL_TimerEndDelay=12,RLGL_TimerEndInterval=0.75,RLGL_TimerEndMaxDuration=9,
    RebelSilentAim=false,RebelSilentAimVisibleCheck=false,
    RebelNoRecoil=false,
    RebelAimbot=false,RebelAimbotHoldKey=false,RebelAimbotSmooth=1.0,RebelAimbotTargetGuards=true,
    RebelAimbotVisibleCheck=false,
    RebelFOV=250,RebelFOVCircle=false,RebelFOVNeon=true,RebelFOVBlackOutline=true,
    RebelFOV_OutlineThickness=5,RebelFOV_OutlineR=0,RebelFOV_OutlineG=0,RebelFOV_OutlineB=0,
    RebelFOVCircleWidth=1.6,RebelFOVBlendSpeed=0.5,
    RebelFOVR=255,RebelFOVG=60,RebelFOVB=60,
    RebelTargetPlayers=true,RebelTargetNPCs=true,
    RebelBodyHead=true,RebelBodyTorso=true,RebelBodyHRP=false,
    RebelBodyLeftArm=false,RebelBodyRightArm=false,RebelBodyLeftLeg=false,RebelBodyRightLeg=false,
    InfJump=false,Noclip=false,
    Halloween_Chams=false,Halloween_Tracers=false,Halloween_Boxes=false,Halloween_Names=false,Halloween_Dist=false,
    Halloween_ChamsR=170,Halloween_ChamsG=0,Halloween_ChamsB=255,
    Halloween_ChamsOutlineR=255,Halloween_ChamsOutlineG=255,Halloween_ChamsOutlineB=255,
    Halloween_ChamsOutlineTransparency=0,
    Halloween_TracerR=170,Halloween_TracerG=0,Halloween_TracerB=255,
    Halloween_BoxR=170,Halloween_BoxG=0,Halloween_BoxB=255,
    Halloween_TextR=220,Halloween_TextG=150,Halloween_TextB=255,
    Halloween_TracerThick=1,Halloween_BoxThick=1,Halloween_TextSize=14,Halloween_BoxScale=1,
    Halloween_RainbowChams=false,Halloween_RainbowTracers=false,
    Halloween_RainbowBoxes=false,Halloween_RainbowText=false,
    Halloween_MinD=0,Halloween_MaxD=5000,
}
local H={Enabled=false,Distance=18,Delay=0,MinInterval=0.02,AnimWatch=0.4,WatchAfter=0.3,
    RadiusVis=false,RadiusTransparency=0.55,RadiusR=70,RadiusG=210,RadiusB=255,StrictMode=true}
local ESP_FONT_NAMES={"GothamBlack","GothamBold","Gotham","Code","Arial","ArialBold",
    "SourceSans","SourceSansBold","SciFi","Fantasy","Roboto","RobotoMono","Ubuntu","Oswald",
    "Nunito","Bodoni","Cartoon","IndieFlower","PatrickHand","Antique","Garamond","Highway",
    "Legacy","PermanentMarker","Sarpanch","SpecialElite","Michroma"}
local function espFont()
    local idx=math.clamp(C.ESP_FontIdx or 1,1,#ESP_FONT_NAMES)
    local f=Enum.Font[ESP_FONT_NAMES[idx]]
    if not f then f=Enum.Font.GothamBlack end
    return f
end
local function guardChipColor(ratio)
    local r,g,b
    if ratio>0.75 then r,g,b=C.GuardESP_HP_State1_R,C.GuardESP_HP_State1_G,C.GuardESP_HP_State1_B
    elseif ratio>0.5 then r,g,b=C.GuardESP_HP_State2_R,C.GuardESP_HP_State2_G,C.GuardESP_HP_State2_B
    elseif ratio>0.25 then r,g,b=C.GuardESP_HP_State3_R,C.GuardESP_HP_State3_G,C.GuardESP_HP_State3_B
    else r,g,b=C.GuardESP_HP_State4_R,C.GuardESP_HP_State4_G,C.GuardESP_HP_State4_B end
    return Color3.fromRGB(r,g,b)
end
local function playerChipColor(ratio)
    local r,g,b
    if ratio>0.75 then r,g,b=C.PlayerESP_HP_State1_R,C.PlayerESP_HP_State1_G,C.PlayerESP_HP_State1_B
    elseif ratio>0.5 then r,g,b=C.PlayerESP_HP_State2_R,C.PlayerESP_HP_State2_G,C.PlayerESP_HP_State2_B
    elseif ratio>0.25 then r,g,b=C.PlayerESP_HP_State3_R,C.PlayerESP_HP_State3_G,C.PlayerESP_HP_State3_B
    else r,g,b=C.PlayerESP_HP_State4_R,C.PlayerESP_HP_State4_G,C.PlayerESP_HP_State4_B end
    return Color3.fromRGB(r,g,b)
end
local function track(c) if not c then return c end if S.unloaded then pcall(function() c:Disconnect() end) return c end table.insert(S.conns,c) return c end
local function uiRadiusColor() return Color3.fromRGB(C.RadiusR or 255,C.RadiusG or 70,C.RadiusB or 160) end
local function hnsRadiusColor() return Color3.fromRGB(H.RadiusR or 70,H.RadiusG or 210,H.RadiusB or 255) end
local function customFOVColor(idx)
    local i=math.clamp(idx,1,9)
    if i==1 then return Color3.fromRGB(C.FOVCustomR1,C.FOVCustomG1,C.FOVCustomB1)
    elseif i==2 then return Color3.fromRGB(C.FOVCustomR2,C.FOVCustomG2,C.FOVCustomB2)
    elseif i==3 then return Color3.fromRGB(C.FOVCustomR3,C.FOVCustomG3,C.FOVCustomB3)
    elseif i==4 then return Color3.fromRGB(C.FOVCustomR4,C.FOVCustomG4,C.FOVCustomB4)
    elseif i==5 then return Color3.fromRGB(C.FOVCustomR5,C.FOVCustomG5,C.FOVCustomB5)
    elseif i==6 then return Color3.fromRGB(C.FOVCustomR6,C.FOVCustomG6,C.FOVCustomB6)
    elseif i==7 then return Color3.fromRGB(C.FOVCustomR7,C.FOVCustomG7,C.FOVCustomB7)
    elseif i==8 then return Color3.fromRGB(C.FOVCustomR8,C.FOVCustomG8,C.FOVCustomB8)
    else return Color3.fromRGB(C.FOVCustomR9,C.FOVCustomG9,C.FOVCustomB9) end
end
local function rebelFOVColor() if C.FOVUseCustom then return customFOVColor(C.FOVCustomIdx or 1) end return Color3.fromRGB(C.RebelFOVR,C.RebelFOVG,C.RebelFOVB) end
local function rebelOutlineColor() return Color3.fromRGB(C.RebelFOV_OutlineR,C.RebelFOV_OutlineG,C.RebelFOV_OutlineB) end
local function guardESPColor() return Color3.fromRGB(C.GuardESP_ColorR,C.GuardESP_ColorG,C.GuardESP_ColorB) end
local function playerESPColor() return Color3.fromRGB(C.PlayerESP_ColorR,C.PlayerESP_ColorG,C.PlayerESP_ColorB) end
local function guardTracerColor() return Color3.fromRGB(C.GuardESP_TracerR,C.GuardESP_TracerG,C.GuardESP_TracerB) end
local function playerTracerColor() return Color3.fromRGB(C.PlayerESP_TracerR,C.PlayerESP_TracerG,C.PlayerESP_TracerB) end
local function guardBoxColor() return Color3.fromRGB(C.GuardESP_BoxR,C.GuardESP_BoxG,C.GuardESP_BoxB) end
local function playerBoxColor() return Color3.fromRGB(C.PlayerESP_BoxR,C.PlayerESP_BoxG,C.PlayerESP_BoxB) end
local function guardHPGrad()
    return mkGrad5(C.GuardESP_HP_TopR,C.GuardESP_HP_TopG,C.GuardESP_HP_TopB,
        C.GuardESP_HP_M1R,C.GuardESP_HP_M1G,C.GuardESP_HP_M1B,
        C.GuardESP_HP_M2R,C.GuardESP_HP_M2G,C.GuardESP_HP_M2B,
        C.GuardESP_HP_M3R,C.GuardESP_HP_M3G,C.GuardESP_HP_M3B,
        C.GuardESP_HP_BotR,C.GuardESP_HP_BotG,C.GuardESP_HP_BotB)
end
local function playerHPGrad()
    return mkGrad5(C.PlayerESP_HP_TopR,C.PlayerESP_HP_TopG,C.PlayerESP_HP_TopB,
        C.PlayerESP_HP_M1R,C.PlayerESP_HP_M1G,C.PlayerESP_HP_M1B,
        C.PlayerESP_HP_M2R,C.PlayerESP_HP_M2G,C.PlayerESP_HP_M2B,
        C.PlayerESP_HP_M3R,C.PlayerESP_HP_M3G,C.PlayerESP_HP_M3B,
        C.PlayerESP_HP_BotR,C.PlayerESP_HP_BotG,C.PlayerESP_HP_BotB)
end
local function randStr(n) local s="" for _=1,n do s=s..string.char(math.random(97,122)) end return s end
local function addCorner(o,r) local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,r or 8) c.Parent=o return c end
local function ensureTracerGui()
    if S.tracerGui and S.tracerGui.Parent then return end
    S.tracerGui=Instance.new("ScreenGui") S.tracerGui.Name="Xionix_Tr_"..randStr(6)
    S.tracerGui.IgnoreGuiInset=true S.tracerGui.ResetOnSpawn=false S.tracerGui.DisplayOrder=99990
    local ph=nil if gethui then local ok,h=pcall(gethui); if ok and h and typeof(h)=="Instance" then ph=h end end
    if not ph then ph=LP:FindFirstChildOfClass("PlayerGui") end
    if not ph then ph=game:GetService("CoreGui") end
    pcall(function() S.tracerGui.Parent=ph end)
    if not S.tracerGui.Parent then pcall(function() S.tracerGui.Parent=game:GetService("CoreGui") end) end
end
local function ensureOverlayGui()
    if S.overlayGui and S.overlayGui.Parent then return end
    S.overlayGui=Instance.new("ScreenGui") S.overlayGui.Name="Xionix_Ov_"..randStr(6)
    S.overlayGui.IgnoreGuiInset=true S.overlayGui.ResetOnSpawn=false S.overlayGui.DisplayOrder=99985
    local ph=nil if gethui then local ok,h=pcall(gethui); if ok and h and typeof(h)=="Instance" then ph=h end end
    if not ph then ph=LP:FindFirstChildOfClass("PlayerGui") end
    if not ph then ph=game:GetService("CoreGui") end
    pcall(function() S.overlayGui.Parent=ph end)
    if not S.overlayGui.Parent then pcall(function() S.overlayGui.Parent=game:GetService("CoreGui") end) end
end
local function normName(s) return string.lower(tostring(s or "")):gsub("[%s%-_%.]","") end
local function findBodyPart(model,name)
    if not model or not name then return nil end
    local d=model:FindFirstChild(name) if d and d:IsA("BasePart") then return d end
    local t=normName(name)
    for _,ch in ipairs(model:GetChildren()) do if ch:IsA("BasePart") and normName(ch.Name)==t then return ch end end
    for _,ch in ipairs(model:GetDescendants()) do if ch:IsA("BasePart") and ch.Parent~=nil and normName(ch.Name)==t then return ch end end
    return nil
end
local function getCharScreenBounds(char,cam)
    if not char or not cam then return nil end
    local a,b=math.huge,math.huge local c,d=-math.huge,-math.huge local any=false
    for _,p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            local sp,onScreen=cam:WorldToViewportPoint(p.Position)
            if onScreen then any=true
                if sp.X<a then a=sp.X end if sp.Y<b then b=sp.Y end
                if sp.X>c then c=sp.X end if sp.Y>d then d=sp.Y end
            end
        end
    end
    if not any then return nil end
    return a,b,c,d
end
local HIT_LIST={"76323709902827","132207921464999","72649558888714","84036894358514","103062305177426","79649041083405","73242877658272","121147456137931","105341857343164","116839849594540","96924216250322","85793691404836","86197206792061","104041807075625","114928327045353","135690448001690","103355259844069","128452090955120","71000246338579","125906547773381","107989020363293","85623602463927","87978085217719","112950478995075","94443309383954","81766558426599","90654171377736","72128148665361","94960826047243","114769224376981","92844369847738","106908462496291","109822392402606","119784367902126","89439896387299","132070051408308","131235569946744","123834203617100","98785078701251","103318207627541","99844967459345","101703309225906","97863204720378","137824029524579","87041753984253","81533666958052","79549040943367","81392013026663","77595339119545","75611037033634","123370871049938","106756593687295","128733894961951","137659772694747","93105538774923","129324788590686","134675465964672","85285032162865","125283605050829","93373403484012","108262048142532","106370995610424","114617637295467","115386570583557","70775136168849","72557176302052","94215646393565","73150160715773","7052329948932","9915750592076","85743982894847","82579449181823","114687917628569","9915750926076","99157505926076"}
local BAN_LIST={"84075526494569","112693580156198","116089915329773","123441836092792","76593886937703","71214385249268","91345240826151","107476375951001","97049872073368","73421886855742","140302976506103","108126144370302","115836393562566","102891247801142","73748962069265","88654124229687","12214474272195"}
local HIT_DELAY={["131235569946744"]=0.9,["114687917628569"]=3.4,["115386570583557"]=0.6,["70775136168849"]=0.7,["132207921464999"]=0.4}
local HIT,BAN={},{}
for i=1,#HIT_LIST do HIT[HIT_LIST[i]]=true S.animEnabled[HIT_LIST[i]]=true end
for i=1,#BAN_LIST do BAN[BAN_LIST[i]]=true S.animEnabled[BAN_LIST[i]]=false end
local SPECIAL_FORCE={["power hold"]=true,["powerhold"]=true,["power_hold"]=true,["pocket sand"]=true,["pocketsand"]=true,["pocket_sand"]=true,["sand"]=true}
local function isHit(id)
    if not id then return false end
    local n=tostring(id):match("%d+") if not n then return false end
    if BAN[n] then return false end
    if HIT[n] then return S.animEnabled[n]~=false end
    for k in pairs(HIT) do if S.animEnabled[k]~=false and not BAN[k] and (n:find(k,1,true) or k:find(n,1,true)) then return true end end
    return false
end
local function getToolRawName(char)
    if not char then return "" end
    for _,c in ipairs(char:GetChildren()) do if c:IsA("Tool") then return c.Name end end
    local hum=char:FindFirstChildOfClass("Humanoid")
    if hum then for _,c in ipairs(hum:GetChildren()) do if c:IsA("Tool") then return c.Name end end end
    local hw=char:GetAttribute("HoldingWeapon")
    if type(hw)=="string" and hw~="" then local t=char:FindFirstChild(hw) if t then return t.Name end return hw end
    return ""
end
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
local function isDodgeTool(tool)
    if not tool or not tool:IsA("Tool") then return false end
    local n=string.lower(tool.Name)
    if n:find("ultra",1,true) or n:find("instinct",1,true) then return false end
    return n:find("dodge",1,true)~=nil
end
local KEYMAP={["1"]=0x31,["2"]=0x32,["3"]=0x33,["4"]=0x34,["5"]=0x35,["6"]=0x36,["7"]=0x37,["8"]=0x38,["9"]=0x39,["0"]=0x30,e=0x45,t=0x54,y=0x59,r=0x52,f=0x46,q=0x51,g=0x47,space=0x20}
local VALID={["1"]=1,["2"]=1,["3"]=1,["4"]=1,["5"]=1,["6"]=1,["7"]=1,["8"]=1,["9"]=1,["0"]=1,E=1,T=1,Y=1,Q=1,F=1,R=1,G=1}
local hasNativePress=(type(keypress)=="function" and type(keyrelease)=="function")
local function getPlayerFireOrigin()
    local char=LP.Character
    if not char then local cam=Workspace.CurrentCamera return cam and cam.CFrame.Position or Vector3.zero end
    local attr=char:GetAttribute("HoldingWeapon")
    if type(attr)=="string" and attr~="" then
        local w=char:FindFirstChild(attr)
        if w then
            local ff=w:FindFirstChild("FireFrom") if ff and ff:IsA("BasePart") then return ff.Position end
            local hd=w:FindFirstChild("Handle") if hd and hd:IsA("BasePart") then return hd.Position end
        end
    end
    for _,c in ipairs(char:GetChildren()) do
        if c:IsA("Tool") then
            local ff=c:FindFirstChild("FireFrom") if ff and ff:IsA("BasePart") then return ff.Position end
            local hd=c:FindFirstChild("Handle") if hd and hd:IsA("BasePart") then return hd.Position end
        end
    end
    local head=char:FindFirstChild("Head") if head then return head.Position end
    local hrp=char:FindFirstChild("HumanoidRootPart") if hrp then return hrp.Position end
    for _,c in ipairs(char:GetDescendants()) do if c:IsA("BasePart") then return c.Position end end
    return Vector3.zero
end
local function isTargetVisible(targetChar)
    if not targetChar or not targetChar.Parent then return false end
    local fromPos=getPlayerFireOrigin() if not fromPos then return false end
    local parts={}
    local head=targetChar:FindFirstChild("Head") if head then table.insert(parts,head) end
    local torso=targetChar:FindFirstChild("UpperTorso") or targetChar:FindFirstChild("Torso") if torso then table.insert(parts,torso) end
    local hrp=targetChar:FindFirstChild("HumanoidRootPart") if hrp then table.insert(parts,hrp) end
    if #parts==0 then return false end
    local rp=RaycastParams.new() rp.FilterType=Enum.RaycastFilterType.Exclude rp.FilterDescendantsInstances={LP.Character}
    for _,part in ipairs(parts) do
        if part.Position then
            local dir=part.Position-fromPos
            if dir.Magnitude>0.01 then
                local hit=Workspace:Raycast(fromPos,dir,rp)
                if hit then local hInst=hit.Instance if hInst==part or hInst:IsDescendantOf(targetChar) then return true end end
            end
        end
    end
    return false
end
local function findBrewInInventory()
    local function scan(c)
        if not c then return nil end
        for _,cc in ipairs(c:GetChildren()) do if cc:IsA("Tool") and string.lower(cc.Name):find("brew") then return cc end end
        return nil
    end
    return scan(LP.Character) or scan(LP:FindFirstChild("Backpack"))
end
local DRINK_WORDS={"drink","iron brew","rush soda","twin shot","rapid reload","focus tonic","brew","soda","tonic","shot","reload"}
local function isDrinkPrompt(p)
    if not p or not p:IsA("ProximityPrompt") then return false end
    local ok1,at=pcall(function() return string.lower(tostring(p.ActionText or "")) end)
    local ok2,ot=pcall(function() return string.lower(tostring(p.ObjectText or "")) end)
    if not ok1 or not ok2 then return false end
    for _,kw in ipairs(DRINK_WORDS) do if at:find(kw,1,true) or ot:find(kw,1,true) then return true end end
    return false
end
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
    local cam=Workspace.CurrentCamera
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
local function inferSlotFor(toolObj,fallback,manual)
    if manual and manual~="" then local up=string.upper(tostring(manual)) if VALID[up] then return up end end
    return fallback
end
local function isUIToolName(name)
    local n=string.lower(tostring(name or ""))
    return n:find("ultra",1,true)~=nil or n:find("instinct",1,true)~=nil
end
local function findUITool()
    local function scan(c)
        if not c then return nil end
        for _,cc in ipairs(c:GetChildren()) do if cc:IsA("Tool") and isUIToolName(cc.Name) then return cc end end
        return nil
    end
    return scan(LP.Character) or scan(LP:FindFirstChild("Backpack"))
end
local function findDodgeTool()
    local function scan(c)
        if not c then return nil end
        for _,cc in ipairs(c:GetChildren()) do if isDodgeTool(cc) then return cc end end
        return nil
    end
    return scan(LP.Character) or scan(LP:FindFirstChild("Backpack"))
end
local function fireUI()
    if S.unloaded or not C.Enabled then return end
    local now=tick() if now-S.lastDodgeUI<(C.MinInterval or 0.02) then return end
    S.lastDodgeUI=now local slot=S.cachedSlot or "T" local pre=C.Delay or 0
    if pre>0 then task.delay(pre,function() if not S.unloaded and C.Enabled then press(slot) end end)
    else press(slot) end
end
local function fireH()
    if S.unloaded or not H.Enabled then return end
    local now=tick() if now-S.lastDodgeH<(H.MinInterval or 0.02) then return end
    S.lastDodgeH=now local tool=S.cachedDodgeTool or findDodgeTool() local slot=S.cachedDodgeSlot or "1" local pre=H.Delay or 0
    local function doFire()
        if S.unloaded or not H.Enabled then return end
        local char=LP.Character local hum=char and char:FindFirstChildOfClass("Humanoid")
        if tool and hum then
            press(slot) task.wait(0.06)
            if tool.Parent~=char then pcall(function() hum:EquipTool(tool) end) task.wait(0.06) end
            pcall(function() tool:Activate() end)
            task.wait(0.02) mouseClick() task.wait(0.04) mouseClick()
        else press(slot) task.wait(0.05) mouseClick() end
    end
    if pre>0 then task.delay(pre,doFire) else doFire() end
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
local function unhook()
    for _,c in pairs(S.hooks) do pcall(function() c:Disconnect() end) end
    table.clear(S.hooks)
end
local function anyOn() return C.Enabled or H.Enabled end
local function considerAttack(tr,hrp,force)
    if S.unloaded or not anyOn() then return end
    if not hrp or not hrp.Parent then return end
    local w=_G.__adWatchers[hrp] if not w then w={c=0} _G.__adWatchers[hrp]=w end
    if w.c>=3 then return end w.c=w.c+1
    local extra=force and 8 or 0
    local firedC=false local firedH=false local allowH=false
    if H.Enabled then
        if force then allowH=true
        elseif tr and tr.Animation and isHit(tr.Animation.AnimationId) then allowH=true end
    end
    local animDelay=0
    if tr and tr.Animation and not force then
        local aid=tostring(tr.Animation.AnimationId):match("%d+")
        if aid and HIT_DELAY[aid] then animDelay=HIT_DELAY[aid] end
    end
    local animLen=0
    if tr then local ok,l=pcall(function() return tr.Length end) if ok and tonumber(l) and l>0 then animLen=l end end
    if not C.Enabled then firedC=true end
    if not H.Enabled or not allowH then firedH=true end
    if firedC and firedH then w.c=w.c-1 if w.c<=0 then _G.__adWatchers[hrp]=nil end return end
    local t0=tick()
    local baseC=math.max(C.AnimWatch or 0.4,animLen+(C.WatchAfter or 0.3))
    local baseH=math.max(H.AnimWatch or 0.4,animLen+(H.WatchAfter or 0.3))
    local maxWatch=math.max(baseC+animDelay,baseH+animDelay)
    local conn
    local function finish() if conn then pcall(function() conn:Disconnect() end) conn=nil end w.c=w.c-1 if w.c<=0 then _G.__adWatchers[hrp]=nil end end
    local function check()
        if S.unloaded or (firedC and firedH) then finish() return end
        if tick()-t0>maxWatch then finish() return end
        local my=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not my or not hrp or not hrp.Parent then finish() return end
        local el=tick()-t0
        local distC=C.Distance or 18 local distH=H.Distance or 18
        local v=hrp.AssemblyLinearVelocity local spd=math.sqrt(v.X*v.X+v.Z*v.Z)
        if spd>15 then
            local dx=my.Position.X-hrp.Position.X local dz=my.Position.Z-hrp.Position.Z
            local dist=math.sqrt(dx*dx+dz*dz)
            if dist>0.5 then
                local dot=(v.X*dx+v.Z*dz)/(dist*spd)
                if dot>0.5 then local reach=spd*0.2 distC=distC+reach distH=distH+reach end
            end
        end
        if C.Enabled and not firedC and el>=animDelay then
            if inRange(my,hrp,distC,extra) then firedC=true fireUI() end
        end
        if H.Enabled and allowH and not firedH and el>=animDelay then
            if inRange(my,hrp,distH,extra) then firedH=true fireH() end
        end
        if firedC and firedH then finish() end
    end
    conn=RunService.Heartbeat:Connect(check)
end
local function hookTool(tool,hrp)
    if not tool or S.hooks[tool] then return end
    S.hooks[tool]=tool.Activated:Connect(function()
        if S.unloaded or not anyOn() then return end
        if isSpecialForce(hrp.Parent) then considerAttack(nil,hrp,true) end
    end)
end
local function hookAnim(an,hrp)
    if S.hooks[an] or S.unloaded then return end
    S.hooks[an]=an.AnimationPlayed:Connect(function(tr)
        if S.unloaded or not anyOn() then return end
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
        local c c=hum.ChildAdded:Connect(function(ch) if ch:IsA("Animator") then hookAnim(ch,hrp) pcall(function() c:Disconnect() end) end end)
        table.insert(S.hooks,c)
    end
    for _,t in ipairs(char:GetChildren()) do if t:IsA("Tool") then hookTool(t,hrp) end end
    local ac ac=char.ChildAdded:Connect(function(ch) if ch:IsA("Tool") then hookTool(ch,hrp) end end)
    table.insert(S.hooks,ac)
end
local function startHooks()
    if S.unloaded then return end
    unhook()
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=LP then
            if plr.Character then hookChar(plr.Character) end
            if not S.added[plr] then
                S.added[plr]=plr.CharacterAdded:Connect(function(ch) if anyOn() and not S.unloaded then task.wait(0.15) hookChar(ch) end end)
            end
        end
    end
    if not S.added._j then
        S.added._j=Players.PlayerAdded:Connect(function(plr)
            if S.unloaded then return end
            S.added[plr]=plr.CharacterAdded:Connect(function(ch) if anyOn() and not S.unloaded then task.wait(0.15) hookChar(ch) end end)
        end)
    end
    if not S.added._r then
        S.added._r=Players.PlayerRemoving:Connect(function(plr) if S.added[plr] then pcall(function() S.added[plr]:Disconnect() end) S.added[plr]=nil end end)
    end
end
local function syncHooks() if anyOn() then startHooks() else unhook() end end
local function getRandomBodyPart(char)
    if not char then return nil end
    local parts={}
    local function tryAdd(list) for _,n in ipairs(list) do local p=findBodyPart(char,n) if p then table.insert(parts,p) return end end end
    if C.RebelBodyHead then tryAdd({"Head"}) end
    if C.RebelBodyTorso then tryAdd({"Torso","UpperTorso","LowerTorso"}) end
    if C.RebelBodyHRP then tryAdd({"HumanoidRootPart"}) end
    if C.RebelBodyLeftArm then tryAdd({"Left Arm","LeftUpperArm","LeftLowerArm"}) end
    if C.RebelBodyRightArm then tryAdd({"Right Arm","RightUpperArm","RightLowerArm"}) end
    if C.RebelBodyLeftLeg then tryAdd({"Left Leg","LeftUpperLeg","LeftLowerLeg"}) end
    if C.RebelBodyRightLeg then tryAdd({"Right Leg","RightUpperLeg","RightLowerLeg"}) end
    if #parts==0 then return char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart") end
    return parts[math.random(1,#parts)]
end
local function isPartInFOV(part)
    if not part then return false end
    if (C.RebelFOV or 0)<=0 then return true end
    local cam=Workspace.CurrentCamera if not cam then return false end
    local sp,onScreen=cam:WorldToViewportPoint(part.Position) if not onScreen then return false end
    local cx=cam.ViewportSize.X/2 local cy=cam.ViewportSize.Y/2
    local dx=sp.X-cx local dy=sp.Y-cy
    return math.sqrt(dx*dx+dy*dy)<=C.RebelFOV
end
local function isCharValidTarget(char)
    if not char or char==LP.Character or not char.Parent then return false end
    if not char:IsA("Model") then return false end
    local hum=char:FindFirstChildOfClass("Humanoid") if not hum or hum.Health<=0 then return false end
    local hrp=char:FindFirstChild("HumanoidRootPart") if not hrp then return false end
    local iAmGuard=LP:GetAttribute("IsGuard")==true
    local targetPlayer=Players:GetPlayerFromCharacter(char)
    if iAmGuard then
        local ck=char:FindFirstChild("GuardCanKill") or hrp:FindFirstChild("GuardCanKillLockOn") or hrp:FindFirstChild("GuardCanKillLockOut")
        if ck then return true end
        if C.RebelTargetPlayers and targetPlayer and targetPlayer~=LP and targetPlayer:GetAttribute("IsGuard")~=true then return true end
    else
        if C.RebelTargetPlayers and targetPlayer and targetPlayer~=LP and targetPlayer:GetAttribute("IsGuard")==true then return true end
        if C.RebelTargetNPCs then
            if char.Name:match("Guard") then return true end
            if char:FindFirstChild("TypeOfGuard") then return true end
            local ck=char:FindFirstChild("GuardCanKill") or hrp:FindFirstChild("GuardCanKillLockOut") or hrp:FindFirstChild("GuardCanKillLockOn")
            if ck then return true end
        end
    end
    return false
end
local function findSilentAimTarget()
    local cam=Workspace.CurrentCamera if not cam then return nil end
    local cx=cam.ViewportSize.X/2 local cy=cam.ViewportSize.Y/2
    local bestPart,bestDist=nil,math.huge local seen={}
    local function consider(char)
        if not char or seen[char] then return end
        seen[char]=true
        if not isCharValidTarget(char) then return end
        if C.RebelSilentAimVisibleCheck and not isTargetVisible(char) then return end
        local part=getRandomBodyPart(char) if not part or not isPartInFOV(part) then return end
        local sp,onScreen=cam:WorldToViewportPoint(part.Position) if not onScreen then return end
        local dx=sp.X-cx local dy=sp.Y-cy local d=math.sqrt(dx*dx+dy*dy)
        if d<bestDist then bestDist=d bestPart=part end
    end
    local live=Workspace:FindFirstChild("Live")
    if live then for _,ch in ipairs(live:GetChildren()) do if ch:IsA("Model") then consider(ch) end end end
    local chars=Workspace:FindFirstChild("Characters")
    if chars then for _,ch in ipairs(chars:GetChildren()) do if ch:IsA("Model") then consider(ch) end end end
    for _,plr in ipairs(Players:GetPlayers()) do if plr~=LP and plr.Character then consider(plr.Character) end end
    return bestPart
end
local function hookCombat()
    if S.combatHooked then if S.gunMod and S.gunMod.FiredGun~=S.origFiredGun then return end end
    local rs=ReplicatedStorage local modules=rs:FindFirstChild("Modules")
    if not modules then pcall(function() modules=rs:WaitForChild("Modules",2) end) end
    if not modules then return end
    local gf=modules:FindFirstChild("GunFunctions")
    if not gf then pcall(function() gf=modules:WaitForChild("GunFunctions",2) end) end
    if not gf then return end
    local ok,mod=pcall(require,gf) if not ok or not mod or type(mod)~="table" then return end
    S.gunMod=mod
    if not S.origFiredGun then S.origFiredGun=mod.FiredGun end
    if not S.origGetBuffs then S.origGetBuffs=mod.GetBuffs end
    if type(S.origFiredGun)=="function" then
        mod.FiredGun=function(arg,arg2,arg3,...)
            if S.unloaded or not C.RebelSilentAim then return S.origFiredGun(arg,arg2,arg3,...) end
            if arg~=LP.Character then return S.origFiredGun(arg,arg2,arg3,...) end
            arg3=arg3 or {}
            local h=arg and arg:FindFirstChild("HumanoidRootPart") if not h then return S.origFiredGun(arg,arg2,arg3,...) end
            local firePos=h.Position
            pcall(function()
                local attr=arg:GetAttribute("HoldingWeapon")
                if attr then local w=arg:FindFirstChild(attr) if w then local ff=w:FindFirstChild("FireFrom") if ff then firePos=ff.Position end end end
            end)
            local target=findSilentAimTarget()
            if target then arg2=target.Position arg3.CustomFireFrom=true arg3.spread=0 end
            return S.origFiredGun(arg,arg2,arg3,...)
        end
    end
    if type(S.origGetBuffs)=="function" then
        mod.GetBuffs=function(...)
            local data=S.origGetBuffs(...) if type(data)~="table" then data={} end
            local cp={} for k,v in pairs(data) do cp[k]=v end
            if C.RebelNoRecoil then cp.RecoilDiv=999999 end
            return cp
        end
    end
    S.combatHooked=true
end
local function unhookCombat()
    if not S.combatHooked or not S.gunMod then return end
    pcall(function()
        if S.origFiredGun then S.gunMod.FiredGun=S.origFiredGun end
        if S.origGetBuffs then S.gunMod.GetBuffs=S.origGetBuffs end
    end)
    S.combatHooked=false S.origFiredGun=nil S.origGetBuffs=nil
end
local function aimbotFindTarget()
    local cam=Workspace.CurrentCamera if not cam then return nil end
    local cx=cam.ViewportSize.X/2 local cy=cam.ViewportSize.Y/2
    local fov=C.RebelFOV or 250 local bestPart,bestDist=nil,math.huge local seen={}
    local sticky=S.aimbotTarget
    if sticky and sticky.Parent and sticky:IsDescendantOf(Workspace) then
        local stickyChar=sticky:FindFirstAncestorOfClass("Model")
        if stickyChar and stickyChar.Parent then
            local sHum=stickyChar:FindFirstChildOfClass("Humanoid")
            if sHum and sHum.Health>0 then
                local part=getRandomBodyPart(stickyChar)
                if part then
                    local sp,onScreen=cam:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local dx=sp.X-cx local dy=sp.Y-cy local d=math.sqrt(dx*dx+dy*dy)
                        if d<=fov*1.5 then
                            local visible=true if C.RebelAimbotVisibleCheck then visible=isTargetVisible(stickyChar) end
                            if visible then return part end
                        end
                    end
                end
            end
        end
    end
    S.aimbotTarget=nil
    local function consider(char)
        if not char or seen[char] then return end
        seen[char]=true
        if not isCharValidTarget(char) then return end
        if C.RebelAimbotVisibleCheck and not isTargetVisible(char) then return end
        if not C.RebelAimbotTargetGuards then
            local hrp=char:FindFirstChild("HumanoidRootPart") local targetPlayer=Players:GetPlayerFromCharacter(char) local isGuardNpc=false
            if not targetPlayer then
                if char.Name:match("Guard") or char:FindFirstChild("TypeOfGuard") then isGuardNpc=true end
                if hrp and (hrp:FindFirstChild("GuardCanKillLockOut") or hrp:FindFirstChild("GuardCanKillLockOn")) then isGuardNpc=true end
            end
            if isGuardNpc then return end
        end
        local part=getRandomBodyPart(char) if not part then return end
        local sp,onScreen=cam:WorldToViewportPoint(part.Position) if not onScreen then return end
        local dx=sp.X-cx local dy=sp.Y-cy local d=math.sqrt(dx*dx+dy*dy)
        if d<=fov and d<bestDist then bestDist=d bestPart=part end
    end
    local live=Workspace:FindFirstChild("Live")
    if live then for _,ch in ipairs(live:GetChildren()) do if ch:IsA("Model") then consider(ch) end end end
    local chars=Workspace:FindFirstChild("Characters")
    if chars then for _,ch in ipairs(chars:GetChildren()) do if ch:IsA("Model") then consider(ch) end end end
    for _,plr in ipairs(Players:GetPlayers()) do if plr~=LP and plr.Character then consider(plr.Character) end end
    if bestPart then S.aimbotTarget=bestPart S.aimbotTargetTime=tick() end
    return bestPart
end
local function startAimbot()
    if S.aimbotConn then return end
    S.aimbotConn=RunService.RenderStepped:Connect(function()
        if S.unloaded or not C.RebelAimbot then return end
        local cam=Workspace.CurrentCamera if not cam then return end
        if C.RebelAimbotHoldKey then
            if not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then S.aimbotTarget=nil return end
        end
        local part=aimbotFindTarget() if not part or not part.Parent then return end
        local camPos=cam.CFrame.Position local wantCF=CFrame.new(camPos,part.Position) local sm=tonumber(C.RebelAimbotSmooth) or 1.0
        if sm<=0.05 then cam.CFrame=wantCF
        else local alpha=math.clamp(1/sm*0.4,0.02,1) cam.CFrame=cam.CFrame:Lerp(wantCF,alpha) end
    end)
end
local function stopAimbot() S.aimbotTarget=nil if S.aimbotConn then pcall(function() S.aimbotConn:Disconnect() end) S.aimbotConn=nil end end
local function doBrewUse()
    if S.unloaded or not C.AutoBrew then return false end
    local invBrew=findBrewInInventory() if not invBrew then return false end
    local char=LP.Character local hum=char and char:FindFirstChildOfClass("Humanoid") if not hum then return false end
    if invBrew.Parent~=char then pcall(function() hum:EquipTool(invBrew) end) task.wait(0.15) end
    press(string.lower(tostring(C.AutoBrewSlot or "e"))) return true
end
local function scanDrinks()
    if not fireproximityprompt then return 0 end
    local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") if not hrp then return 0 end
    local fired=0 local roots={workspace}
    local live=workspace:FindFirstChild("Live") if live then table.insert(roots,live) end
    local effects=workspace:FindFirstChild("Effects") if effects then table.insert(roots,effects) end
    for _,root in ipairs(roots) do
        for _,obj in ipairs(root:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                local parent=obj.Parent local pos
                if parent then if parent:IsA("BasePart") then pos=parent.Position else local p=parent:FindFirstChildWhichIsA("BasePart") if p then pos=p.Position end end end
                if pos and (hrp.Position-pos).Magnitude<=20 then
                    if isDrinkPrompt(obj) then pcall(fireproximityprompt,obj) fired=fired+1 end
                end
            end
        end
    end
    return fired
end
local function startBrewLoop()
    if S.brewLoopConn then return end
    S.lastBrewTick=0
    S.brewLoopConn=task.spawn(function()
        while not S.unloaded and C.AutoBrew do
            local now=tick() pcall(scanDrinks)
            local invBrew=findBrewInInventory() local interval=tonumber(C.AutoBrewInterval) or 1
            if invBrew and (now-S.lastBrewTick)>=interval then
                S.lastBrewTick=now
                local used=doBrewUse()
                if used then
                    local bd=tonumber(C.AutoBrewBrewDelay) or 1.8 task.wait(bd)
                    for i=1,8 do
                        if S.unloaded or not C.AutoBrew then return end
                        local n=scanDrinks() if n>0 then task.wait(0.2) else task.wait(0.3) end
                    end
                end
            end
            task.wait(0.3)
        end
    end)
end
local function stopBrewLoop() if S.brewLoopConn then pcall(function() task.cancel(S.brewLoopConn) end) S.brewLoopConn=nil end S.lastBrewTick=0 end
local function destroyFOVCircle() if S.fovGui then pcall(function() S.fovGui:Destroy() end) end S.fovGui=nil S.fovFrame=nil S.fovStroke=nil end
local function stopFovRainbow() if S.fovRainbowConn then pcall(function() S.fovRainbowConn:Disconnect() end) S.fovRainbowConn=nil end end
local function startFovRainbow()
    stopFovRainbow()
    S.fovRainbowConn=RunService.RenderStepped:Connect(function()
        if S.unloaded or not C.FOVRainbow then return end
        if not S.fovFrame or not S.fovFrame.Parent then return end
        local t=tick() local col=Color3.fromHSV((t*0.35)%1,1,1)
        for _,ch in ipairs(S.fovFrame:GetChildren()) do
            if ch:IsA("Frame") then
                for _,st in ipairs(ch:GetChildren()) do
                    if st:IsA("UIStroke") and st.Name~="BlackStrokeOuter" and st.Name~="BlackStrokeInner" then st.Color=col end
                end
            end
        end
        if S.fovStroke then S.fovStroke.Color=col end
    end)
end
local function makeFOVCircle()
    destroyFOVCircle()
    if not C.RebelFOVCircle then return end
    local parent=nil
    if gethui then local ok,h=pcall(gethui); if ok and h and typeof(h)=="Instance" then parent=h end end
    if not parent then parent=LP:FindFirstChildOfClass("PlayerGui") end
    if not parent then parent=game:GetService("CoreGui") end
    S.fovGui=Instance.new("ScreenGui") S.fovGui.Name="Xionix_FOV_"..randStr(6)
    S.fovGui.IgnoreGuiInset=true S.fovGui.ResetOnSpawn=false S.fovGui.DisplayOrder=99998
    pcall(function() S.fovGui.Parent=parent end)
    if not S.fovGui.Parent then pcall(function() S.fovGui.Parent=game:GetService("CoreGui") end) end
    local d=math.max(4,(C.RebelFOV or 150)*2) local radius=math.floor(d/2) local ot=C.RebelFOV_OutlineThickness or 5
    S.fovFrame=Instance.new("Frame") S.fovFrame.BackgroundTransparency=1 S.fovFrame.AnchorPoint=Vector2.new(0.5,0.5)
    S.fovFrame.Position=UDim2.new(0.5,0,0.5,0) S.fovFrame.Size=UDim2.fromOffset(d,d) S.fovFrame.ZIndex=1000 S.fovFrame.Parent=S.fovGui
    addCorner(S.fovFrame,radius)
    if C.RebelFOVBlackOutline then
        local bo=Instance.new("Frame") bo.Name="BlackOuter" bo.BackgroundTransparency=1 bo.Size=UDim2.fromScale(1,1)
        bo.AnchorPoint=Vector2.new(0.5,0.5) bo.Position=UDim2.fromScale(0.5,0.5) bo.ZIndex=996 bo.Parent=S.fovFrame addCorner(bo,radius)
        local bs=Instance.new("UIStroke") bs.Name="BlackStrokeOuter" bs.Color=rebelOutlineColor() bs.Thickness=ot
        bs.Transparency=0 bs.ApplyStrokeMode=Enum.ApplyStrokeMode.Border bs.Parent=bo
    end
    if C.RebelFOVNeon then
        local g1=Instance.new("Frame") g1.Name="Glow1" g1.BackgroundTransparency=1 g1.Size=UDim2.fromScale(1,1)
        g1.AnchorPoint=Vector2.new(0.5,0.5) g1.Position=UDim2.fromScale(0.5,0.5) g1.ZIndex=999 g1.Parent=S.fovFrame addCorner(g1,radius)
        local g1s=Instance.new("UIStroke") g1s.Color=rebelFOVColor() g1s.Thickness=14 g1s.Transparency=0.82 g1s.Parent=g1
    end
    S.fovStroke=Instance.new("UIStroke") S.fovStroke.Color=rebelFOVColor()
    S.fovStroke.Thickness=tonumber(C.RebelFOVCircleWidth) or 1.6 S.fovStroke.Transparency=0 S.fovStroke.Parent=S.fovFrame
    local inr=Instance.new("Frame") inr.Name="Inner" inr.BackgroundTransparency=1 inr.Size=UDim2.fromScale(1,1)
    inr.AnchorPoint=Vector2.new(0.5,0.5) inr.Position=UDim2.fromScale(0.5,0.5) inr.ZIndex=1001 inr.Parent=S.fovFrame addCorner(inr,radius)
    local is=Instance.new("UIStroke") is.Name="InnerStroke" is.Color=rebelFOVColor() is.Thickness=1.2 is.Transparency=0.15 is.Parent=inr
    if C.FOVRainbow then startFovRainbow() end
end
local function refreshFOVCircle()
    if not S.fovFrame then return end
    local d=math.max(4,(C.RebelFOV or 150)*2) local radius=math.floor(d/2)
    S.fovFrame.Size=UDim2.fromOffset(d,d)
    local c=S.fovFrame:FindFirstChildOfClass("UICorner") if c then c.CornerRadius=UDim.new(0,radius) end
end
local uiDisc,hnsDisc,vizConn
local lastVizKey=""
local function destroyViz()
    if vizConn then pcall(function() vizConn:Disconnect() end) vizConn=nil end
    if uiDisc then pcall(function() uiDisc:Destroy() end) uiDisc=nil end
    if hnsDisc then pcall(function() hnsDisc:Destroy() end) hnsDisc=nil end
end
local function buildDisc(color)
    local p=Instance.new("Part") p.Name="UIRadiusDisc" p.Anchored=true p.CanCollide=false
    p.CanQuery=false p.CanTouch=false p.CastShadow=false p.Massless=true p.Locked=true p.Material=Enum.Material.Plastic
    p.Color=color p.Shape=Enum.PartType.Cylinder p.Size=Vector3.new(0.08,2,2) p.Transparency=0.55
    pcall(function() p.Parent=Workspace.CurrentCamera or Workspace end)
    return p
end
local function makeViz()
    if S.unloaded then return end
    local key=tostring(C.RadiusVis).."|"..tostring(H.RadiusVis).."|"..tostring(C.Distance).."|"..tostring(H.Distance)
    if key==lastVizKey then return end lastVizKey=key destroyViz()
    if not C.RadiusVis and not H.RadiusVis then return end
    if C.RadiusVis then uiDisc=buildDisc(uiRadiusColor()) end
    if H.RadiusVis then hnsDisc=buildDisc(hnsRadiusColor()) end
    vizConn=RunService.RenderStepped:Connect(function()
        if S.unloaded then return end
        local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") if not hrp then return end
        local base=hrp.Position-Vector3.new(0,2.9,0)
        if uiDisc then
            local d=math.max(2,C.Distance or 16)*2
            uiDisc.CFrame=CFrame.new(base)*CFrame.Angles(0,0,math.rad(90)) uiDisc.Size=Vector3.new(0.08,d,d)
            uiDisc.Color=uiRadiusColor() uiDisc.Transparency=math.clamp(1-(C.RadiusTransparency or 0.55),0.1,0.9)
        end
        if hnsDisc then
            local d=math.max(2,H.Distance or 16)*2
            hnsDisc.CFrame=CFrame.new(base+Vector3.new(0,0.02,0))*CFrame.Angles(0,0,math.rad(90)) hnsDisc.Size=Vector3.new(0.08,d,d)
            hnsDisc.Color=hnsRadiusColor() hnsDisc.Transparency=math.clamp(1-(H.RadiusTransparency or 0.55),0.1,0.9)
        end
    end)
end
local RLGL_RED_IMG="rbxassetid://88400194373338"
_G.__rlgl_isRed=function()
    local ok1,r1=pcall(function()
        local pg=LP:FindFirstChild("PlayerGui") if not pg then return false end
        local imp=pg:FindFirstChild("ImpactFrames") if not imp then return false end
        local tl=imp:FindFirstChild("TrafficLightEmpty") if not tl or not tl:IsA("ImageLabel") then return false end
        return tl.Image==RLGL_RED_IMG
    end)
    if ok1 and r1 then return true end
    local ok2,r2=pcall(function()
        local cc=Lighting:FindFirstChildOfClass("ColorCorrectionEffect") if not cc or not cc.Enabled then return false end
        local t=cc.TintColor return t.R>0.6 and t.G<0.4 and t.B<0.4
    end)
    return ok2 and r2 or false
end
_G.__rlgl_inSafeZone=function()
    local char=LP.Character if not char then return false end
    local hrp=char:FindFirstChild("HumanoidRootPart") if not hrp then return false end
    local p=hrp.Position if math.abs(p.Y-1023)>80 then return false end
    local function inBox(a,b,c,d) return p.X>=a and p.X<=b and p.Z>=c and p.Z<=d end
    if inBox(-219,135,-656,-511) then return true end
    if inBox(-215,115,82,168) then return true end
    return false
end
_G.__rlgl_inFinishZone=function()
    local char=LP.Character if not char then return false end
    local hrp=char:FindFirstChild("HumanoidRootPart") if not hrp then return false end
    local p=hrp.Position if math.abs(p.Y-1023)>80 then return false end
    return p.X>=-215 and p.X<=115 and p.Z>=82 and p.Z<=168
end
_G.__rlgl_isMoving=function(th)
    local char=LP.Character if not char then return false end
    local hum=char:FindFirstChildOfClass("Humanoid") local hrp=char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return false end
    if hum.MoveDirection.Magnitude>0.1 then return true end
    local v=hrp.AssemblyLinearVelocity return math.sqrt(v.X*v.X+v.Z*v.Z)>(th or 0.3)
end
_G.__rlgl_isOnMap=function()
    local values=workspace:FindFirstChild("Values")
    if values then local cg=values:FindFirstChild("CurrentGame") if cg and cg.Value=="RedLightGreenLight" then return true end end
    local char=LP.Character if not char then return false end
    local hrp=char:FindFirstChild("HumanoidRootPart") if not hrp then return false end
    return hrp.Position.Y>1000 and hrp.Position.Y<1050
end
_G.__rlgl_timerSeconds=function()
    local attr=workspace:GetAttribute("CurrentGameTime") if type(attr)=="number" then return attr,tostring(attr) end
    for _,n in ipairs({"TimeLeft","Timer","RoundTime","TimeRemaining"}) do
        local v=workspace:GetAttribute(n) if type(v)=="number" then return v,tostring(v) end
    end
    return nil,nil
end
_G.__rlgl_fireDodge=function()
    if S.unloaded then return end
    local char=LP.Character if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid") if not hum or hum.Health<=0 then return end
    if type(keypress)=="function" and type(keyrelease)=="function" then
        pcall(function() keypress(0x54) task.delay(0.012,function() pcall(function() keyrelease(0x54) end) end) end)
    else
        pcall(function()
            local vim=game:GetService("VirtualInputManager")
            vim:SendKeyEvent(true,Enum.KeyCode.T,false,game)
            task.delay(0.012,function() pcall(function() vim:SendKeyEvent(false,Enum.KeyCode.T,false,game) end) end)
        end)
    end
end
local function applyFullBright(st)
    if st then
        if not S.fbInst then S.fbInst=Instance.new("ColorCorrectionEffect") S.fbInst.Name="Xionix_FB" S.fbInst.Contrast=0.15 S.fbInst.Saturation=0.05 S.fbInst.Parent=Lighting end
        S.fbInst.Brightness=tonumber(C.FullBrightIntensity) or 0.3
    else
        if S.fbInst then pcall(function() S.fbInst:Destroy() end) S.fbInst=nil end
    end
end
local function applyRemoveFog(st)
    if st then
        if not S.fogBackup then S.fogBackup={FogEnd=Lighting.FogEnd,FogStart=Lighting.FogStart,FogColor=Lighting.FogColor} end
        Lighting.FogEnd=1000000 Lighting.FogStart=1000000
    else
        if S.fogBackup then
            Lighting.FogEnd=S.fogBackup.FogEnd Lighting.FogStart=S.fogBackup.FogStart
            Lighting.FogColor=S.fogBackup.FogColor S.fogBackup=nil
        end
    end
end
-- ===== HSX ADDITIONS: HELPERS =====
local function _xd_notify(t,d,dur)
    pcall(function() WindUI:Notify({Title=tostring(t),Content=tostring(d or ""),Duration=tonumber(dur) or 3}) end)
end
local function _xd_getChar() return LP.Character end
local function _xd_getHum(c) c=c or LP.Character return c and c:FindFirstChildOfClass("Humanoid") end
local function _xd_getHRP(c) c=c or LP.Character return c and c:FindFirstChild("HumanoidRootPart") end
local function _xd_safeTP(pos) local hrp=_xd_getHRP() if hrp then hrp.CFrame=CFrame.new(pos) return true end return false end
local function _xd_isGameActive(name)
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
local function _xd_canEnable(game,label)
    if game and not _xd_isGameActive(game) then _xd_notify(label,"Wait for "..game.."!",1) return false end
    return true
end
local function _xd_isHider(p)
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
local function _xd_isSeeker(p)
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
local function _xd_isGuard(p)
    if not p then return false end local f=false
    pcall(function()
        if p:GetAttribute("IsGuard")==true or p:GetAttribute("isGuard")==true then f=true end
        local c=p.Character
        if c then if c:GetAttribute("IsGuard") or c:GetAttribute("isGuard") then f=true end end
    end)
    return f
end
-- ===== HSX ADDITIONS: NEW FUNCTIONS =====
-- Lights Out
S.LightsOutSafe={Enabled=false,SavedCFrame=nil}
function S.toggle_lights_out_safezone(arg)
    local enabled=arg and true or false
    S.LightsOutSafe.Enabled=enabled
    local getCharacter=_xd_getChar() local humanoidRootPart
    if getCharacter then humanoidRootPart=getCharacter:FindFirstChild("HumanoidRootPart") or getCharacter.PrimaryPart else humanoidRootPart=getCharacter end
    if enabled then
        if humanoidRootPart then
            S.LightsOutSafe.SavedCFrame=humanoidRootPart.CFrame
            pcall(function() humanoidRootPart.CFrame=CFrame.new(178,56,50) _xd_notify("Lights Out","Teleported",0.9) end)
        end
        return true
    end
    if humanoidRootPart and S.LightsOutSafe.SavedCFrame then
        pcall(function() humanoidRootPart.CFrame=S.LightsOutSafe.SavedCFrame _xd_notify("Lights Out","Returned",0.9) end)
    end
    S.LightsOutSafe.SavedCFrame=nil
    return true
end
function S.toggle_vampire_vision(arg)
    local v=arg and true or false S.VampireVisionEnabled=v
    local nv=Lighting:FindFirstChild("VampireNightVision")
    if v then
        if not nv then local cc=Instance.new("ColorCorrectionEffect") cc.Name="VampireNightVision" cc.Parent=Lighting nv=cc end
        nv.Brightness=0.16 nv.Contrast=0.06 nv.Saturation=-0.08 nv.TintColor=Color3.fromRGB(255,236,236)
    elseif nv then nv:Destroy() end
end
-- Hide and Seek
function S.teleport_to_spawn()
    local c=_xd_getChar() if not c then return end
    local hrp=_xd_getHRP(c) if not hrp then return end
    hrp.CFrame=CFrame.new(Vector3.new(196.83342,55.9548,-90.47459))
end
function S.teleport_to_hider()
    if not _xd_canEnable("HideAndSeek","HNS") then return end
    local c=_xd_getChar() if not c then return end
    local hrp=_xd_getHRP(c) if not hrp then return end
    for _,p in pairs(Players:GetPlayers()) do
        if p~=LP and _xd_isHider(p) and p.Character then
            local h=p.Character:FindFirstChildOfClass("Humanoid")
            if h and h.Health>0 then
                local hrp2=p.Character:FindFirstChild("HumanoidRootPart")
                if hrp2 then hrp.CFrame=CFrame.new(hrp2.Position.X,hrp2.Position.Y+3,hrp2.Position.Z) _xd_notify("HNS","TP to hider: "..p.Name,0.9) return end
            end
        end
    end
    _xd_notify("HideAndSeek","No hiders found",0.9)
end
function S.teleport_to_seeker()
    if not _xd_canEnable("HideAndSeek","HNS") then return end
    local c=_xd_getChar() if not c then return end
    local hrp=_xd_getHRP(c) if not hrp then return end
    for _,p in pairs(Players:GetPlayers()) do
        if p~=LP and _xd_isSeeker(p) and p.Character then
            local h=p.Character:FindFirstChildOfClass("Humanoid")
            if h and h.Health>0 then
                local hrp2=p.Character:FindFirstChild("HumanoidRootPart")
                if hrp2 then hrp.CFrame=CFrame.new(hrp2.Position.X,hrp2.Position.Y+3,hrp2.Position.Z) _xd_notify("HNS","TP to seeker: "..p.Name,0.9) return end
            end
        end
    end
    _xd_notify("HideAndSeek","No seekers found",0.9)
end
S.KeyESPEnabled=false S.KeyESPBoxes={} S.KeyESPConnection=nil
function S.toggle_key_esp(v)
    if v then if not _xd_canEnable("HideAndSeek","Key ESP") then return false end end
    S.KeyESPEnabled=v
    if S.KeyESPConnection then S.KeyESPConnection:Disconnect() S.KeyESPConnection=nil end
    for _,b in pairs(S.KeyESPBoxes) do if b then pcall(function() b:Destroy() end) end end S.KeyESPBoxes={}
    if v then
        task.spawn(function()
            local lp2=LP local W=workspace local effects
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
                local b=Instance.new("BoxHandleAdornment") b.Name="KeyESP" b.Adornee=a
                b.Size=a.Size+Vector3.new(0.5,0.5,0.5) b.Color3=Color3.fromRGB(138,43,226)
                b.Transparency=0.4 b.AlwaysOnTop=true b.ZIndex=10 b.Parent=a return b
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
                                else delBox(child) local k2=pp:FindFirstChild("KeyESP") if k2 then k2:Destroy() end end
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
    return true
end
S.ExitDoorESPEnabled=false S.ExitDoorESPThread=nil S.ExitDoorESPObjects={}
function S.toggle_exit_door_esp(arg)
    if arg then if not _xd_canEnable("HideAndSeek","Exit Door ESP") then S.ExitDoorESPEnabled=false return end end
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
    if not arg then return end
    local function mk(arg2)
        local ok,size=pcall(function() local bb,s=arg2:GetBoundingBox() return s end) size=ok and size or Vector3.new(4,6,2)
        local box=Instance.new("BoxHandleAdornment")
        box.Adornee=arg2.PrimaryPart or arg2:FindFirstChildWhichIsA("BasePart")
        if not box.Adornee then return nil end
        box.Size=size box.Color3=Color3.fromRGB(255,255,0) box.Transparency=0.5
        box.AlwaysOnTop=true box.ZIndex=10 box.Parent=box.Adornee
        local bb=Instance.new("BillboardGui") bb.Adornee=box.Adornee bb.Size=UDim2.new(0,100,0,50)
        bb.StudsOffset=Vector3.new(0,3,0) bb.AlwaysOnTop=true bb.Parent=box.Adornee
        local lbl=Instance.new("TextLabel") lbl.Size=UDim2.new(1,0,1,0) lbl.BackgroundTransparency=1
        lbl.Text="EXIT DOOR" lbl.TextColor3=Color3.fromRGB(255,255,0) lbl.TextScaled=true lbl.Font=Enum.Font.SourceSansBold lbl.Parent=bb
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
end
S.SpikesESPObjects={}
function S.toggle_spikes_esp(arg)
    S.SpikesESPEnabled=arg and true or false
    for _,o in pairs(S.SpikesESPObjects or {}) do pcall(function() if type(o)=="table" then for _,x in pairs(o) do if x and x.Destroy then x:Destroy() end end elseif o and o.Destroy then o:Destroy() end end) end
    S.SpikesESPObjects={}
    if not arg then return end
    local names={KillingParts=true,killingParts=true,Killingparts=true,killingparts=true}
    for _,d in ipairs(workspace:GetDescendants()) do
        if names[d.Name] or string.lower(tostring(d.Name))=="killingparts" then
            local parts={}
            if d:IsA("BasePart") then table.insert(parts,d) else for _,d2 in ipairs(d:GetDescendants()) do if d2:IsA("BasePart") then table.insert(parts,d2) end end end
            for _,p in ipairs(parts) do
                if not S.SpikesESPObjects[p] then
                    local hl=Instance.new("Highlight") hl.Name="SpikeHL" hl.Adornee=p hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
                    hl.FillColor=Color3.fromRGB(0,0,0) hl.OutlineColor=Color3.fromRGB(40,40,40)
                    hl.FillTransparency=0.35 hl.OutlineTransparency=0 hl.Parent=p S.SpikesESPObjects[p]=hl
                end
            end
        end
    end
end
S.AntiSpikesEnabled=false S.AntiSpikesPlatforms={} S.AntiSpikesConn=nil
function S.toggle_anti_spikes(arg)
    S.AntiSpikesEnabled=arg and true or false
    for _,p in ipairs(S.AntiSpikesPlatforms) do pcall(function() if p then p:Destroy() end end) end S.AntiSpikesPlatforms={}
    if S.AntiSpikesConn then pcall(function() S.AntiSpikesConn:Disconnect() end) S.AntiSpikesConn=nil end
    if not arg then return true end
    local m=Workspace:FindFirstChild("HideAndSeekMap") local kp=m and m:FindFirstChild("KillingParts")
    if not kp then _xd_notify("Anti-Spikes","KillingParts not found",0.9) S.AntiSpikesEnabled=false return false end
    local n=0
    local function make(p)
        if not p:IsA("BasePart") then return end
        local part=Instance.new("Part") part.Name="AntiSpike" part.Anchored=true part.CanCollide=true
        part.Transparency=0.5 part.Material=Enum.Material.SmoothPlastic part.Color=Color3.fromRGB(60,60,60)
        part.Size=Vector3.new(math.max(p.Size.X,4),1,math.max(p.Size.Z,4))
        part.CFrame=CFrame.new(p.Position+Vector3.new(0,20,0)) part.Parent=workspace
        table.insert(S.AntiSpikesPlatforms,part) n+=1
    end
    for _,d in ipairs(kp:GetDescendants()) do if d:IsA("BasePart") then make(d) end end
    for _,c in ipairs(kp:GetChildren()) do if c:IsA("BasePart") then make(c) end end
    _xd_notify("Anti-Spikes","Enabled ("..n..")",0.9) return true
end
S.SpikesKillFeature={Enabled=false,AnimationIds={"rbxassetid://105341857343164","rbxassetid://95623680038308","rbxassetid://106191977814264","rbxassetid://79549040943367","rbxassetid://138639404847153","rbxassetid://81533666958052","rbxassetid://118039465583394"},SpikesPosition=nil,PlatformHeightOffset=20,ReturnDelay=0.6,OriginalCFrame=nil,ActiveAnimation=false,AnimationStartTime=0,AnimationConnection=nil,CharacterAddedConnection=nil,AnimationStoppedConnections={},TrackedAnimations={},SafetyCheckConnection=nil,PlatformPart=nil,PlatformCreated=false}
function S.toggle_spikes_kill(arg)
    if arg and not _xd_isGameActive("HideAndSeek") then _xd_notify("Spikes Kill","Wait for HideAndSeek!",0.9) S.SpikesKillFeature.Enabled=false return end
    local F=S.SpikesKillFeature
    if F.AnimationConnection then F.AnimationConnection:Disconnect() F.AnimationConnection=nil end
    if F.CharacterAddedConnection then F.CharacterAddedConnection:Disconnect() F.CharacterAddedConnection=nil end
    if F.SafetyCheckConnection then F.SafetyCheckConnection:Disconnect() F.SafetyCheckConnection=nil end
    for _,c in ipairs(F.AnimationStoppedConnections) do pcall(function() c:Disconnect() end) end F.AnimationStoppedConnections={}
    if F.PlatformPart then pcall(function() F.PlatformPart:Destroy() end) F.PlatformPart=nil end
    F.PlatformCreated=false F.OriginalCFrame=nil F.ActiveAnimation=false F.AnimationStartTime=0 F.TrackedAnimations={} F.SpikesPosition=nil
    if not arg then F.Enabled=false return end
    pcall(function()
        local m=workspace:FindFirstChild("HideAndSeekMap") m=m and m:FindFirstChild("KillingParts")
        if m then for _,c in pairs(m:GetChildren()) do if c:IsA("BasePart") then if not F.SpikesPosition then F.SpikesPosition=c.Position end end end end
    end)
    local function fn4()
        if F.PlatformCreated or not F.SpikesPosition then return end
        pcall(function()
            local p=Instance.new("Part") p.Name="SafetyPlatform" p.Size=Vector3.new(20,5,20)
            p.Position=F.SpikesPosition+Vector3.new(0,F.PlatformHeightOffset,0) p.Anchored=true p.CanCollide=true p.Transparency=1
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
    local function fn6(c) if not c or not c:FindFirstChild("HumanoidRootPart") then return end if F.OriginalCFrame then c:SetPrimaryPartCFrame(F.OriginalCFrame) F.OriginalCFrame=nil end end
    local function fn7(id) for _,a in ipairs(F.AnimationIds) do if a==id then return true end end return false end
    local function fn8(c)
        F.AnimationConnection=c:WaitForChild("Humanoid").AnimationPlayed:Connect(function(tr)
            if not F.Enabled then return end
            if tr.Animation and fn7(tr.Animation.AnimationId) then
                F.TrackedAnimations[tr]=true
                if not F.ActiveAnimation then
                    F.ActiveAnimation=true F.AnimationStartTime=tick() fn5(c)
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
        if not F.Enabled then if F.SafetyCheckConnection then F.SafetyCheckConnection:Disconnect() F.SafetyCheckConnection=nil end return end
        if not _xd_isGameActive("HideAndSeek") then F.Enabled=false return end
        if F.PlatformCreated and (not F.PlatformPart or not F.PlatformPart.Parent) then F.PlatformCreated=false F.PlatformPart=nil fn4() end
        local active=F.ActiveAnimation if active then active=tick()-F.AnimationStartTime>=10 end
        if active then local v=_xd_getChar() if v and F.OriginalCFrame then fn6(v) end F.ActiveAnimation=false F.TrackedAnimations={} end
    end)
    F.Enabled=true fn4()
end
-- Auto Dodge: STRICT ALWAYS ON, replace HollyMode toggle
-- Jump Rope
S.JumpRopeAntiFall={Enabled=false,Platform=nil,Conn=nil}
function S.toggle_jump_rope_anti_fall(enabled)
    if enabled then if not _xd_canEnable("JumpRope","JumpRope") then return end end
    if S.JumpRopeAntiFall.Conn then S.JumpRopeAntiFall.Conn:Disconnect() end
    if S.JumpRopeAntiFall.Platform then S.JumpRopeAntiFall.Platform:Destroy() end
    S.JumpRopeAntiFall.Enabled=enabled
    if enabled then
        local function mk()
            local c=_xd_getChar() if not c then return nil end
            local hrp=_xd_getHRP(c) if not hrp then return nil end
            local p=Instance.new("Part") p.Name=HttpService:GenerateGUID(false)
            p.Size=Vector3.new(10000,1,10000) p.Position=Vector3.new(hrp.Position.X,hrp.Position.Y-5,hrp.Position.Z)
            p.Anchored=true p.CanCollide=true p.Transparency=0.5 p.Parent=workspace return p
        end
        S.JumpRopeAntiFall.Platform=mk()
        S.JumpRopeAntiFall.Conn=RunService.Heartbeat:Connect(function()
            if not S.JumpRopeAntiFall.Enabled then return end
            if not _xd_isGameActive("JumpRope") then S.JumpRopeAntiFall.Enabled=false return end
            if not (S.JumpRopeAntiFall.Platform and S.JumpRopeAntiFall.Platform.Parent) then S.JumpRopeAntiFall.Platform=mk() end
        end)
    end
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
    if enabled then if not _xd_canEnable("JumpRope","JumpRope") then return false end end
    if S.JumpRopeAntiHit.Connection then S.JumpRopeAntiHit.Connection:Disconnect() S.JumpRopeAntiHit.Connection=nil end
    S.JumpRopeAntiHit.Enabled=enabled S.JumpRopeAntiHit.RopeDestroyed=false
    if enabled then
        S.disable_damage_scripts() S.destroy_all_ropes()
        S.JumpRopeAntiHit.Connection=RunService.Heartbeat:Connect(function()
            if not S.JumpRopeAntiHit.Enabled then return end
            if not _xd_isGameActive("JumpRope") then S.toggle_jump_rope_anti_hit(false) return end
            if not S.JumpRopeAntiHit.RopeDestroyed then S.destroy_all_ropes() end
        end)
    end
    return true
end
S.JumpRopeFakeBalance={Enabled=false,Connection=nil,AnimationId="rbxassetid://105677261748140",AnimationDuration=0.4,CurrentAnimation=nil,StopTimer=nil,WasJumping=false}
function S.play_land_animation_fake_balance()
    if not S.JumpRopeFakeBalance.Enabled then return end
    local c=_xd_getChar() if not c then return end
    local h=_xd_getHum(c) if not h then return end
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
    local c=_xd_getChar() if not c then return end
    local h=_xd_getHum(c) if not h then return end
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
    if enabled then if not _xd_canEnable("JumpRope","JumpRope") then return false end end
    if S.JumpRopeFakeBalance.Connection then S.JumpRopeFakeBalance.Connection:Disconnect() S.JumpRopeFakeBalance.Connection=nil end
    if S.JumpRopeFakeBalance.CurrentAnimation then pcall(function() S.JumpRopeFakeBalance.CurrentAnimation:Stop() end) S.JumpRopeFakeBalance.CurrentAnimation=nil end
    if S.JumpRopeFakeBalance.StopTimer then S.JumpRopeFakeBalance.StopTimer:Disconnect() S.JumpRopeFakeBalance.StopTimer=nil end
    S.JumpRopeFakeBalance.Enabled=enabled
    if enabled then
        S.setup_jump_rope_fake_balance()
        S.JumpRopeFakeBalance.Connection=RunService.Heartbeat:Connect(function()
            if not S.JumpRopeFakeBalance.Enabled then return end
            if not _xd_isGameActive("JumpRope") then S.toggle_jump_rope_fake_balance(false) return end
        end)
    end
    return true
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
end
function S.remove_balance_mini_game()
    local pj=LP:FindFirstChild("PlayingJumpRope")
    if pj then pcall(function() pj:Destroy() end) else _xd_notify("Jump Rope","PlayingJumpRope not found",0.9) end
end
function S.jr_delete_rope()
    if not _xd_canEnable("JumpRope","JumpRope") then return end
    for _,d in pairs(workspace:GetDescendants()) do
        if d.Name=="Rope" and (d:IsA("Model") or d:IsA("Part")) then d:Destroy() _xd_notify("JumpRope","Rope deleted",0.9) return end
    end
    _xd_notify("JumpRope","Rope not found",0.9)
end
function S.jr_tp_start() if not _xd_canEnable("JumpRope","JumpRope") then return end _xd_safeTP(Vector3.new(615.2844,192.27428,920.9525)) _xd_notify("JumpRope","TP Start",0.9) end
function S.jr_tp_end() if not _xd_canEnable("JumpRope","JumpRope") then return end _xd_safeTP(Vector3.new(720.89606,198.62831,921.17065)) _xd_notify("JumpRope","TP End",0.9) end
-- Tug of War
S.TugOfWarAutoQTEMiss=false S.TugOfWarAutoQTEMissConnection=nil
local function _findCircleBase()
    local pg=LP:FindFirstChild("PlayerGui") if not pg then return nil end
    local tbl2={} tbl2[1]=pg:FindFirstChild("TugOfWarUIV2") tbl2[2]=pg:FindFirstChild("TugOfWarUI")
    do local v=table.pack(pg.FindFirstChild(pg,"TugofWarRemake")) table.move(v,1,v.n,3,tbl2) end
    for _,v3 in ipairs(tbl2) do
        if v3 then
            local cb=(v3:FindFirstChild("TugofWarRemake") or v3):FindFirstChild("CircleBase")
            if cb then return cb end
            local cb2=v3:FindFirstChild("CircleBase",true) if cb2 then return cb2 end
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
            local v3=_findCircleBase() if not v3 then return end
            local arrow=v3:FindFirstChild("Arrow") local medium=v3:FindFirstChild("Medium")
            if arrow and medium then medium.Rotation=arrow.Rotation end
        end)
    end
end
function S.toggle_tug_auto_pull_op(arg)
    local enabled=arg and true or false
    S.AutoPullV2=S.AutoPullV2 or {}
    S.AutoPullV2.Enabled=enabled
    if S.AutoPullV2.Conn then pcall(function() S.AutoPullV2.Conn:Disconnect() end) S.AutoPullV2.Conn=nil end
    if S.AutoPullV2._pressTask then pcall(task.cancel,S.AutoPullV2._pressTask) S.AutoPullV2._pressTask=nil end
    if not enabled then S.AutoPullV2._didPress=false S.AutoPullV2.CapturedArgs=nil return true end
    S.AutoPullV2._didPress=false S.AutoPullV2.CapturedArgs=nil
    local function fn11()
        local pg=LP:FindFirstChild("PlayerGui") if not pg then return nil end
        for _,d in ipairs(pg:GetDescendants()) do
            if d.Name=="CircleBase" and d:FindFirstChild("Arrow") and d:FindFirstChild("Medium") then return d end
        end
        return nil
    end
    local function fn12(a) pcall(function() local ar=a:FindFirstChild("Arrow") local me=a:FindFirstChild("Medium") if ar and me then me.Rotation=ar.Rotation end end) end
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
                local v2=fn11() if v2 then fn12(v2) fn13(v2) n+=1 end
                if S.AutoPullV2.CapturedArgs and #S.AutoPullV2.CapturedArgs>0 then S.AutoPullV2._didPress=true break else task.wait(0.12) continue end
            end
            break
        end
        S.AutoPullV2._didPress=true
    end)
    S.AutoPullV2.Conn=RunService.Heartbeat:Connect(function()
        if not S.AutoPullV2.Enabled or not S.AutoPullV2._didPress then return end
        local now=tick() if now-(S.AutoPullV2.LastFire or 0)<0.04 then return end
        S.AutoPullV2.LastFire=now
        pcall(function()
            local r=ReplicatedStorage:FindFirstChild("Remotes") local trb=r and r:FindFirstChild("TemporaryReachedBindable")
            if trb then trb:FireServer({GameQTE=true}) trb:FireServer({IHateYou=true}) end
        end)
    end)
    return true
end
-- Glass Bridge
function S.gb_tp_end()
    if _xd_isGameActive("GlassBridge") then _xd_safeTP(Vector3.new(-196.37247,522.19214,-1534.2098)) _xd_notify("GlassBridge","TP End",0.9)
    else _xd_notify("GlassBridge","Wait for GlassBridge!",0.9) end
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
                for _,c in ipairs(d:GetChildren()) do if c.ClassName=="TouchInterest" then pcall(function() c:Destroy() end) end end
            end
        end
    end
    if S.AntiBreakEnabled then
        remove()
        S.AntiBreakConn=RunService.Heartbeat:Connect(function()
            if not S.AntiBreakEnabled then return end
            local now=tick() if now<(S._ABLast or 0)+1 then return end
            S._ABLast=now pcall(remove)
        end)
    end
end
-- Mingle
S.MingleVoidKillEnabled=false S.MingleConns={}
function S.toggle_mingle_void_kill(on)
    if on and not _xd_isGameActive("Mingle") then _xd_notify("Mingle Void Kill","Wait for Mingle!",0.9) return end
    for _,c in pairs(S.MingleConns) do pcall(function() c:Disconnect() end) end S.MingleConns={}
    S.MingleVoidKillEnabled=on
    if on then
        local animId="rbxassetid://71318091779666" local plat=nil
        local function attach(arg)
            local hum=arg:FindFirstChildOfClass("Humanoid") or arg:WaitForChild("Humanoid",5) if not hum then return end
            local c=hum.AnimationPlayed:Connect(function(tr)
                if not S.MingleVoidKillEnabled then return end
                if not tr.Animation or tr.Animation.AnimationId~=animId then return end
                local hrp=arg:FindFirstChild("HumanoidRootPart") if not hrp then return end
                local saved=hrp.CFrame
                if plat then pcall(function() plat:Destroy() end) plat=nil end
                plat=Instance.new("Part") plat.Name=HttpService:GenerateGUID(false)
                plat.Size=Vector3.new(40,2,40) plat.Position=Vector3.new(196.83342,52.9548,-90.47459)
                plat.Anchored=true plat.CanCollide=true plat.Transparency=1 plat.Parent=workspace
                hrp.AssemblyLinearVelocity=Vector3.zero hrp.CFrame=CFrame.new(Vector3.new(196.83342,55.9548,-90.47459))
                if arg.PrimaryPart then pcall(function() arg:SetPrimaryPartCFrame(CFrame.new(Vector3.new(196.83342,55.9548,-90.47459))) end) end
                local c2=tr.Stopped:Connect(function()
                    task.wait(0.6)
                    if arg and arg.Parent and S.MingleVoidKillEnabled then
                        local h2=arg:FindFirstChild("HumanoidRootPart")
                        if h2 then h2.AssemblyLinearVelocity=Vector3.zero h2.CFrame=saved if arg.PrimaryPart then pcall(function() arg:SetPrimaryPartCFrame(saved) end) end end
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
    return true
end
-- SkySquid
S.AutoRespawnOnFall={Enabled=false,Connection=nil,FallHeight=950,TeleportPosition=Vector3.new(0,966,-6),HasTeleported=false}
function S.toggle_auto_respawn_on_fall(enabled)
    if enabled and not _xd_isGameActive("SkySquidGame") then _xd_notify("Auto Respawn","Wait for SkySquidGame!",0.9) return end
    S.AutoRespawnOnFall.Enabled=enabled S.AutoRespawnOnFall.HasTeleported=false
    if S.AutoRespawnOnFall.Connection then S.AutoRespawnOnFall.Connection:Disconnect() S.AutoRespawnOnFall.Connection=nil end
    if enabled then
        S.AutoRespawnOnFall.Connection=RunService.Heartbeat:Connect(function()
            if not S.AutoRespawnOnFall.Enabled then return end
            if not _xd_isGameActive("SkySquidGame") then return end
            local v=_xd_getChar() if not v then return end
            local hrp=_xd_getHRP(v) if not hrp then return end
            local y=hrp.Position.Y
            if y<=S.AutoRespawnOnFall.FallHeight and not S.AutoRespawnOnFall.HasTeleported then
                hrp.CFrame=CFrame.new(S.AutoRespawnOnFall.TeleportPosition) S.AutoRespawnOnFall.HasTeleported=true
            end
            if S.AutoRespawnOnFall.FallHeight<y then S.AutoRespawnOnFall.HasTeleported=false end
        end)
    end
end
S.VoidKillSettings={Enabled=false,Conn=nil,CharConn=nil,Platform=nil,BackupPlatform=nil}
S.VoidAnimIds={"rbxassetid://107989020363293","rbxassetid://71619354165195"}
function S.toggle_void_kill(enabled)
    if enabled and not _xd_isGameActive("SkySquidGame") then _xd_notify("Void Kill","Wait for SkySquidGame!",0.9) return end
    local V=S.VoidKillSettings
    if not enabled then
        if V.Conn then V.Conn:Disconnect() V.Conn=nil end
        if V.CharConn then V.CharConn:Disconnect() V.CharConn=nil end
        if V.Platform then V.Platform:Destroy() V.Platform=nil end
        if V.BackupPlatform then V.BackupPlatform:Destroy() V.BackupPlatform=nil end
        return true
    end
    V.Enabled=true
    local function attach(arg)
        local hum=arg:FindFirstChildOfClass("Humanoid") or arg:WaitForChild("Humanoid",5) if not hum then return end
        V.Conn=hum.AnimationPlayed:Connect(function(tr)
            if not V.Enabled then return end
            if tr.Animation and table.find(S.VoidAnimIds,tr.Animation.AnimationId) then
                local hrp=arg:FindFirstChild("HumanoidRootPart") if not hrp then return end
                local saved=hrp.CFrame
                local plat=Instance.new("Part") plat.Name=HttpService:GenerateGUID(false)
                plat.Size=Vector3.new(10,1,10) plat.Position=Vector3.new(-95.1,960.6,67.6)
                plat.Anchored=true plat.CanCollide=true plat.Transparency=1 plat.Parent=workspace
                arg:SetPrimaryPartCFrame(CFrame.new(-95.1,964.6,67.6))
                tr.Stopped:Connect(function() task.wait(1) if saved then arg:SetPrimaryPartCFrame(saved) end plat:Destroy() end)
            end
        end)
    end
    if LP.Character then attach(LP.Character) end
    V.CharConn=LP.CharacterAdded:Connect(function(c) task.wait(1) attach(c) end)
    return true
end
S.SkySquidAntiFall={Enabled=false,Platform=nil,Conn=nil}
function S.toggle_sky_squid_anti_fall(enabled)
    if S.SkySquidAntiFall.Conn then S.SkySquidAntiFall.Conn:Disconnect() end
    if S.SkySquidAntiFall.Platform then S.SkySquidAntiFall.Platform:Destroy() end
    S.SkySquidAntiFall.Enabled=enabled
    if enabled then
        local function mk()
            local c=_xd_getChar() if not c then return nil end
            local hrp=_xd_getHRP(c) if not hrp then return nil end
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
    return true
end
S.OrbitKillauraEnabled=false S.OrbitKillauraConn=nil S.OrbitRadius=3 S.OrbitSpeed=10 S.OrbitAntiHitEnabled=false
S._DeathAnimId="rbxassetid://82747596610040" S._DeathAnimConns={}
function S.StartDeathAnimGuard(arg,arg2)
    if S._DeathAnimConns[arg] then pcall(function() S._DeathAnimConns[arg]:Disconnect() end) S._DeathAnimConns[arg]=nil end
    local function fn(arg3)
        if not arg3 then return end
        local hum=arg3:FindFirstChildOfClass("Humanoid") if not hum then return end
        if S._DeathAnimConns[arg] then pcall(function() S._DeathAnimConns[arg]:Disconnect() end) end
        S._DeathAnimConns[arg]=hum.AnimationPlayed:Connect(function(tr)
            local ok,r=pcall(function() return tr.Animation end) if not ok or not r then return end
            local s=tostring(r.AnimationId or "")
            if s==S._DeathAnimId or s:find("82747596610040") then
                if S[arg] then S[arg]=false pcall(function() if arg2 then arg2() end end) pcall(function() _xd_notify("Feature off to prevent death","",1.2) end) end
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
local function _findNearestEnemy()
    local c=LP.Character if not c or not c:FindFirstChild("HumanoidRootPart") then return nil end
    local pos=c.HumanoidRootPart.Position local bd=math.huge local res=nil
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP and p.Character then
            local hrp=p.Character:FindFirstChild("HumanoidRootPart") local h=p.Character:FindFirstChild("Humanoid")
            if hrp and h and h.Health>0 and not p.Character:FindFirstChild("Dead") then
                local d=(pos-hrp.Position).Magnitude if d<bd then bd=d res=p end
            end
        end
    end
    return res
end
function S.toggle_orbit_killaura(arg)
    local on=arg and true or false
    if on then
        local flag=false pcall(function() flag=_xd_isGameActive("SkySquidGame") or _xd_isGameActive("SquidGame") end)
        if not flag then
            pcall(function()
                local v=workspace:FindFirstChild("Values") v=v and v:FindFirstChild("CurrentGame")
                if (v and tostring(v.Value) or ""):lower():find("squid") then flag=true end
            end)
        end
        if not flag then _xd_notify("Orbit Kill Aura","Only SkySquidGame/SquidGame",1.2) return false end
    end
    S.OrbitKillauraEnabled=on
    if S.OrbitKillauraConn then pcall(function() S.OrbitKillauraConn:Disconnect() end) S.OrbitKillauraConn=nil end
    if not on then S.StopDeathAnimGuard("OrbitKillauraEnabled") return true end
    S.StartDeathAnimGuard("OrbitKillauraEnabled",function() if S.OrbitKillauraConn then pcall(function() S.OrbitKillauraConn:Disconnect() end) S.OrbitKillauraConn=nil end end)
    S.OrbitKillauraConn=RunService.Heartbeat:Connect(function()
        if not S.OrbitKillauraEnabled then return end
        local tgt=_findNearestEnemy() if not tgt or not tgt.Character then return end
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
                if h2 then flag=check(h2:GetPlayingAnimationTracks()) if not flag then local an=h2:FindFirstChildOfClass("Animator") if an then flag=check(an:GetPlayingAnimationTracks()) end end end
            end)
            if flag then yOff=16 end
        end
        hrp2.CFrame=CFrame.new(Vector3.new(pos.X+math.cos(n)*r,pos.Y+yOff,pos.Z+math.sin(n)*r),hrp.Position)
    end)
    return true
end
-- Pentathlon
S.PentathlonThreads={} S.PentathlonConns={}
local function _findPenInstance()
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
local _penCache=nil
local function _getPenInstance() if _penCache then return _penCache end _penCache=_findPenInstance() return _penCache end
local function _inPentathlon() return LP:GetAttribute("InPentathlon")==true or Workspace:FindFirstChild("PentathlonMap")~=nil end
local function _getPenClient() local ok,r=pcall(function() return require(ReplicatedStorage.Modules.Games.PentathlonClient) end) return ok and r or nil end
local function _stopPen(name)
    if S.PentathlonThreads[name] then pcall(task.cancel,S.PentathlonThreads[name]) S.PentathlonThreads[name]=nil end
    if S.PentathlonConns[name] and typeof(S.PentathlonConns[name])=="RBXScriptConnection" then pcall(function() S.PentathlonConns[name]:Disconnect() end) end
    S.PentathlonConns[name]=nil
end
task.spawn(function() while true do task.wait(1) if _penCache and not _inPentathlon() then _penCache=nil end end end)
S.AutoDdakji=false
function S.toggle_auto_ddakji(on)
    if on and not _xd_isGameActive("Pentathlon") then _xd_notify("Auto Ddakji","Wait for Pentathlon!",0.9) return end
    _stopPen("Ddakji") S.AutoDdakji=on
    if on then
        local cl=_getPenClient() if not cl then return end
        local pw=0.95123884995606622 local ps=Vector3.new(-147.3337,6001.0757,-19.965336) local last=0
        S.PentathlonThreads.Ddakji=task.spawn(function()
            while S.AutoDdakji do
                if _inPentathlon() then
                    if tick()-last>=1.5 then
                        local inst=_getPenInstance()
                        if inst and inst.Active and inst.CurrentPlayer==LP.Character then
                            pcall(function() cl.RunServerGame(inst,"Thrown",{Power=pw,Position=ps}) end) last=tick()
                        end
                    end
                    task.wait(0.1) continue
                end
                break
            end
            _stopPen("Ddakji")
        end)
    end
end
S.AutoFlyingStone=false
function S.toggle_auto_flying_stone(on)
    if on and not _xd_isGameActive("Pentathlon") then _xd_notify("Auto Flying Stone","Wait for Pentathlon!",0.9) return end
    _stopPen("FlyingStone") S.AutoFlyingStone=on
    if on then
        local cl=_getPenClient() if not cl then return end
        local last=0 local cache={stand=nil,game=nil}
        S.PentathlonThreads.FlyingStone=task.spawn(function()
            while S.AutoFlyingStone do
                if _inPentathlon() then
                    if tick()-last>=1.5 then
                        local inst=_getPenInstance()
                        if inst and inst.Active and inst.CurrentPlayer==LP.Character then
                            local hrp=_xd_getHRP()
                            if hrp then
                                if not cache.stand or cache.game~=inst then
                                    cache.game=inst local pm=Workspace:FindFirstChild("PentathlonMap") cache.stand=pm and pm:FindFirstChild("Stand",true)
                                end
                                local target
                                if cache.stand and cache.stand:FindFirstChild("Target") then target=cache.stand.Target.Position else target=hrp.Position+hrp.CFrame.LookVector*20 end
                                local origin=hrp.Position+Vector3.new(0,1.5,0) local dir=(target-origin).Unit
                                pcall(function() cl.RunServerGame(inst,"Thrown",{ThrowPower="Perfect",Origin=origin,Direction=dir}) end) last=tick()
                            end
                        end
                    end
                    task.wait(0.1) continue
                end
                break
            end
            _stopPen("FlyingStone")
        end)
    end
end
S.AutoGonggi=false
function S.toggle_auto_gonggi(on)
    if on and not _xd_isGameActive("Pentathlon") then _xd_notify("Auto Gonggi","Wait for Pentathlon!",0.9) return end
    _stopPen("Gonggi") S.AutoGonggi=on
    if on then
        local cl=_getPenClient() if not cl then return end
        local last=0 local taken={} local instCache=nil
        S.PentathlonThreads.Gonggi=task.spawn(function()
            while S.AutoGonggi do
                if _inPentathlon() then
                    local inst=_getPenInstance()
                    if inst and inst.Active and inst.CurrentPlayer==LP.Character and tick()-last>=2.5 then
                        if inst~=instCache then instCache=inst table.clear(taken) end
                        local pm=Workspace:FindFirstChild("PentathlonMap")
                        if pm then
                            local target=nil
                            for _,d in ipairs(pm:GetDescendants()) do if d:IsA("BasePart") and d:FindFirstChild("GrabHighlight") and not taken[d.Name] then target=d break end end
                            if target then
                                taken[target.Name]=true last=tick()
                                task.spawn(function()
                                    task.wait(0.4)
                                    if inst and inst.Active then pcall(function() cl.RunServerGame(inst,"GotPiece",{Name=target.Name}) end) end
                                    task.wait(0.3)
                                    if inst and inst.Active then
                                        local done=true
                                        for _,d in ipairs(pm:GetDescendants()) do if d:IsA("BasePart") and d:FindFirstChild("GrabHighlight") and not taken[d.Name] then done=false break end end
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
            _stopPen("Gonggi")
        end)
    end
end
S.AutoSpinningTop=false
function S.toggle_auto_spinning_top(on)
    if on and not _xd_isGameActive("Pentathlon") then _xd_notify("Auto Spinning Top","Wait for Pentathlon!",0.9) return end
    _stopPen("SpinningTop") S.AutoSpinningTop=on
    if on then
        local cl=_getPenClient() if not cl then return end
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
                if _inPentathlon() then
                    local inst=_getPenInstance()
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
            _stopPen("SpinningTop")
        end)
    end
end
S.AutoJegi=false
function S.toggle_auto_jegi(on)
    if on and not _xd_isGameActive("Pentathlon") then _xd_notify("Auto Jegi","Wait for Pentathlon!",0.9) return end
    _stopPen("Jegi") S.AutoJegi=on
    if on then
        local cl=_getPenClient() if not cl then return end
        local last=0
        S.PentathlonThreads.Jegi=task.spawn(function()
            while S.AutoJegi do
                if _inPentathlon() then
                    if tick()-last>=0.8 then
                        local inst=_getPenInstance()
                        if inst and inst.Active and inst.CurrentPlayer==LP.Character then
                            pcall(function() cl.RunServerGame(inst,"Kick",{Lose=false}) end) last=tick()
                        end
                    end
                    task.wait(0.1) continue
                end
                break
            end
            _stopPen("Jegi")
        end)
    end
end
-- Dalgona additions
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
function S.toggle_anti_crack() S.AntiCrack() return true end
function S.dalgona_lighter()
    if _xd_isGameActive("Dalgona") then LP:SetAttribute("HasLighter",true) else _xd_notify("Dalgona","Wait for Dalgona!",0.9) end
end
-- Power ESP
S.ESPPowersEnabled=false S.ESPPowersDrawings={} S.ESPPowersConnection=nil
C.PowerESPColor=Color3.fromRGB(255,255,255) C.PowerESPFont=2 C.PowerESPSize=16
function S.clear_esp_powers()
    for _,d in pairs(S.ESPPowersDrawings) do pcall(function() if d.Remove then d:Remove() elseif d.Destroy then d:Destroy() end end) end
    S.ESPPowersDrawings={}
    if S.ESPPowersConnection then pcall(function() S.ESPPowersConnection:Disconnect() end) S.ESPPowersConnection=nil end
end
function S.toggle_esp_powers(arg)
    S.ESPPowersEnabled=arg and true or false S.clear_esp_powers()
    if not arg then return true end
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
                        if on and pos.Z>0 then d.Visible=true d.Position=Vector2.new(pos.X,pos.Y) d.Text=pow else d.Visible=false end
                    end
                end
            end
        end
        for k,d in pairs(S.ESPPowersDrawings) do if not active[k] then pcall(function() if d.Remove then d:Remove() end end) S.ESPPowersDrawings[k]=nil end end
    end)
    return true
end
-- HnS ESP (chase game ESP: seekers red, hiders green, guards yellow)
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
    if not on then return end
    if not _xd_isGameActive("HideAndSeek") then _xd_notify("H&S ESP","Wait for HideAndSeek!",0.9) return end
    S.HNSEspConn=RunService.RenderStepped:Connect(function()
        if not S.HNSEspEnabled then return end
        if not _xd_isGameActive("HideAndSeek") then return end
        local cam=workspace.CurrentCamera if not cam then return end
        local hrp=_xd_getHRP() if not hrp then return end
        local from=cam:WorldToViewportPoint(hrp.Position) local fromV=Vector2.new(from.X,from.Y)
        local active={}
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=LP and p.Character then
                local hum=p.Character:FindFirstChildOfClass("Humanoid")
                local root=p.Character:FindFirstChild("HumanoidRootPart")
                local head=p.Character:FindFirstChild("Head")
                if hum and hum.Health>0 and root and head then
                    local color
                    if _xd_isGuard(p) then color=C.HNSGuardColor
                    elseif _xd_isSeeker(p) then color=C.HNSSeekerColor
                    elseif _xd_isHider(p) then color=C.HNSSafeColor
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
end
-- Extra additions
S.CustomGravityEnabled=false S.CustomGravityValue=196.2 S.CustomGravityConn=nil
function S.toggle_custom_gravity(on)
    S.CustomGravityEnabled=on
    if S.CustomGravityConn then S.CustomGravityConn:Disconnect() S.CustomGravityConn=nil end
    if on then
        Workspace.Gravity=S.CustomGravityValue
        S.CustomGravityConn=RunService.Heartbeat:Connect(function() if S.CustomGravityEnabled then Workspace.Gravity=S.CustomGravityValue end end)
    else Workspace.Gravity=196.2 end
end
function S.set_custom_gravity(v)
    local n=tonumber(v)
    if n and n>=50 and n<=500 then S.CustomGravityValue=n if S.CustomGravityEnabled then Workspace.Gravity=n end
    else _xd_notify("Custom Gravity","Invalid (50-500)",0.9) end
end
S.CustomJumpPowerEnabled=false S.CustomJumpPowerValue=50 S.CustomJumpPowerConn=nil
function S.toggle_custom_jump_power(on)
    S.CustomJumpPowerEnabled=on
    if S.CustomJumpPowerConn then S.CustomJumpPowerConn:Disconnect() S.CustomJumpPowerConn=nil end
    if on then
        local c=_xd_getChar() if c then local h=_xd_getHum(c) if h then S.OriginalJumpPower=h.JumpPower h.JumpPower=S.CustomJumpPowerValue end end
        S.CustomJumpPowerConn=RunService.Heartbeat:Connect(function()
            if S.CustomJumpPowerEnabled then local c2=_xd_getChar() if c2 then local h=_xd_getHum(c2) if h and h.JumpPower~=S.CustomJumpPowerValue then h.JumpPower=S.CustomJumpPowerValue end end end
        end)
    else local c=_xd_getChar() if c then local h=_xd_getHum(c) if h then h.JumpPower=S.OriginalJumpPower or 50 end end end
end
function S.set_custom_jump_power(v)
    local n=tonumber(v)
    if n and n>=20 and n<=200 then S.CustomJumpPowerValue=n if S.CustomJumpPowerEnabled then local c=_xd_getChar() if c then local h=_xd_getHum(c) if h then h.JumpPower=n end end end
    else _xd_notify("Custom Jump Power","Invalid (20-200)",0.9) end
end
S.CustomLevelEnabled=false S.CustomLevelValue=1 S.CustomLevelConn=nil
function S.toggle_custom_level(on)
    S.CustomLevelEnabled=on
    if S.CustomLevelConn then S.CustomLevelConn:Disconnect() S.CustomLevelConn=nil end
    if on then
        LP:SetAttribute("_CurrentLevel",S.CustomLevelValue)
        S.CustomLevelConn=RunService.Heartbeat:Connect(function() if S.CustomLevelEnabled then LP:SetAttribute("_CurrentLevel",S.CustomLevelValue) end end)
    end
end
function S.set_custom_level(v)
    local n=tonumber(v)
    if n and n>=1 and n<=999999 then S.CustomLevelValue=math.floor(n) if S.CustomLevelEnabled then LP:SetAttribute("_CurrentLevel",S.CustomLevelValue) end
    else _xd_notify("Custom Level","Invalid (1-999999)",0.9) end
end
S.CustomWinstreakEnabled=false S.CustomWinstreakValue=0 S.CustomWinstreakConn=nil
function S.toggle_custom_winstreak(on)
    S.CustomWinstreakEnabled=on
    if S.CustomWinstreakConn then S.CustomWinstreakConn:Disconnect() S.CustomWinstreakConn=nil end
    if on then
        LP:SetAttribute("_ConsecutiveWins",S.CustomWinstreakValue)
        S.CustomWinstreakConn=RunService.Heartbeat:Connect(function() if S.CustomWinstreakEnabled then LP:SetAttribute("_ConsecutiveWins",S.CustomWinstreakValue) end end)
    end
end
function S.set_custom_winstreak(v)
    local n=tonumber(v)
    if n and n>=0 and n<=999999 then S.CustomWinstreakValue=math.floor(n) if S.CustomWinstreakEnabled then LP:SetAttribute("_ConsecutiveWins",S.CustomWinstreakValue) end
    else _xd_notify("Custom Winstreak","Invalid",0.9) end
end
C.ClothesColor=Color3.fromRGB(255,255,255) C.ClothesColorEnabled=false
C.FakeSettings={["Custom Clothing Color"]=false}
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
    pcall(function()
        if C.ClothesColorEnabled then
            LP:SetAttribute("ClothingColor",C.ClothesColor) LP:SetAttribute("UniformColorValue",C.ClothesColor)
            LP:SetAttribute("ClothingColorToggle",true) LP:SetAttribute("SetUniformSkinEnabled",true)
        else
            LP:SetAttribute("ClothingColor",nil) LP:SetAttribute("UniformColorValue",nil)
            LP:SetAttribute("ClothingColorToggle",false) LP:SetAttribute("SetUniformSkinEnabled",false)
        end
    end)
end
function S.toggle_custom_uniform_color(on) C.ClothesColorEnabled=on S.UpdateVIPClothes() return true end
function S.set_uniform_color(c) if typeof(c)=="Color3" then C.ClothesColor=c if C.ClothesColorEnabled then S.UpdateVIPClothes() end end end
task.spawn(function() pcall(S.InitSettingDataSpoof) end)
S.FlySpeed=50
function S.toggle_fly(on)
    on=on and true or false
    local opFly=S._OpFly or {flying=false,keyDown=nil,keyUp=nil,m1=nil,m2=nil,velName="OpFlyVel",gyroName="OpFlyGyro",speed=1}
    S._OpFly=opFly
    local function clean()
        opFly.flying=false
        if opFly.keyDown then pcall(function() opFly.keyDown:Disconnect() end) opFly.keyDown=nil end
        if opFly.keyUp then pcall(function() opFly.keyUp:Disconnect() end) opFly.keyUp=nil end
        if opFly.m1 then pcall(function() opFly.m1:Disconnect() end) opFly.m1=nil end
        if opFly.m2 then pcall(function() opFly.m2:Disconnect() end) opFly.m2=nil end
        pcall(function()
            local hrp=_xd_getHRP()
            if hrp then
                local v=hrp:FindFirstChild(opFly.velName) if v then v:Destroy() end
                local g=hrp:FindFirstChild(opFly.gyroName) if g then g:Destroy() end
            end
            local h=_xd_getHum() if h then h.PlatformStand=false h.AutoRotate=true end
        end)
    end
    clean()
    if not on then return true end
    local isMobile=UIS.TouchEnabled and not UIS.KeyboardEnabled
    local c=_xd_getChar() local hum=_xd_getHum(c) local hrp=_xd_getHRP(c)
    if not hrp or not hum then return false end
    if isMobile then
        opFly.flying=true
        local bv=Instance.new("BodyVelocity") bv.Name=opFly.velName bv.MaxForce=Vector3.zero bv.Velocity=Vector3.new() bv.Parent=hrp
        local bg=Instance.new("BodyGyro") bg.Name=opFly.gyroName bg.MaxTorque=Vector3.new(9e9,9e9,9e9) bg.P=1000 bg.D=50 bg.Parent=hrp
        local cm=nil pcall(function() cm=require(LP.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule")) end)
        opFly.m2=RunService.RenderStepped:Connect(function()
            if not opFly.flying then return end
            local h2=_xd_getHRP() if not h2 then return end
            local v=h2:FindFirstChild(opFly.velName) local g=h2:FindFirstChild(opFly.gyroName) local hu=_xd_getHum()
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
        opFly.keyDown=UIS.InputBegan:Connect(function(input,gp)
            if gp then return end
            if input.KeyCode==Enum.KeyCode.W then keys.F=speed
            elseif input.KeyCode==Enum.KeyCode.S then keys.B=-speed
            elseif input.KeyCode==Enum.KeyCode.A then keys.L=-speed
            elseif input.KeyCode==Enum.KeyCode.D then keys.R=speed
            elseif input.KeyCode==Enum.KeyCode.E then keys.Q=speed*2
            elseif input.KeyCode==Enum.KeyCode.Q then keys.E=-speed*2 end
        end)
        opFly.keyUp=UIS.InputEnded:Connect(function(input)
            if input.KeyCode==Enum.KeyCode.W then keys.F=0
            elseif input.KeyCode==Enum.KeyCode.S then keys.B=0
            elseif input.KeyCode==Enum.KeyCode.A then keys.L=0
            elseif input.KeyCode==Enum.KeyCode.D then keys.R=0
            elseif input.KeyCode==Enum.KeyCode.E then keys.Q=0
            elseif input.KeyCode==Enum.KeyCode.Q then keys.E=0 end
        end)
    end
    return true
end
-- Rebel additions
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
        pcall(function() table.insert(t,string.lower(el.Name or "")) local p=el.Parent for i=1,4 do if p then table.insert(t,string.lower(p.Name or "")) p=p.Parent else break end end end)
        return table.concat(t," ")
    end
    local function isBad(el) local s=gatherText(el) for _,w in ipairs(badWords) do if string.find(s,w,1,true) then return true end end return false end
    local function fireBtn(el)
        if not el or isBad(el) then return false end
        local fired=false
        pcall(function() if firesignal then pcall(firesignal,el.MouseButton1Click) pcall(firesignal,el.Activated) pcall(firesignal,el.MouseButton1Down) pcall(firesignal,el.MouseButton1Up) fired=true end end)
        pcall(function() if getconnections then for _,sig in ipairs({el.MouseButton1Click,el.Activated,el.MouseButton1Down,el.MouseButton1Up}) do if sig then for _,c in pairs(getconnections(sig)) do pcall(function() if c.Fire then c:Fire() end end) fired=true end end end end end)
        return fired
    end
    local function byPath(parts)
        local pg=LP:FindFirstChild("PlayerGui") if not pg then return {} end
        local res={}
        for _,d in ipairs(pg:GetDescendants()) do
            if d:IsA("GuiButton") or d:IsA("TextButton") or d:IsA("ImageButton") then
                local chain={} local p=d for i=1,8 do if p and p~=pg then table.insert(chain,1,string.lower(p.Name or "")) p=p.Parent else break end end
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
        if not S.AutoBecomeGuardEnabled then return end
        S.AutoBecomeGuardTask=task.spawn(function() while S.AutoBecomeGuardEnabled do if not LP:GetAttribute("IsGuard") then doOnce() task.wait(0.12) continue end break end end)
    end
end
-- ===== BULLET TRACER =====
local btFadeStyles={ {name="Quad",style=Enum.EasingStyle.Quad},{name="Linear",style=Enum.EasingStyle.Linear},{name="Expo",style=Enum.EasingStyle.Exponential},{name="Back",style=Enum.EasingStyle.Back},{name="Circ",style=Enum.EasingStyle.Circular},{name="Sine",style=Enum.EasingStyle.Sine},{name="Quint",style=Enum.EasingStyle.Quint},{name="Bounce",style=Enum.EasingStyle.Bounce},{name="Elastic",style=Enum.EasingStyle.Elastic} }
local function btGetMuzzle()
    local char=LP.Character if not char then return nil end
    local hrp=char:FindFirstChild("HumanoidRootPart") if not hrp then return nil end
    local attr=char:GetAttribute("HoldingWeapon")
    if type(attr)=="string" and attr~="" then
        local w=char:FindFirstChild(attr)
        if w then
            local ff=w:FindFirstChild("FireFrom") if ff and ff:IsA("BasePart") then return ff.Position end
            local hd=w:FindFirstChild("Handle") if hd and hd:IsA("BasePart") then return hd.Position+hd.CFrame.LookVector*0.5 end
        end
    end
    return hrp.Position+hrp.CFrame.LookVector*1.5+Vector3.new(0,0.8,0)
end
local function btGetTarget(fromPos)
    local cam=Workspace.CurrentCamera if not cam then return nil end
    local vp=cam.ViewportSize local dir=cam:ViewportPointToRay(vp.X/2,vp.Y/2).Direction
    local rp=RaycastParams.new() rp.FilterType=Enum.RaycastFilterType.Exclude rp.FilterDescendantsInstances={LP.Character}
    local hit=Workspace:Raycast(fromPos,dir*C.BulletTracerRange,rp)
    if hit then return hit.Position end return fromPos+dir*C.BulletTracerRange
end
local function btSpawnLine(fromPos,toPos)
    local delta=toPos-fromPos local dist=delta.Magnitude if dist<1 then return end
    local dir=delta.Unit local a=fromPos+dir*C.BulletTracerStartOffset local b=toPos-dir*C.BulletTracerEndOffset
    local d2=(b-a).Magnitude if d2<0.3 then return end
    local mid=(a+b)/2 local cf=CFrame.lookAt(mid,b)
    local col=Color3.fromRGB(C.BulletTracerR,C.BulletTracerG,C.BulletTracerB)
    local th=C.BulletTracerThickness local lt=C.BulletTracerLifetime
    local style=btFadeStyles[C.BulletTracerFadeIdx or 1].style
    local T=TweenInfo.new(lt,style,Enum.EasingDirection.Out)
    local spd=math.max(50,tonumber(C.BulletTracerSpeed) or 800) local travelTime=dist/spd
    if travelTime<0.015 then travelTime=0.015 end
    local function mkPart(partSize,color,trans)
        local p=Instance.new("Part") p.Name="Xionix_BTracer" p.Anchored=true p.CanCollide=false
        p.CanQuery=false p.CanTouch=false p.CastShadow=false p.Material=Enum.Material.Neon
        p.Color=color p.Transparency=trans p.Size=partSize p.CFrame=cf p.Parent=workspace return p
    end
    local function animateGrow(p,w,h,fullLen)
        task.spawn(function()
            local t0=tick()
            while true do
                if S.unloaded or not p or not p.Parent then return end
                local t=(tick()-t0)/travelTime if t>=1 then t=1 end
                local sz=fullLen*t if sz<0.01 then sz=0.01 end
                p.Size=Vector3.new(w,h,sz) p.CFrame=CFrame.lookAt(a+dir*(sz/2),b)
                if t>=1 then break end
                RunService.Heartbeat:Wait()
            end
        end)
    end
    if C.BulletTracerGlow then
        local outer=mkPart(Vector3.new(th*3,th*3,0.01),col,math.clamp(C.BulletTracerOpacity+0.4,0,1))
        task.delay(lt+travelTime+0.1,function() pcall(function() outer:Destroy() end) end)
        animateGrow(outer,th*3,th*3,d2)
        task.delay(travelTime,function() if outer and outer.Parent then TweenService:Create(outer,T,{Transparency=1,Size=Vector3.new(0.01,0.01,d2)}):Play() end end)
    end
    local core=mkPart(Vector3.new(th,th,0.01),col,C.BulletTracerOpacity)
    if C.BulletTracerGlow then local l=Instance.new("PointLight") l.Color=col l.Brightness=3 l.Range=8 l.Parent=core end
    task.delay(lt+travelTime+0.1,function() pcall(function() core:Destroy() end) end)
    animateGrow(core,th,th,d2)
    task.delay(travelTime,function() if core and core.Parent then TweenService:Create(core,T,{Transparency=1,Size=Vector3.new(0.01,0.01,d2)}):Play() end end)
    if C.BulletTracerWhiteCore then
        local inner=mkPart(Vector3.new(th*0.3,th*0.3,0.01),Color3.new(1,1,1),math.clamp(C.BulletTracerOpacity+0.1,0,1))
        task.delay(lt+travelTime+0.1,function() pcall(function() inner:Destroy() end) end)
        animateGrow(inner,th*0.3,th*0.3,d2)
        task.delay(travelTime,function() if inner and inner.Parent then TweenService:Create(inner,T,{Transparency=1,Size=Vector3.new(0.005,0.005,d2)}):Play() end end)
    end
end
local function btOnShot()
    if not C.BulletTracer then return end
    local now=tick() if now-S.btLastShot<C.BulletTracerCooldown then return end
    S.btLastShot=now
    local fromPos=btGetMuzzle() if not fromPos then return end
    local toPos=btGetTarget(fromPos) if not toPos then return end
    btSpawnLine(fromPos,toPos)
end
local function btAttachAnimator(an)
    if not an then return end
    if S.btAnimConn then pcall(function() S.btAnimConn:Disconnect() end) S.btAnimConn=nil end
    S.btAnimConn=an.AnimationPlayed:Connect(function(tr)
        local a=tr.Animation if not a then return end
        local id=a.AnimationId if not SHOT_IDS[id] then return end
        local t=tick() if t-(S.btLastIdTime[id] or 0)<C.BulletTracerCooldown then return end
        S.btLastIdTime[id]=t btOnShot()
    end)
end
local function btWatchChar(char)
    if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid") if not hum then return end
    local an=hum:FindFirstChildOfClass("Animator")
    if an then btAttachAnimator(an)
    else local c c=hum.ChildAdded:Connect(function(ch) if ch:IsA("Animator") then btAttachAnimator(ch) pcall(function() c:Disconnect() end) end end) end
end
if LP.Character then btWatchChar(LP.Character) end
track(LP.CharacterAdded:Connect(function(ch) task.wait(0.5) btWatchChar(ch) end))
-- ===== ESP =====
local guardESPs={}
local playerESPs={}
local function clearAllGuardESP()
    for _,v in pairs(guardESPs) do
        pcall(function() if v.hl then v.hl:Destroy() end end)
        pcall(function() if v.nameBill then v.nameBill:Destroy() end end)
        pcall(function() if v.hpBar then v.hpBar:Destroy() end end)
        pcall(function() if v.distBill then v.distBill:Destroy() end end)
        pcall(function() if v.toolBill then v.toolBill:Destroy() end end)
        pcall(function() if v.tracer then v.tracer:Destroy() end end)
        pcall(function() if v.box then v.box:Destroy() end end)
    end
    table.clear(guardESPs)
end
local function clearAllPlayerESP()
    for _,v in pairs(playerESPs) do
        pcall(function() if v.hl then v.hl:Destroy() end end)
        pcall(function() if v.nameBill then v.nameBill:Destroy() end end)
        pcall(function() if v.hpBar then v.hpBar:Destroy() end end)
        pcall(function() if v.distBill then v.distBill:Destroy() end end)
        pcall(function() if v.toolBill then v.toolBill:Destroy() end end)
        pcall(function() if v.tracer then v.tracer:Destroy() end end)
        pcall(function() if v.box then v.box:Destroy() end end)
    end
    table.clear(playerESPs)
end
local function isGuardPlayer(char,plr)
    if not char or not plr then return false end
    if plr:GetAttribute("IsGuard")==true then return true end
    if char:FindFirstChild("GuardPlayerOutift") then return true end
    if char:FindFirstChild("G3SG1") then return true end
    return false
end
local function getCharHeightStuds(char)
    local hrp=char and char:FindFirstChild("HumanoidRootPart") if not hrp then return 5.5 end
    local minY,maxY=math.huge,-math.huge
    for _,p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then local y=p.Position.Y if y<minY then minY=y end if y>maxY then maxY=y end end end
    if minY==math.huge then return 5.5 end
    local h=maxY-minY if h<3 then h=3 end if h>10 then h=10 end return h
end
local function createESP(plr,char,hrp,hum,nameSize,hpGrad)
    local color=plr:GetAttribute("IsGuard") and guardESPColor() or playerESPColor()
    local darkColor=color:Lerp(Color3.new(0,0,0),0.35)
    local charHeight=getCharHeightStuds(char)
    ensureTracerGui() ensureOverlayGui()
    local hl=Instance.new("Highlight") hl.Name="Xionix_HL" hl.FillTransparency=0.4 hl.OutlineTransparency=0
    hl.FillColor=color hl.OutlineColor=darkColor hl.Adornee=char hl.Parent=char
    local nameBill=Instance.new("BillboardGui") nameBill.Name="Xionix_NAME" nameBill.Size=UDim2.fromOffset(360,26)
    nameBill.StudsOffset=Vector3.new(0,charHeight*0.5+0.6,0) nameBill.AlwaysOnTop=true nameBill.LightInfluence=0 nameBill.Adornee=hrp nameBill.Parent=char
    local container=Instance.new("Frame") container.BackgroundTransparency=1 container.Size=UDim2.fromOffset(0,24)
    container.AutomaticSize=Enum.AutomaticSize.X container.AnchorPoint=Vector2.new(0.5,0.5) container.Position=UDim2.fromScale(0.5,0.5) container.Parent=nameBill
    local layout=Instance.new("UIListLayout") layout.FillDirection=Enum.FillDirection.Horizontal
    layout.SortOrder=Enum.SortOrder.LayoutOrder layout.VerticalAlignment=Enum.VerticalAlignment.Center
    layout.HorizontalAlignment=Enum.HorizontalAlignment.Center layout.Padding=UDim.new(0,6) layout.Parent=container
    local hpChip=Instance.new("Frame") hpChip.LayoutOrder=1 hpChip.Size=UDim2.fromOffset(42,20)
    hpChip.BackgroundColor3=Color3.fromRGB(74,222,74) hpChip.BorderSizePixel=0 hpChip.Parent=container addCorner(hpChip,5)
    local hpChipStroke=Instance.new("UIStroke") hpChipStroke.Thickness=1.5 hpChipStroke.Transparency=0 hpChipStroke.Color=Color3.new(0,0,0)
    hpChipStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border hpChipStroke.Parent=hpChip
    local hpLbl=Instance.new("TextLabel") hpLbl.Size=UDim2.fromScale(1,1) hpLbl.BackgroundTransparency=1
    hpLbl.Font=Enum.Font.GothamBlack hpLbl.TextSize=13 hpLbl.TextColor3=Color3.new(1,1,1)
    hpLbl.TextStrokeTransparency=0 hpLbl.TextStrokeColor3=Color3.new(0,0,0) hpLbl.Text="[100]" hpLbl.Parent=hpChip
    local nl=Instance.new("TextLabel") nl.LayoutOrder=2 nl.BackgroundTransparency=1
    nl.AutomaticSize=Enum.AutomaticSize.X nl.Size=UDim2.fromOffset(0,24)
    nl.Font=espFont() nl.TextSize=nameSize or 17 nl.TextColor3=Color3.new(1,1,1)
    nl.TextStrokeTransparency=0 nl.TextStrokeColor3=Color3.new(0,0,0) nl.Text=plr.Name nl.Parent=container
    local toolBill=Instance.new("BillboardGui") toolBill.Size=UDim2.fromOffset(220,20)
    toolBill.StudsOffset=Vector3.new(0,-charHeight*0.5-1.2,0) toolBill.AlwaysOnTop=true
    toolBill.LightInfluence=0 toolBill.Adornee=hrp toolBill.Parent=char
    local tl=Instance.new("TextLabel") tl.Size=UDim2.new(1,0,1,0) tl.BackgroundTransparency=1
    tl.TextColor3=color tl.TextStrokeTransparency=0 tl.TextStrokeColor3=Color3.new(0,0,0) tl.Font=espFont()
    tl.TextSize=13 tl.Text="" tl.Parent=toolBill
    local hpBar=Instance.new("BillboardGui") hpBar.Size=UDim2.fromOffset(8,charHeight*24)
    hpBar.StudsOffset=Vector3.new(-2.5,0,0) hpBar.AlwaysOnTop=true hpBar.LightInfluence=0 hpBar.Adornee=hrp hpBar.Parent=char
    local hpBg=Instance.new("Frame") hpBg.Size=UDim2.fromScale(1,1) hpBg.AnchorPoint=Vector2.new(0.5,0.5)
    hpBg.Position=UDim2.fromScale(0.5,0.5) hpBg.BackgroundColor3=Color3.fromRGB(25,8,8) hpBg.BackgroundTransparency=0.2
    hpBg.BorderSizePixel=0 hpBg.Parent=hpBar
    local hpBgCorner=addCorner(hpBg,3)
    local hpFill=Instance.new("Frame") hpFill.Size=UDim2.fromScale(1,1) hpFill.BackgroundColor3=Color3.new(1,1,1)
    hpFill.BorderSizePixel=0 hpFill.AnchorPoint=Vector2.new(0,1) hpFill.Position=UDim2.fromScale(0,1) hpFill.Parent=hpBg
    local hpFillCorner=addCorner(hpFill,3)
    local hpGradient=Instance.new("UIGradient") hpGradient.Color=hpGrad or mkGrad5(80,255,80,180,255,60,255,200,40,255,120,60,255,40,40)
    hpGradient.Rotation=90 hpGradient.Parent=hpFill
    local distBill=Instance.new("BillboardGui") distBill.Size=UDim2.fromOffset(160,18)
    distBill.StudsOffset=Vector3.new(2.8,0,0) distBill.AlwaysOnTop=true distBill.LightInfluence=0 distBill.Adornee=hrp distBill.Parent=char
    local dl=Instance.new("TextLabel") dl.Size=UDim2.new(1,0,1,0) dl.BackgroundTransparency=1
    dl.TextColor3=color dl.TextStrokeTransparency=0 dl.TextStrokeColor3=Color3.new(0,0,0) dl.Font=Enum.Font.Code
    dl.TextSize=13 dl.Text="" dl.TextXAlignment=Enum.TextXAlignment.Left dl.Parent=distBill
    local tracer=Instance.new("Frame") tracer.AnchorPoint=Vector2.new(0.5,0.5) tracer.BorderSizePixel=0
    tracer.ZIndex=5 tracer.Visible=false tracer.BackgroundColor3=color tracer.Parent=S.tracerGui
    local box=Instance.new("Frame") box.BackgroundTransparency=1 box.BorderSizePixel=0 box.Visible=false box.ZIndex=4 box.Parent=S.overlayGui
    local boxStroke=Instance.new("UIStroke") boxStroke.Thickness=2 boxStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border boxStroke.Parent=box
    return {hl=hl,nameBill=nameBill,hpChip=hpChip,hpChipStroke=hpChipStroke,hpLbl=hpLbl,nameL=nl,
        toolBill=toolBill,toolL=tl,hpBar=hpBar,hpBg=hpBg,hpFill=hpFill,hpGradient=hpGradient,
        hpBgCorner=hpBgCorner,hpFillCorner=hpFillCorner,distBill=distBill,distL=dl,
        tracer=tracer,box=box,boxStroke=boxStroke,char=char,color=color,charHeight=charHeight}
end
local function destroyESP(e)
    if not e then return end
    pcall(function() if e.hl then e.hl:Destroy() end end)
    pcall(function() if e.nameBill then e.nameBill:Destroy() end end)
    pcall(function() if e.hpBar then e.hpBar:Destroy() end end)
    pcall(function() if e.distBill then e.distBill:Destroy() end end)
    pcall(function() if e.toolBill then e.toolBill:Destroy() end end)
    pcall(function() if e.tracer then e.tracer:Destroy() end end)
    pcall(function() if e.box then e.box:Destroy() end end)
end
local function updateESP()
    if S.unloaded then return end
    _G.__adEspDone=0 _G.__adEspTotal=0
    local guardOn=C.GuardESP local playerOn=C.PlayerESP
    if not (guardOn or playerOn) then
        if next(guardESPs) then clearAllGuardESP() end
        if next(playerESPs) then clearAllPlayerESP() end
        return
    end
    local myHrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=LP then
            _G.__adEspTotal=_G.__adEspTotal+1
            pcall(function()
                local char=plr.Character local hum=char and char:FindFirstChildOfClass("Humanoid") local hrp=char and char:FindFirstChild("HumanoidRootPart")
                local isGuard=C.GuardESP_ForceAll or isGuardPlayer(char,plr)
                local wG=guardOn and isGuard local wP=playerOn and not isGuard
                if hum and hrp and hum.Health>0 and (wG or wP) then
                    local maxD=wG and (C.GuardESP_MaxDist or 0) or (C.PlayerESP_MaxDist or 0)
                    local myP=myHrp and myHrp.Position or Vector3.zero
                    local dist=(myP-hrp.Position).Magnitude
                    if maxD>0 and dist>maxD then
                        if guardESPs[plr] then destroyESP(guardESPs[plr]) guardESPs[plr]=nil end
                        if playerESPs[plr] then destroyESP(playerESPs[plr]) playerESPs[plr]=nil end
                        return
                    end
                    _G.__adEspDone=_G.__adEspDone+1
                    local col=wG and guardESPColor() or playerESPColor()
                    local nS=wG and (C.GuardESP_NameSize or 17) or (C.PlayerESP_NameSize or 17)
                    local hG=wG and guardHPGrad() or playerHPGrad()
                    local tbl=wG and guardESPs or playerESPs
                    local oth=wG and playerESPs or guardESPs
                    if oth[plr] then destroyESP(oth[plr]) oth[plr]=nil end
                    if not tbl[plr] or tbl[plr].char~=char then
                        if tbl[plr] then destroyESP(tbl[plr]) tbl[plr]=nil end
                        tbl[plr]=createESP(plr,char,hrp,hum,nS,hG)
                    end
                    local e=tbl[plr]
                    if e then
                        local sH=wG and C.GuardESP_HP or (wP and C.PlayerESP_HP)
                        local sN=wG and C.GuardESP_Name or (wP and C.PlayerESP_Name)
                        local sT=wG and C.GuardESP_Tool or (wP and C.PlayerESP_Tool)
                        local sD=wG and C.GuardESP_Distance or (wP and C.PlayerESP_Distance)
                        local sHL=wG and C.GuardESP_Highlight or (wP and C.PlayerESP_Highlight)
                        local sTr=wG and C.GuardESP_Tracer or (wP and C.PlayerESP_Tracer)
                        local sBx=wG and C.GuardESP_Box or (wP and C.PlayerESP_Box)
                        e.showHPBar=sH e.showTracer=sTr e.showBox=sBx
                        e.boxColor=wG and guardBoxColor() or playerBoxColor()
                        e.boxThick=wG and (C.GuardESP_BoxThickness or 2) or (C.PlayerESP_BoxThickness or 2)
                        e.hpBarThickness=wG and (C.GuardESP_HPBarThickness or 8) or (C.PlayerESP_HPBarThickness or 8)
                        e.hpBarLength=wG and (C.GuardESP_HPBarLength or 1.5) or (C.PlayerESP_HPBarLength or 1.5)
                        e.hpBarRoundness=wG and (C.GuardESP_HPBarRoundness or 3) or (C.PlayerESP_HPBarRoundness or 3)
                        e.tracerColor=wG and guardTracerColor() or playerTracerColor()
                        e.nameBill.Enabled=sN and true or false
                        e.toolBill.Enabled=sT and true or false
                        if e.hl then e.hl.Enabled=sHL and true or false end
                        if sT then local tn=getToolRawName(char) if tn=="" then tn="- none -" end if e.toolL.Text~=tn then e.toolL.Text=tn end end
                        local ratio=math.clamp(hum.Health/math.max(hum.MaxHealth,1),0,1)
                        e.hpFill.Size=UDim2.fromScale(1,ratio)
                        if e.hpLbl then e.hpLbl.Text="["..tostring(math.floor(hum.Health+0.5)).."]" end
                        local chipBg=wG and C.GuardESP_HP_ChipBg or (wP and C.PlayerESP_HP_ChipBg)
                        local chipCol=wG and guardChipColor(ratio) or playerChipColor(ratio)
                        if e.hpChip then e.hpChip.BackgroundColor3=chipCol e.hpChip.BackgroundTransparency=chipBg and 0 or 1 end
                        if e.hpLbl then e.hpLbl.TextColor3=chipCol end
                        if e.hpChipStroke then local outlineOn=wG and C.GuardESP_HP_Outline or (wP and C.PlayerESP_HP_Outline) e.hpChipStroke.Enabled=(outlineOn and chipBg) and true or false end
                        if sD then if myHrp and hrp then e.distBill.Enabled=true e.distL.Text=string.format("[%d studs]",math.floor(dist+0.5)) else e.distBill.Enabled=false end else e.distBill.Enabled=false end
                        if e.tracer then e.tracer.BackgroundColor3=e.tracerColor end
                        if not wG and e.nameL then
                            local dn=plr.Name if C.PlayerESP_CustomName and C.PlayerESP_CustomName~="" then dn=C.PlayerESP_CustomName end
                            if e.nameL.Text~=dn then e.nameL.Text=dn end
                            if not C.PlayerESP_NameRainbow then e.nameL.TextColor3=Color3.new(1,1,1) end
                        end
                    end
                else
                    if guardESPs[plr] then destroyESP(guardESPs[plr]) guardESPs[plr]=nil end
                    if playerESPs[plr] then destroyESP(playerESPs[plr]) playerESPs[plr]=nil end
                end
            end)
        end
    end
end
task.spawn(function()
    while S.running and not S.unloaded do
        pcall(function()
            if C.GuardESP or C.PlayerESP then
                local cam=Workspace.CurrentCamera
                if cam then
                    local fov=math.rad(cam.FieldOfView) local vp=cam.ViewportSize local vpY=vp.Y
                    local camPos=cam.CFrame.Position local oX=vp.X/2 local oY=vp.Y/2 local tH=math.tan(fov/2)
                    if tH>0.01 then
                        local function upd(e)
                            if not e then return end
                            local hrp=e.char and e.char:FindFirstChild("HumanoidRootPart")
                            if e.hpBar then
                                if e.showHPBar and hrp then
                                    local d=(camPos-hrp.Position).Magnitude if d<1 then d=1 end
                                    local pps=vpY/(2*d*tH) local bw=e.hpBarThickness or 8 local bm=e.hpBarLength or 1.5
                                    local hPx=(e.charHeight or 5.5)*pps*bm if hPx>3500 then hPx=3500 end if hPx<20 then hPx=20 end
                                    e.hpBar.Enabled=true e.hpBar.Size=UDim2.fromOffset(bw,hPx)
                                    local rn=e.hpBarRoundness or 3
                                    pcall(function() if e.hpBgCorner then e.hpBgCorner.CornerRadius=UDim.new(0,rn) end if e.hpFillCorner then e.hpFillCorner.CornerRadius=UDim.new(0,rn) end end)
                                else e.hpBar.Enabled=false end
                            end
                            if e.tracer then
                                if not e.showTracer or not hrp then if e.tracer.Visible then e.tracer.Visible=false end
                                else
                                    local sp,onScreen=cam:WorldToViewportPoint(hrp.Position)
                                    local dx=sp.X-oX local dy=sp.Y-oY local bh=(sp.Z<0)
                                    if bh then dx=-dx dy=-dy end
                                    local rl=math.sqrt(dx*dx+dy*dy) local ux,uy
                                    if rl<0.001 then ux,uy=0,1 else ux=dx/rl uy=dy/rl end
                                    local tL=math.huge
                                    if ux>0.0001 then tL=math.min(tL,(vp.X-oX)/ux) end
                                    if ux<-0.0001 then tL=math.min(tL,-oX/ux) end
                                    if uy>0.0001 then tL=math.min(tL,(vp.Y-oY)/uy) end
                                    if uy<-0.0001 then tL=math.min(tL,-oY/uy) end
                                    if tL==math.huge or tL<1 then tL=1 end
                                    local tx,ty
                                    if onScreen and not bh then tx=sp.X ty=sp.Y else tx=oX+ux*tL ty=oY+uy*tL end
                                    local fdx=tx-oX local fdy=ty-oY local fl=math.sqrt(fdx*fdx+fdy*fdy)
                                    if fl<1 then fl=1 end
                                    local ang=math.deg(math.atan2(fdy,fdx))
                                    e.tracer.Visible=true e.tracer.Position=UDim2.fromOffset((oX+tx)/2,(oY+ty)/2)
                                    e.tracer.Size=UDim2.fromOffset(fl,1.5) e.tracer.Rotation=ang
                                end
                            end
                            if e.box and e.boxStroke then
                                if not e.showBox then if e.box.Visible then e.box.Visible=false end
                                else
                                    local char=e.char
                                    if char and char.Parent then
                                        local mnX,mnY,mxX,mxY=getCharScreenBounds(char,cam)
                                        if mnX then
                                            e.box.Visible=true e.box.Position=UDim2.fromOffset(mnX-4,mnY-4)
                                            e.box.Size=UDim2.fromOffset(mxX-mnX+8,mxY-mnY+8)
                                            e.boxStroke.Color=e.boxColor or Color3.new(1,1,1) e.boxStroke.Thickness=e.boxThick or 2
                                        elseif e.box.Visible then e.box.Visible=false end
                                    elseif e.box.Visible then e.box.Visible=false end
                                end
                            end
                        end
                        for _,e in pairs(guardESPs) do upd(e) end
                        for _,e in pairs(playerESPs) do upd(e) end
                    end
                end
            end
        end)
        RunService.RenderStepped:Wait()
    end
end)
task.spawn(function()
    while S.running and not S.unloaded do
        pcall(function()
            if C.PlayerESP and C.PlayerESP_NameRainbow then
                local h=(tick()*(C.PlayerESP_NameRainbowSpeed or 1.0))%1 local col=Color3.fromHSV(h,1,1)
                for _,e in pairs(playerESPs) do if e.nameL and e.nameL.Parent then pcall(function() e.nameL.TextColor3=col end) end end
            end
        end)
        RunService.RenderStepped:Wait()
    end
end)
-- ===== HALLOWEEN =====
local function _hlwCheck(n) return string.find(string.lower(tostring(n or "")),"cryptid",1,true)~=nil end
local function _hlwIsTarget(v)
    if not (v:IsA("Model") or v:IsA("BasePart")) then return false end
    if not _hlwCheck(v.Name) then return false end
    if v:IsA("BasePart") then local p=v.Parent if p and p:IsA("Model") and _hlwCheck(p.Name) then return false end end
    return true
end
local function _hlwModel(obj) if obj:IsA("Model") then return obj end return obj:FindFirstAncestorOfClass("Model") or obj end
local function _hlwSetup(obj)
    if S._halloween.objects[obj] then return end
    local model=_hlwModel(obj)
    local root=model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Head") or model.PrimaryPart or (model:IsA("BasePart") and model)
    if not root then return end
    local hl=Instance.new("Highlight") hl.Name="xionix_c_hl" hl.Parent=Camera hl.Adornee=model
    hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
    hl.FillColor=Color3.fromRGB(C.Halloween_ChamsR,C.Halloween_ChamsG,C.Halloween_ChamsB) hl.FillTransparency=0.5
    hl.OutlineColor=Color3.fromRGB(C.Halloween_ChamsOutlineR,C.Halloween_ChamsOutlineG,C.Halloween_ChamsOutlineB)
    hl.OutlineTransparency=C.Halloween_ChamsOutlineTransparency hl.Enabled=false
    local bb=Instance.new("BillboardGui") bb.Name="xionix_c_bb" bb.Size=UDim2.fromOffset(200,40)
    bb.StudsOffset=Vector3.new(0,3,0) bb.AlwaysOnTop=true bb.MaxDistance=math.huge bb.Adornee=root bb.Enabled=false bb.Parent=model
    local txt=Instance.new("TextLabel") txt.Size=UDim2.fromScale(1,1) txt.BackgroundTransparency=1
    txt.Font=Enum.Font.GothamBold txt.TextSize=C.Halloween_TextSize
    txt.TextColor3=Color3.fromRGB(C.Halloween_TextR,C.Halloween_TextG,C.Halloween_TextB)
    txt.TextStrokeTransparency=0.4 txt.TextStrokeColor3=Color3.new(0,0,0) txt.Parent=bb
    local tr,bx
    if Drawing then
        tr=Drawing.new("Line") tr.Color=Color3.fromRGB(C.Halloween_TracerR,C.Halloween_TracerG,C.Halloween_TracerB)
        tr.Thickness=C.Halloween_TracerThick tr.Transparency=1 tr.Visible=false
        bx=Drawing.new("Square") bx.Color=Color3.fromRGB(C.Halloween_BoxR,C.Halloween_BoxG,C.Halloween_BoxB)
        bx.Thickness=C.Halloween_BoxThick bx.Filled=false bx.Transparency=1 bx.Visible=false
    end
    S._halloween.objects[obj]={hl=hl,bb=bb,txt=txt,tr=tr,bx=bx,root=root,model=model}
end
local function _hlwCleanup(obj)
    local d=S._halloween.objects[obj] if not d then return end
    if d.hl then pcall(function() d.hl:Destroy() end) end
    if d.bb then pcall(function() d.bb:Destroy() end) end
    if d.tr then pcall(function() d.tr:Remove() end) end
    if d.bx then pcall(function() d.bx:Remove() end) end
    S._halloween.objects[obj]=nil
end
local function _hlwScan()
    if S._halloween.active then return end S._halloween.active=true
    task.spawn(function()
        local queue={Workspace} local i=1 local count=0
        while i<=#queue and not S.unloaded and S._halloween.active do
            local cur=queue[i] i=i+1
            for _,ch in ipairs(cur:GetChildren()) do
                if _hlwIsTarget(ch) then pcall(_hlwSetup,ch) end
                table.insert(queue,ch) count=count+1
                if count%500==0 then task.wait() end
            end
        end
    end)
end
local function _hlwClear()
    S._halloween.active=false
    for obj in pairs(S._halloween.objects) do _hlwCleanup(obj) end
    table.clear(S._halloween.objects)
end
track(Workspace.DescendantAdded:Connect(function(v)
    if S.unloaded or not S._halloween.active then return end
    if _hlwIsTarget(v) then task.defer(function() if v and v.Parent and not S.unloaded then pcall(_hlwSetup,v) end end) end
end))
task.spawn(function()
    while S.running and not S.unloaded do
        RunService.RenderStepped:Wait()
        if not S.unloaded and (C.Halloween_Chams or C.Halloween_Tracers or C.Halloween_Boxes or C.Halloween_Names or C.Halloween_Dist) then
            pcall(function()
                local char=LP.Character local hrp=char and char:FindFirstChild("HumanoidRootPart") if not hrp then return end
                local rbw=Color3.fromHSV((tick()*0.5)%1,1,1)
                local vp=Camera.ViewportSize local oX=vp.X/2 local oY=vp.Y/2
                for obj,d in pairs(S._halloween.objects) do
                    local root=d.root
                    if not root or not root.Parent or not obj.Parent then _hlwCleanup(obj)
                    else
                        local sp,onScr=Camera:WorldToViewportPoint(root.Position)
                        local dist=math.max(1,math.floor((hrp.Position-root.Position).Magnitude))
                        local inRange=dist>=C.Halloween_MinD and dist<=C.Halloween_MaxD
                        if C.Halloween_Chams and inRange then
                            d.hl.Enabled=true
                            d.hl.FillColor=C.Halloween_RainbowChams and rbw or Color3.fromRGB(C.Halloween_ChamsR,C.Halloween_ChamsG,C.Halloween_ChamsB)
                            d.hl.OutlineColor=C.Halloween_RainbowChams and rbw or Color3.fromRGB(C.Halloween_ChamsOutlineR,C.Halloween_ChamsOutlineG,C.Halloween_ChamsOutlineB)
                            d.hl.OutlineTransparency=C.Halloween_ChamsOutlineTransparency
                        else d.hl.Enabled=false end
                        if (C.Halloween_Names or C.Halloween_Dist) and inRange then
                            local tStr=""
                            if C.Halloween_Names then tStr=obj.Name end
                            if C.Halloween_Dist then if tStr~="" then tStr=tStr.." " end tStr=tStr.."["..dist.."m]" end
                            if tStr~="" then
                                d.bb.Enabled=true d.txt.Text=tStr
                                d.txt.TextColor3=C.Halloween_RainbowText and rbw or Color3.fromRGB(C.Halloween_TextR,C.Halloween_TextG,C.Halloween_TextB)
                                d.txt.TextSize=C.Halloween_TextSize
                            else d.bb.Enabled=false end
                        else d.bb.Enabled=false end
                        if d.bx then
                            if C.Halloween_Boxes and inRange and onScr and sp.Z>0 then
                                local baseH=(vp.Y/dist)*3 local h=baseH*C.Halloween_BoxScale local w=h/2
                                d.bx.Size=Vector2.new(w,h) d.bx.Position=Vector2.new(sp.X-w/2,sp.Y-h/2)
                                d.bx.Color=C.Halloween_RainbowBoxes and rbw or Color3.fromRGB(C.Halloween_BoxR,C.Halloween_BoxG,C.Halloween_BoxB)
                                d.bx.Thickness=C.Halloween_BoxThick d.bx.Visible=true
                            else d.bx.Visible=false end
                        end
                        if d.tr then
                            if C.Halloween_Tracers and inRange then
                                local dx=sp.X-oX local dy=sp.Y-oY local bh=(sp.Z<0) if bh then dx=-dx dy=-dy end
                                local tx,ty
                                if onScr and not bh then tx=sp.X ty=sp.Y
                                else
                                    local rl=math.sqrt(dx*dx+dy*dy) local ux,uy=0,1
                                    if rl>0.01 then ux=dx/rl uy=dy/rl end
                                    local tL=math.huge
                                    if ux>0 then tL=math.min(tL,(vp.X-oX)/ux) elseif ux<0 then tL=math.min(tL,-oX/ux) end
                                    if uy>0 then tL=math.min(tL,(vp.Y-oY)/uy) elseif uy<0 then tL=math.min(tL,-oY/uy) end
                                    if tL==math.huge or tL<1 then tL=1 end
                                    tx=oX+ux*tL ty=oY+uy*tL
                                end
                                if tx~=tx then tx=oX end if ty~=ty then ty=oY+100 end
                                tx=math.clamp(tx,0,vp.X) ty=math.clamp(ty,0,vp.Y)
                                d.tr.From=Vector2.new(oX,oY) d.tr.To=Vector2.new(tx,ty)
                                d.tr.Color=C.Halloween_RainbowTracers and rbw or Color3.fromRGB(C.Halloween_TracerR,C.Halloween_TracerG,C.Halloween_TracerB)
                                d.tr.Thickness=math.max(1,C.Halloween_TracerThick) d.tr.Visible=true
                            else d.tr.Visible=false end
                        end
                    end
                end
            end)
        end
    end
end)
-- ===== ONE CLICK DALGONA =====
local function setOneClickDalgona(v)
    local state=v and true or false if state==S.oneClickDalgona then return end
    S.oneClickDalgona=state
    if S.dalgonaConn then pcall(function() S.dalgonaConn:Disconnect() end) S.dalgonaConn=nil end
    if not state then
        for part,data in pairs(_G.__dalgonaCache) do if part and part.Parent then pcall(function() part.Position=data.Position part.Transparency=data.Transparency end) end end
        table.clear(_G.__dalgonaCache) return
    end
    table.clear(_G.__dalgonaCache)
    S.dalgonaConn=RunService.RenderStepped:Connect(function()
        if S.unloaded or not S.oneClickDalgona then return end
        pcall(function()
            local mouse=LP:GetMouse() if not mouse or not mouse.Hit then return end
            local effects=workspace:FindFirstChild("Effects") local outline=nil
            if effects then for _,c in pairs(effects:GetChildren()) do if c:IsA("Model") and string.match(c.Name,"Outline$") then outline=c break end end end
            if not outline then return end
            local pos=mouse.Hit.Position
            for _,child in ipairs(outline:GetChildren()) do
                if child:IsA("BasePart") then
                    if not _G.__dalgonaCache[child] then _G.__dalgonaCache[child]={Position=child.Position,Transparency=child.Transparency} end
                    child.Position=pos child.Transparency=1
                end
            end
        end)
    end)
end
-- ===== LIMB REMOVE =====
local function rebuildLimbCache()
    table.clear(S.handCache) table.clear(S.legCache) table.clear(S.torsoCache)
    local char=LP.Character if not char then return end
    local HN={LeftArm=true,RightArm=true,["Left Arm"]=true,["Right Arm"]=true,LeftUpperArm=true,RightUpperArm=true,LeftLowerArm=true,RightLowerArm=true,LeftHand=true,RightHand=true}
    local LN={LeftUpperLeg=true,LeftLowerLeg=true,LeftFoot=true,["Left Leg"]=true,RightUpperLeg=true,RightLowerLeg=true,RightFoot=true,["Right Leg"]=true}
    local TN={Torso=true,UpperTorso=true,LowerTorso=true}
    local HA={lefthand=true,righthand=true,leftgrip=true,rightgrip=true,leftwrist=true,rightwrist=true,leftcuff=true,rightcuff=true,leftglove=true,rightglove=true,leftarm=true,rightarm=true}
    local function isHA(acc)
        if not acc or not acc:IsA("Accessory") then return false end
        local n=string.lower(acc.Name)
        if n:find("glove") or n:find("hand") or n:find("wrist") or n:find("cuff") then return true end
        local h=acc:FindFirstChild("Handle")
        if h then for _,d in ipairs(h:GetChildren()) do if d:IsA("Attachment") and HA[string.lower(d.Name)] then return true end end end
        return false
    end
    for _,p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            if HN[p.Name] then table.insert(S.handCache,p)
            elseif LN[p.Name] then table.insert(S.legCache,p)
            elseif TN[p.Name] then table.insert(S.torsoCache,p)
            else local acc=p:FindFirstAncestorOfClass("Accessory") if acc and isHA(acc) then table.insert(S.handCache,p) end end
        end
    end
end
local function setCacheHidden(cache,hide)
    for i=1,#cache do
        local p=cache[i]
        if p and p.Parent then
            if hide then
                if S.origTransparency[p]==nil then S.origTransparency[p]=p.Transparency end
                p.LocalTransparencyModifier=1 p.Transparency=1
            else p.LocalTransparencyModifier=0 p.Transparency=S.origTransparency[p] or 0 end
        end
    end
end
local function applyRemoveHands(st) C.RemoveHands=st and true or false rebuildLimbCache() setCacheHidden(S.handCache,C.RemoveHands) return true end
local function applyRemoveLegs(st) C.RemoveLegs=st and true or false rebuildLimbCache() setCacheHidden(S.legCache,C.RemoveLegs) return true end
local function applyRemoveTorso(st) C.RemoveTorso=st and true or false rebuildLimbCache() setCacheHidden(S.torsoCache,C.RemoveTorso) return true end
local function ensureHandsLoop()
    if S.handsConn then return end
    S.handsConn=RunService.Heartbeat:Connect(function()
        if S.unloaded then return end
        if C.RemoveHands then setCacheHidden(S.handCache,true) end
        if C.RemoveLegs then setCacheHidden(S.legCache,true) end
        if C.RemoveTorso then setCacheHidden(S.torsoCache,true) end
    end)
    table.insert(S.conns,S.handsConn)
end
-- ===== MORPH =====
local MORPH_KRB_R15_MESH="rbxassetid://902942096"
local MORPH_KRB_R15_TEXTURE="rbxassetid://902843398"
local MORPH_KRB_R6_MESH="rbxassetid://101851696"
local MORPH_KRB_R6_TEXTURE="rbxassetid://101851254"
local MORPH_KRB_COLOR=Color3.fromRGB(64,64,64)
local MORPH_DEFAULT_FACE="rbxasset://textures/face.png"
local MORPH_COOLDOWN=13
local MORPH_NICK_COOLDOWN=120
local MORPH_SESSION_MAX=15
local function morphCheckRate(nick)
    local now=tick()
    if S.morphRate.session>=MORPH_SESSION_MAX then return false end
    if now-S.morphRate.lastMorph<MORPH_COOLDOWN then return false end
    if nick and S.morphRate.nickTimes[nick] and now-S.morphRate.nickTimes[nick]<MORPH_NICK_COOLDOWN then return false end
    return true
end
local function morphMarkRate(nick)
    local now=tick() S.morphRate.lastMorph=now S.morphRate.session=S.morphRate.session+1
    if nick then S.morphRate.nickTimes[nick]=now end
end
local function morphGetCachedUserId(nick)
    if S.morphCache.userId[nick] then return S.morphCache.userId[nick] end
    local ok,uid=pcall(function() return Players:GetUserIdFromNameAsync(nick) end)
    if ok and uid then S.morphCache.userId[nick]=uid return uid end
    return nil
end
local function morphApplyKorblox(char)
    if not char then return false end
    local hum=char:FindFirstChildOfClass("Humanoid") if not hum then return false end
    if hum.RigType==Enum.HumanoidRigType.R15 then
        local ru=char:FindFirstChild("RightUpperLeg") local rl=char:FindFirstChild("RightLowerLeg") local rf=char:FindFirstChild("RightFoot")
        if not (ru and rl and rf) then return false end
        if not S.morph.korbloxSaved.ru then S.morph.korbloxSaved.ru={meshId=ru.MeshId,textureId=ru.TextureID,color=ru.Color,tRL=rl.Transparency,tRF=rf.Transparency} end
        if ru.MeshId~=MORPH_KRB_R15_MESH then pcall(function() ru.MeshId=MORPH_KRB_R15_MESH ru.TextureID=MORPH_KRB_R15_TEXTURE end) end
        if rl.Transparency~=1 then rl.Transparency=1 end
        if rf.Transparency~=1 then rf.Transparency=1 end
        if ru.Color~=Color3.new(1,1,1) then ru.Color=Color3.new(1,1,1) end
        if ru.Transparency~=0 then ru.Transparency=0 end
        return true
    else
        local rightLeg=char:FindFirstChild("Right Leg") if not rightLeg then return false end
        if not S.morph.korbloxSaved.r6 then
            local savedMesh=nil
            for _,v in ipairs(rightLeg:GetChildren()) do if v:IsA("SpecialMesh") or v:IsA("CharacterMesh") then savedMesh=v:Clone() break end end
            S.morph.korbloxSaved.r6={color=rightLeg.Color,transparency=rightLeg.Transparency,mesh=savedMesh}
        end
        local existing=rightLeg:FindFirstChildOfClass("SpecialMesh")
        if not existing or existing.MeshId~=MORPH_KRB_R6_MESH then
            for _,v in ipairs(rightLeg:GetChildren()) do if v:IsA("SpecialMesh") or v:IsA("CharacterMesh") then v:Destroy() end end
            local mesh=Instance.new("SpecialMesh") mesh.MeshType=Enum.MeshType.FileMesh mesh.MeshId=MORPH_KRB_R6_MESH mesh.TextureId=MORPH_KRB_R6_TEXTURE mesh.Parent=rightLeg
        end
        if rightLeg.Color~=MORPH_KRB_COLOR then rightLeg.Color=MORPH_KRB_COLOR end
        if rightLeg.Transparency~=0 then rightLeg.Transparency=0 end
        return true
    end
end
local function morphRemoveKorblox(char)
    if not char then return false end
    local hum=char:FindFirstChildOfClass("Humanoid") if not hum then return false end
    if hum.RigType==Enum.HumanoidRigType.R15 then
        local ru=char:FindFirstChild("RightUpperLeg") local rl=char:FindFirstChild("RightLowerLeg") local rf=char:FindFirstChild("RightFoot")
        if ru and rl and rf and S.morph.korbloxSaved.ru then
            pcall(function() ru.MeshId=S.morph.korbloxSaved.ru.meshId or "" ru.TextureID=S.morph.korbloxSaved.ru.textureId or "" end)
            ru.Color=S.morph.korbloxSaved.ru.color or ru.Color rl.Transparency=S.morph.korbloxSaved.ru.tRL or 0 rf.Transparency=S.morph.korbloxSaved.ru.tRF or 0
            S.morph.korbloxSaved.ru=nil
        end
    else
        local rightLeg=char:FindFirstChild("Right Leg")
        if rightLeg and S.morph.korbloxSaved.r6 then
            for _,v in ipairs(rightLeg:GetChildren()) do if v:IsA("SpecialMesh") or v:IsA("CharacterMesh") then v:Destroy() end end
            rightLeg.Color=S.morph.korbloxSaved.r6.color or rightLeg.Color rightLeg.Transparency=S.morph.korbloxSaved.r6.transparency or 0
            if S.morph.korbloxSaved.r6.mesh then S.morph.korbloxSaved.r6.mesh:Clone().Parent=rightLeg end
            S.morph.korbloxSaved.r6=nil
        end
    end
    return true
end
local function morphSaveHeadState(char)
    local head=char:FindFirstChild("Head") if not head then return end
    if S.morph.headSaved and S.morph.headSaved.char==char then return end
    local decals={} for _,c in ipairs(head:GetChildren()) do if c:IsA("Decal") then table.insert(decals,{name=c.Name,face=c.Face,texture=c.Texture}) end end
    local meshes={} for _,c in ipairs(head:GetChildren()) do if c:IsA("SpecialMesh") then table.insert(meshes,c:Clone()) end end
    S.morph.headSaved={char=char,transparency=head.Transparency,canCollide=head.CanCollide,decals=decals,meshes=meshes}
end
local function morphApplyHeadless(char)
    if not char then return false end
    local head=char:FindFirstChild("Head") if not head then return false end
    morphSaveHeadState(char)
    for _,c in ipairs(head:GetChildren()) do if c:IsA("Decal") then c:Destroy() end if c:IsA("SpecialMesh") then c:Destroy() end end
    if head.Transparency~=1 then head.Transparency=1 end
    if head.CanCollide~=false then head.CanCollide=false end
    if head:IsA("MeshPart") then pcall(function() head.MeshId="" head.TextureID="" end) end
    return true
end
local function morphRemoveHeadless(char)
    if not char then return false end
    local head=char:FindFirstChild("Head") if not head then return false end
    if S.morph.headSaved and S.morph.headSaved.char==char then
        head.Transparency=S.morph.headSaved.transparency or 0 head.CanCollide=S.morph.headSaved.canCollide or true
        for _,c in ipairs(head:GetChildren()) do if c:IsA("Decal") then c:Destroy() end if c:IsA("SpecialMesh") then c:Destroy() end end
        for _,d in ipairs(S.morph.headSaved.decals) do local nd=Instance.new("Decal") nd.Name=d.name nd.Face=d.face nd.Texture=d.texture nd.Parent=head end
        for _,m in ipairs(S.morph.headSaved.meshes) do m:Clone().Parent=head end
        S.morph.headSaved=nil
    else head.Transparency=0 end
    return true
end
local function applyKorblox(st) local char=LP.Character if not char then return end if st then morphApplyKorblox(char) else morphRemoveKorblox(char) end end
local function applyHeadless(st) local char=LP.Character if not char then return end if st then morphApplyHeadless(char) else morphRemoveHeadless(char) end end
-- ===== HIDE NICK =====
local function isNickName(n)
    local cached=S.nickNameCache[n] if cached~=nil then return cached end
    local lower=string.lower(n) local result
    if lower:sub(1,4)=="_xd_" or lower:find("xd_",1,true) or lower:find("xionix",1,true) then result=false
    elseif lower:find("nametag") or lower:find("nick") or lower:find("displayname") or lower=="name" or lower:find("^name_") or lower:find("_name") then result=true
    else result=false end
    S.nickNameCache[n]=result return result
end
local function isNickByAdornee(obj)
    local ad=obj.Adornee if not ad then return false end
    local an=ad.Name return an=="Head" or an=="HumanoidRootPart" or an=="Torso" or an=="UpperTorso" or an=="LowerTorso"
end
local function isNickFast(obj)
    if not obj then return false end
    if obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then if isNickName(obj.Name) then return true end if isNickByAdornee(obj) then return true end end
    return false
end
local NICK_PARTS={"Head","HumanoidRootPart","Torso","UpperTorso","LowerTorso"}
local function setHumanoidTag(hum,hide)
    if not hum then return end
    if hide then
        if hum.DisplayDistanceType~=Enum.HumanoidDisplayDistanceType.None then hum.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None end
        if hum.NameDisplayDistance~=0 then hum.NameDisplayDistance=0 end
        if hum.HealthDisplayDistance~=0 then hum.HealthDisplayDistance=0 end
    else hum.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.Viewer hum.NameDisplayDistance=100 hum.HealthDisplayDistance=100 end
end
local function applyToChar(char,shouldHide)
    if not char or not char.Parent then return end
    local hum=char:FindFirstChildOfClass("Humanoid") if hum then setHumanoidTag(hum,shouldHide) end
    for i=1,#NICK_PARTS do
        local part=char:FindFirstChild(NICK_PARTS[i])
        if part then
            for _,d in ipairs(part:GetChildren()) do
                if d:IsA("BillboardGui") or d:IsA("SurfaceGui") then
                    if shouldHide then
                        if d.Enabled and isNickFast(d) then
                            if not S.hiddenNicks[d] then S.hiddenNicks[d]={enabled=true} end
                            d.Enabled=false
                        end
                    elseif S.hiddenNicks[d] then d.Enabled=S.hiddenNicks[d].enabled S.hiddenNicks[d]=nil end
                end
            end
        end
    end
end
local function watchPart(char,partName,shouldHideGetter)
    local part=char:FindFirstChild(partName) if not part then return end
    local key=tostring(char).."|"..partName.."|"..tostring(part) if S.watchedKeys[key] then return end
    S.watchedKeys[key]=true
    local c=part.ChildAdded:Connect(function(d)
        if S.unloaded then return end
        if not shouldHideGetter() then return end
        if d:IsA("BillboardGui") or d:IsA("SurfaceGui") then
            if d.Enabled and isNickFast(d) then
                if not S.hiddenNicks[d] then S.hiddenNicks[d]={enabled=true} end
                d.Enabled=false
            end
        end
    end)
    table.insert(S.perCharConns,c)
end
local function setupChar(char,isMe)
    if not char then return end
    local shouldHideGetter=isMe and function() return C.HideNick end or function() return C.HideOtherNames end
    applyToChar(char,shouldHideGetter())
    for _,pn in ipairs(NICK_PARTS) do watchPart(char,pn,shouldHideGetter) end
    local c=char.ChildAdded:Connect(function(d)
        if S.unloaded then return end
        if d.Name=="Head" or d.Name=="HumanoidRootPart" then
            if not d.Parent then return end
            applyToChar(char,shouldHideGetter()) watchPart(char,d.Name,shouldHideGetter)
        end
    end)
    table.insert(S.perCharConns,c)
end
local function refreshNicks()
    if LP.Character then setupChar(LP.Character,true) end
    for _,plr in ipairs(Players:GetPlayers()) do if plr~=LP and plr.Character then setupChar(plr.Character,false) end end
end
local function bindPlayer(plr)
    local isMe=(plr==LP)
    if plr.Character then setupChar(plr.Character,isMe) end
    local c=plr.CharacterAdded:Connect(function(ch) if S.unloaded then return end setupChar(ch,isMe) end)
    table.insert(S.perCharConns,c)
end
for _,plr in ipairs(Players:GetPlayers()) do bindPlayer(plr) end
local _pc=Players.PlayerAdded:Connect(bindPlayer)
table.insert(S.perCharConns,_pc)
RunService.RenderStepped:Connect(function()
    if S.unloaded then return end
    if not (C.HideNick or C.HideOtherNames) then return end
    if C.HideNick then
        local char=LP.Character
        if char then local hum=char:FindFirstChildOfClass("Humanoid") if hum then
            if hum.DisplayDistanceType~=Enum.HumanoidDisplayDistanceType.None then hum.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None end
            if hum.NameDisplayDistance~=0 then hum.NameDisplayDistance=0 end
            if hum.HealthDisplayDistance~=0 then hum.HealthDisplayDistance=0 end
        end end
    end
    if C.HideOtherNames then
        for _,plr in ipairs(Players:GetPlayers()) do if plr~=LP then
            local char=plr.Character
            if char then local hum=char:FindFirstChildOfClass("Humanoid") if hum then
                if hum.DisplayDistanceType~=Enum.HumanoidDisplayDistanceType.None then hum.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None end
                if hum.NameDisplayDistance~=0 then hum.NameDisplayDistance=0 end
                if hum.HealthDisplayDistance~=0 then hum.HealthDisplayDistance=0 end
            end end
        end end
    end
end)
-- ===== NOCLIP + INF JUMP =====
local _noclipActive=false _noclipDisabled={} _noclipFloorParts=setmetatable({},{__mode="k"})
local _noclipLastSafePos=nil _noclipLastSafeUpdate=0 _noclipFrame=0
local _noclipScanParams=OverlapParams.new() _noclipScanParams.FilterType=Enum.RaycastFilterType.Exclude _noclipScanParams.MaxParts=500 _noclipScanParams.RespectCanCollide=true
local _noclipOverlapAll=OverlapParams.new() _noclipOverlapAll.FilterType=Enum.RaycastFilterType.Exclude _noclipOverlapAll.MaxParts=200 _noclipOverlapAll.RespectCanCollide=false
local _noclipRayDown=RaycastParams.new() _noclipRayDown.FilterType=Enum.RaycastFilterType.Exclude _noclipRayDown.IgnoreWater=true
local function _noclipDetectFloor(pos,char)
    local set={} _noclipRayDown.FilterDescendantsInstances={char}
    local feetPos=Vector3.new(pos.X,pos.Y-2,pos.Z)
    for dx=-6,6,6 do for dz=-6,6,6 do
        local origin=feetPos+Vector3.new(dx,0,dz)
        local hit=workspace:Raycast(origin,Vector3.new(0,-200,0),_noclipRayDown)
        if hit and hit.Instance then set[hit.Instance]=true end
    end end
    return set
end
local function _noclipDisableAbove(pos,char)
    _noclipRayDown.FilterDescendantsInstances={char}
    local origin=Vector3.new(pos.X,pos.Y+3,pos.Z) local remaining=30
    for _=1,6 do
        local hit=workspace:Raycast(origin,Vector3.new(0,remaining,0),_noclipRayDown)
        if not hit or not hit.Instance then break end
        if hit.Instance:IsA("BasePart") and hit.Instance.CanCollide and not _noclipFloorParts[hit.Instance] then
            hit.Instance.CanCollide=false _noclipDisabled[hit.Instance]=true
        end
        local adv=(hit.Position-origin).Magnitude+0.5 if adv>=remaining then break end
        origin=origin+Vector3.new(0,adv,0) remaining=remaining-adv
    end
end
local function _noclipUpdate()
    if not _noclipActive or S.unloaded then return end
    local char=LP.Character if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart") local hum=char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    local pos=hrp.Position local vel=hrp.AssemblyLinearVelocity local feetY=pos.Y-3
    if vel.Y<-30 then return end
    _noclipScanParams.FilterDescendantsInstances={char} _noclipOverlapAll.FilterDescendantsInstances={char}
    local newFloor=_noclipDetectFloor(pos,char) for p in pairs(newFloor) do _noclipFloorParts[p]=true end
    if math.abs(vel.Y)<5 and hum.FloorMaterial~=Enum.Material.Air then
        if _noclipLastSafePos==nil or (tick()-_noclipLastSafeUpdate)>0.3 then _noclipLastSafePos=pos _noclipLastSafeUpdate=tick() end
    end
    if _noclipLastSafePos and pos.Y<_noclipLastSafePos.Y-25 then
        pcall(function() hrp.CFrame=CFrame.new(_noclipLastSafePos+Vector3.new(0,4,0)) hrp.AssemblyLinearVelocity=Vector3.zero hrp.AssemblyAngularVelocity=Vector3.zero end)
        return
    end
    local parts=workspace:GetPartBoundsInRadius(pos,35,_noclipScanParams)
    for _,p in ipairs(parts) do
        if p:IsA("BasePart") and not _noclipFloorParts[p] then
            local partTopY=p.Position.Y+p.Size.Y*0.5
            local horizDist=math.sqrt((p.Position.X-pos.X)^2+(p.Position.Z-pos.Z)^2)
            local isUnderMe=(horizDist<15) and (partTopY<=feetY+2)
            if not isUnderMe then p.CanCollide=false _noclipDisabled[p]=true end
        end
    end
    local climbCheck=workspace:GetPartBoundsInRadius(pos,12,_noclipOverlapAll) local insideWall=false
    for _,p in ipairs(climbCheck) do
        if p:IsA("BasePart") and _noclipDisabled[p] and not _noclipFloorParts[p] then insideWall=true break end
    end
    if insideWall then _noclipDisableAbove(pos,char) end
    for p in pairs(_noclipFloorParts) do if p.Parent and not p.CanCollide then p.CanCollide=true _noclipDisabled[p]=nil end end
    if _noclipFrame%120==0 then
        for p in pairs(_noclipDisabled) do
            if not p.Parent then _noclipDisabled[p]=nil
            elseif (p.Position-pos).Magnitude>200 then pcall(function() p.CanCollide=true end) _noclipDisabled[p]=nil end
        end
        for p in pairs(_noclipFloorParts) do if not p.Parent or (p.Position-pos).Magnitude>400 then _noclipFloorParts[p]=nil end end
    end
end
local function _startNoclip() if _noclipActive then return end _noclipActive=true _noclipLastSafePos=nil _noclipLastSafeUpdate=0 end
local function _stopNoclip()
    _noclipActive=false
    for p in pairs(_noclipDisabled) do if p.Parent then pcall(function() p.CanCollide=true end) end end
    table.clear(_noclipDisabled) table.clear(_noclipFloorParts) _noclipLastSafePos=nil
end
track(RunService.RenderStepped:Connect(function()
    if not _noclipActive or S.unloaded then return end
    _noclipFrame=_noclipFrame+1 if _noclipFrame%3~=0 then return end
    pcall(_noclipUpdate)
end))
track(UIS.JumpRequest:Connect(function()
    if S.unloaded or not C.InfJump then return end
    local char=LP.Character local hum=char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end))
-- ===== CONFIG =====
local CONFIG_FOLDER="XionixConfig"
local AUTOLOAD_FILE=CONFIG_FOLDER.."/_autoload.txt"
local function ensureFolder()
    if S.FILE.isfolder and S.FILE.makefolder then
        local ok,e=pcall(S.FILE.isfolder,CONFIG_FOLDER) if not ok or not e then pcall(S.FILE.makefolder,CONFIG_FOLDER) end
    end
end
local function configPath(name) return CONFIG_FOLDER.."/"..tostring(name)..".json" end
local function saveAutoloadName(name) if not S.FILE.writefile then return false end ensureFolder() return pcall(function() S.FILE.writefile(AUTOLOAD_FILE,tostring(name or "")) end) end
local function loadAutoloadName()
    if not S.FILE.readfile or not S.FILE.isfile then return "" end
    local ok,e=pcall(S.FILE.isfile,AUTOLOAD_FILE) if not ok or not e then return "" end
    local ok2,raw=pcall(S.FILE.readfile,AUTOLOAD_FILE) if not ok2 or not raw then return "" end
    return tostring(raw):gsub("%s","")
end
local function clearAutoloadName() if not S.FILE.delfile then return false end return pcall(S.FILE.delfile,AUTOLOAD_FILE) end
local function packStore(store)
    local t={}
    for k,v in pairs(store) do
        if typeof(v)=="Color3" then t[k]={v.R,v.G,v.B}
        elseif typeof(v)=="EnumItem" then t[k]=v.Name
        else t[k]=v end
    end
    return t
end
local function unpackStore(store,data)
    if type(data)~="table" then return end
    for k,v in pairs(data) do
        if k=="MenuKey" and type(v)=="string" then
            local ok,en=pcall(function() return Enum.KeyCode[v] end) if ok and en then store[k]=en end
        elseif store[k]~=nil and type(v)==type(store[k]) then store[k]=v end
    end
end
local function applyData(data)
    if data.C or data.H or data.anim then
        unpackStore(C,data.C or data.ui) unpackStore(H,data.H or data.hns)
        if type(data.anim)=="table" then
            for k,v in pairs(data.anim) do if HIT[tostring(k)]~=nil and not BAN[tostring(k)] then S.animEnabled[tostring(k)]=v and true or false end end
        end
    else unpackStore(C,data) end
    if C.FullBright and S.fbInst then S.fbInst.Brightness=tonumber(C.FullBrightIntensity) or 0.3 end
    makeViz() syncHooks() updateESP() makeFOVCircle()
end
local function saveConfig(name)
    name=name or S.currentConfigName if not S.FILE.writefile then return false end ensureFolder()
    local cn=tostring(name):gsub("[^%w%-%_]","") if cn=="" then cn="default" end
    S.currentConfigName=cn
    local pl={C=packStore(C),H=packStore(H),anim=S.animEnabled}
    return pcall(function() S.FILE.writefile(configPath(cn),HttpService:JSONEncode(pl)) end)
end
local function loadConfig(name)
    name=name or S.currentConfigName
    if not S.FILE.readfile or not S.FILE.isfile then return false end
    local path=configPath(name)
    local ok,e=pcall(S.FILE.isfile,path) if not ok or not e then return false end
    local ok2,raw=pcall(S.FILE.readfile,path) if not ok2 or not raw then return false end
    local ok3,data=pcall(function() return HttpService:JSONDecode(raw) end) if not ok3 or type(data)~="table" then return false end
    applyData(data) S.currentConfigName=tostring(name):gsub("[^%w%-%_]","") return true
end
local function listConfigs()
    local list={}
    if not S.FILE.listfiles or not S.FILE.isfolder then return list end
    local ok,e=pcall(S.FILE.isfolder,CONFIG_FOLDER) if not ok or not e then return list end
    local ok2,files=pcall(S.FILE.listfiles,CONFIG_FOLDER) if not ok2 or type(files)~="table" then return list end
    for _,f in ipairs(files) do local n=tostring(f):match("([^/\\]+)%.json$") if n and n~="" then table.insert(list,n) end end
    table.sort(list) return list
end
local function deleteConfig(name) if not S.FILE.delfile then return false end return pcall(S.FILE.delfile,configPath(name)) end
-- ===== TOGGLE WRAPPER =====
local _polls={}
local function T(tab,cfg,setter)
    local initial=cfg.Default or false local last=initial
    local obj=tab:Toggle({
        Title=cfg.Title, Desc=cfg.Desc or "", Default=initial,
        Callback=function(s)
            local state
            if s==true then state=true
            elseif s==false then state=false
            elseif s==nil then state=not last
            else local ok,v=pcall(function() return s.Value end) if ok and type(v)=="boolean" then state=v else state=not last end end
            if state~=last then last=state setter(state) end
        end
    })
    table.insert(_polls,{obj=obj,setter=setter,getLast=function() return last end,setLast=function(v) last=v end})
    return obj
end
task.spawn(function() while not S.unloaded do task.wait(0.15) for _,p in ipairs(_polls) do pcall(function() local v=p.obj.Value if type(v)=="boolean" and v~=p.getLast() then p.setLast(v) p.setter(v) end end) end end end)
-- ===== WINDOW =====
local Window=WindUI:CreateWindow({
    Title=SCRIPT_NAME.." "..SCRIPT_VERSION,
    Author="Xionix",
    Folder="Xionix_Dewamp",
    Size=UDim2.fromOffset(580,460),
    Transparent=true,
    Theme="Dark",
    User={Enabled=true,Anonymous=true},
})
-- ===== MENU TOGGLE (FIXED) =====
pcall(function() Window:SetToggleKey(nil) end)
local _menuOpen=true
local _lastMenuToggle=0
local function _doMenuToggle()
    if S.unloaded then return end
    _menuOpen=not _menuOpen
    local ok=pcall(function()
        if _menuOpen then
            if Window.Open then Window:Open()
            elseif Window.SetVisible then Window:SetVisible(true)
            elseif Window.Show then Window:Show() end
        else
            if Window.Close then Window:Close()
            elseif Window.SetVisible then Window:SetVisible(false)
            elseif Window.Hide then Window:Hide() end
        end
    end)
    if not ok then
        pcall(function()
            if Window.Visible~=nil then Window.Visible=_menuOpen end
            if Window.UIElements and Window.UIElements.Root then Window.UIElements.Root.Visible=_menuOpen end
        end)
    end
end
track(UIS.InputBegan:Connect(function(input,processed)
    if S.unloaded then return end
    if input.UserInputType~=Enum.UserInputType.Keyboard then return end
    if input.KeyCode~=C.MenuKey then return end
    if UIS:GetFocusedTextBox() then return end
    local now=tick() if now-_lastMenuToggle<0.2 then return end
    _lastMenuToggle=now
    _doMenuToggle()
end))
-- ===== TABS =====
local TabExtra=Window:Tab({Title="Extra",Icon="settings"})
TabExtra:Section({Title="Auto Dodge"})
T(TabExtra,{Title="Ultra Instinct",Desc="Auto dodge everything",Default=false},function(v) C.Enabled=v syncHooks() end)
TabExtra:Slider({Title="Radius (studs)",Step=1,Value={Min=1,Max=95,Default=C.Distance},Callback=function(v) C.Distance=v makeViz() end})
TabExtra:Slider({Title="Delay (s)",Step=0.01,Value={Min=0,Max=0.25,Default=C.Delay},Callback=function(v) C.Delay=v end})
TabExtra:Slider({Title="Min interval (s)",Step=0.01,Value={Min=0.02,Max=1.0,Default=C.MinInterval},Callback=function(v) C.MinInterval=v end})
TabExtra:Slider({Title="Anim watch min (s)",Step=0.05,Value={Min=0.05,Max=2.0,Default=C.AnimWatch},Callback=function(v) C.AnimWatch=v end})
TabExtra:Slider({Title="Watch after anim (s)",Step=0.05,Value={Min=0,Max=1.5,Default=C.WatchAfter},Callback=function(v) C.WatchAfter=v end})
T(TabExtra,{Title="Show radius",Desc="Visual circle",Default=false},function(v) C.RadiusVis=v makeViz() end)
TabExtra:Slider({Title="Radius visibility",Step=0.05,Value={Min=0.15,Max=0.95,Default=C.RadiusTransparency},Callback=function(v) C.RadiusTransparency=v end})
TabExtra:Colorpicker({Title="Radius Color",Default=uiRadiusColor(),Callback=function(col) C.RadiusR=math.floor(col.R*255+0.5) C.RadiusG=math.floor(col.G*255+0.5) C.RadiusB=math.floor(col.B*255+0.5) end})
TabExtra:Input({Title="UI Slot",Value="",Placeholder="auto = empty",Callback=function(v) C.ManualUISlot=string.upper(v or "") end})
TabExtra:Section({Title="RLGL Auto Dodge"})
T(TabExtra,{Title="RLGL Auto Dodge",Default=false},function(v) C.RLGL_AutoDodge=v end)
T(TabExtra,{Title="Only on red light",Default=true},function(v) C.RLGL_OnlyRedLight=v end)
T(TabExtra,{Title="Auto-dodge after timer 0",Default=true},function(v) C.RLGL_TimerEndDodge=v end)
TabExtra:Slider({Title="Delay after red (s)",Step=0.05,Value={Min=0.05,Max=2.0,Default=0.55},Callback=function(v) C.RLGL_RedDelay=v end})
TabExtra:Slider({Title="Interval (s)",Step=0.05,Value={Min=0.05,Max=2.0,Default=0.75},Callback=function(v) C.RLGL_MinInterval=v end})
TabExtra:Slider({Title="Velocity threshold",Step=0.1,Value={Min=0.1,Max=8.0,Default=0.1},Callback=function(v) C.RLGL_VelThreshold=v end})
TabExtra:Slider({Title="Delay after 0 (s)",Step=0.05,Value={Min=0,Max=3.0,Default=12},Callback=function(v) C.RLGL_TimerEndDelay=v end})
TabExtra:Slider({Title="Timer end interval (s)",Step=0.05,Value={Min=0.05,Max=2.0,Default=0.75},Callback=function(v) C.RLGL_TimerEndInterval=v end})
TabExtra:Slider({Title="Timer end max duration (s)",Step=1,Value={Min=3,Max=30,Default=9},Callback=function(v) C.RLGL_TimerEndMaxDuration=v end})
TabExtra:Section({Title="Movement"})
T(TabExtra,{Title="Infinite Jump",Default=false},function(v) C.InfJump=v end)
T(TabExtra,{Title="Noclip",Desc="Walk through walls",Default=false},function(v) C.Noclip=v if v then _startNoclip() else _stopNoclip() end end)
TabExtra:Section({Title="Custom Gravity"})
T(TabExtra,{Title="Custom Gravity",Default=false},function(v) S.toggle_custom_gravity(v) end)
TabExtra:Slider({Title="Gravity",Step=1,Value={Min=50,Max=500,Default=196.2},Callback=function(v) S.set_custom_gravity(v) end})
TabExtra:Section({Title="Custom Jump Power"})
T(TabExtra,{Title="Custom Jump Power",Default=false},function(v) S.toggle_custom_jump_power(v) end)
TabExtra:Slider({Title="Jump Power",Step=1,Value={Min=20,Max=200,Default=50},Callback=function(v) S.set_custom_jump_power(v) end})
TabExtra:Section({Title="Flight"})
T(TabExtra,{Title="Enable Flight",Default=false},function(v) S.toggle_fly(v) end)
TabExtra:Slider({Title="Fly Speed",Step=1,Value={Min=10,Max=300,Default=50},Callback=function(v) S.FlySpeed=v end})
TabExtra:Section({Title="Custom Clothes Color"})
T(TabExtra,{Title="Custom Clothes Color",Default=false},function(v) S.toggle_custom_uniform_color(v) end)
TabExtra:Colorpicker({Title="Clothes Color",Default=C.ClothesColor,Callback=function(c) S.set_uniform_color(c) end})
TabExtra:Section({Title="Custom Level"})
T(TabExtra,{Title="Custom Level",Default=false},function(v) S.toggle_custom_level(v) end)
TabExtra:Input({Title="Level Value",Value="1",Callback=function(v) S.set_custom_level(tonumber(v) or 1) end})
TabExtra:Section({Title="Custom Winstreak"})
T(TabExtra,{Title="Custom Winstreak",Default=false},function(v) S.toggle_custom_winstreak(v) end)
TabExtra:Input({Title="Winstreak Value",Value="0",Callback=function(v) S.set_custom_winstreak(tonumber(v) or 0) end})
TabExtra:Section({Title="Morph"})
local morphNick=""
TabExtra:Input({Title="Nickname",Value="",Placeholder="type nick",Callback=function(v) morphNick=v or "" end})
TabExtra:Button({Title="Morph",Icon="user-check",Callback=function()
    if morphNick=="" then return end
    if not morphCheckRate(morphNick) then return end
    S.morph._busy=true
    task.spawn(function()
        task.wait(0.4)
        local uid=morphGetCachedUserId(morphNick) if not uid then S.morph._busy=false return end
        local ok2,desc=pcall(function() return Players:GetHumanoidDescriptionFromUserIdAsync(uid) end) if not ok2 or not desc then S.morph._busy=false return end
        local bcColors,shirt,pants,graphic={},0,0,0 local faceId=0
        pcall(function() bcColors.head=desc.HeadColor end) pcall(function() bcColors.torso=desc.TorsoColor end)
        pcall(function() bcColors.leftArm=desc.LeftArmColor end) pcall(function() bcColors.rightArm=desc.RightArmColor end)
        pcall(function() bcColors.leftLeg=desc.LeftLegColor end) pcall(function() bcColors.rightLeg=desc.RightLegColor end)
        pcall(function() shirt=tonumber(desc.Shirt) or 0 end) pcall(function() pants=tonumber(desc.Pants) or 0 end)
        pcall(function() graphic=tonumber(desc.GraphicTShirt) or 0 end) pcall(function() faceId=tonumber(desc.Face) or 0 end)
        pcall(function() desc:Destroy() end)
        local oldChar=LP.Character if not oldChar then S.morph._busy=false return end
        S.morph.active=true S.morph._lastNick=morphNick
        local toDestroy={} for _,c in ipairs(oldChar:GetChildren()) do if c:IsA("Accessory") or c:IsA("Hat") or c:IsA("Shirt") or c:IsA("Pants") or c:IsA("ShirtGraphic") or c:IsA("BodyColors") or c:IsA("CharacterMesh") then table.insert(toDestroy,c) end end
        for _,c in ipairs(toDestroy) do pcall(function() c:Destroy() end) end
        task.wait(0.15)
        local newBC=Instance.new("BodyColors")
        if bcColors.head then pcall(function() newBC.HeadColor3=bcColors.head end) end
        if bcColors.torso then pcall(function() newBC.TorsoColor3=bcColors.torso end) end
        if bcColors.leftArm then pcall(function() newBC.LeftArmColor3=bcColors.leftArm end) end
        if bcColors.rightArm then pcall(function() newBC.RightArmColor3=bcColors.rightArm end) end
        if bcColors.leftLeg then pcall(function() newBC.LeftLegColor3=bcColors.leftLeg end) end
        if bcColors.rightLeg then pcall(function() newBC.RightLegColor3=bcColors.rightLeg end) end
        newBC.Parent=oldChar
        if shirt>0 then local s=Instance.new("Shirt") s.ShirtTemplate="rbxassetid://"..shirt s.Parent=oldChar end
        if pants>0 then local p=Instance.new("Pants") p.PantsTemplate="rbxassetid://"..pants p.Parent=oldChar end
        if graphic>0 then local g=Instance.new("ShirtGraphic") g.Graphic="rbxassetid://"..graphic g.Parent=oldChar end
        task.wait(0.1)
        local head=oldChar:FindFirstChild("Head")
        if head then
            for _,c in ipairs(head:GetChildren()) do if c:IsA("Decal") and c.Name=="face" then c:Destroy() end end
            local fd=Instance.new("Decal") fd.Name="face" fd.Face=Enum.NormalId.Front
            fd.Texture=faceId>0 and ("rbxassetid://"..faceId) or MORPH_DEFAULT_FACE fd.Parent=head
        end
        S.morph.activeKorblox=S.morph.korbloxManual or false
        if S.morph.activeKorblox then pcall(function() morphApplyKorblox(oldChar) end) end
        S.morph.activeHeadless=S.morph.headlessManual or false
        if S.morph.activeHeadless then pcall(function() morphApplyHeadless(oldChar) end) end
        morphMarkRate(morphNick) S.morph._busy=false
    end)
end})
TabExtra:Button({Title="Reset to my skin",Icon="rotate-ccw",Callback=function()
    S.morph.activeKorblox=false S.morph.activeHeadless=false S.morph.korbloxManual=false S.morph.headlessManual=false
    local char=LP.Character if char then pcall(function() morphRemoveKorblox(char) end) pcall(function() morphRemoveHeadless(char) end) end
end})
TabExtra:Section({Title="Cosmetics"})
T(TabExtra,{Title="Headless",Default=false},function(v) S.morph.headlessManual=v S.morph.activeHeadless=v if LP.Character then applyHeadless(v) end end)
T(TabExtra,{Title="Korblox Right Leg",Default=false},function(v) S.morph.korbloxManual=v S.morph.activeKorblox=v if LP.Character then applyKorblox(v) end end)
TabExtra:Section({Title="Instant Interact"})
T(TabExtra,{Title="Enable Instant Interact",Desc="Auto-fire all proximity prompts",Default=false},function(v) C.InstantInteract=v end)
TabExtra:Section({Title="Hide Overhead"})
T(TabExtra,{Title="Hide my nickname",Default=false},function(v) C.HideNick=v refreshNicks() end)
T(TabExtra,{Title="Hide other players names",Default=false},function(v) C.HideOtherNames=v refreshNicks() end)
TabExtra:Section({Title="Visual"})
T(TabExtra,{Title="Full Bright",Default=false},function(v) applyFullBright(v) end)
TabExtra:Slider({Title="FullBright intensity",Step=0.05,Value={Min=0.1,Max=3.0,Default=0.3},Callback=function(v) C.FullBrightIntensity=v if S.fbInst then S.fbInst.Brightness=v end end})
T(TabExtra,{Title="Remove Fog",Default=false},function(v) applyRemoveFog(v) end)
TabExtra:Section({Title="Remove Parts (client)"})
T(TabExtra,{Title="Remove Legs",Default=false},function(v) applyRemoveLegs(v) ensureHandsLoop() end)
T(TabExtra,{Title="Remove Hands",Default=false},function(v) applyRemoveHands(v) ensureHandsLoop() rebuildLimbCache() end)
T(TabExtra,{Title="Remove Torso",Default=false},function(v) applyRemoveTorso(v) ensureHandsLoop() rebuildLimbCache() end)
TabExtra:Section({Title="Extra"})
TabExtra:Button({Title="Open Infinite Yield",Icon="terminal",Callback=function() if not loadstring or not game.HttpGet then return end pcall(function() loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Infinite-Yield-95978"))() end) end})
TabExtra:Button({Title="Force Open Menu",Icon="maximize",Callback=function() pcall(function() Window:Open() end) _menuOpen=true end})
TabExtra:Button({Title="FULL UNLOAD",Icon="trash-2",Callback=function() if S.doFullUnload then pcall(S.doFullUnload) end end})
-- HnS TAB (Strict toggle REMOVED - strict is always ON)
local TabHnS=Window:Tab({Title="HnS",Icon="users"})
TabHnS:Section({Title="HnS Dodge"})
T(TabHnS,{Title="HnS Dodge",Desc="Strict mode always on - only dodges real hit animations",Default=false},function(v) H.Enabled=v syncHooks() end)
TabHnS:Slider({Title="Radius (studs)",Step=1,Value={Min=1,Max=95,Default=H.Distance},Callback=function(v) H.Distance=v makeViz() end})
TabHnS:Slider({Title="Delay (s)",Step=0.01,Value={Min=0,Max=0.25,Default=H.Delay},Callback=function(v) H.Delay=v end})
TabHnS:Slider({Title="Min interval (s)",Step=0.01,Value={Min=0.02,Max=1.0,Default=H.MinInterval},Callback=function(v) H.MinInterval=v end})
TabHnS:Section({Title="Radius Visualizer"})
T(TabHnS,{Title="Show radius",Default=false},function(v) H.RadiusVis=v makeViz() end)
TabHnS:Colorpicker({Title="HnS Radius Color",Default=hnsRadiusColor(),Callback=function(col) H.RadiusR=math.floor(col.R*255+0.5) H.RadiusG=math.floor(col.G*255+0.5) H.RadiusB=math.floor(col.B*255+0.5) end})
TabHnS:Section({Title="Slot"})
TabHnS:Input({Title="HnS Slot",Value="",Placeholder="auto = empty",Callback=function(v) C.ManualHnSSlot=string.upper(v or "") end})
-- Lights Out Tab (NEW)
local TabLO=Window:Tab({Title="Lights Out",Icon="moon"})
TabLO:Section({Title="Lights Out"})
T(TabLO,{Title="Safezone TP",Desc="TP to safe; disable returns you",Default=false},function(v) S.toggle_lights_out_safezone(v) end)
T(TabLO,{Title="Vampire Lightning",Desc="Night vision color correction",Default=false},function(v) S.toggle_vampire_vision(v) end)
-- Hide and Seek Tab (NEW)
local TabHNS2=Window:Tab({Title="Hide and Seek",Icon="eye-off"})
TabHNS2:Section({Title="Teleports"})
TabHNS2:Button({Title="TP to Spawn",Callback=function() S.teleport_to_spawn() end})
TabHNS2:Button({Title="TP to Hider",Callback=function() S.teleport_to_hider() end})
TabHNS2:Button({Title="TP to Seeker",Callback=function() S.teleport_to_seeker() end})
TabHNS2:Section({Title="ESP"})
T(TabHNS2,{Title="ESP Dropped Keys",Default=false},function(v) S.toggle_key_esp(v) end)
T(TabHNS2,{Title="ESP Exit Doors",Default=false},function(v) S.toggle_exit_door_esp(v) end)
T(TabHNS2,{Title="ESP Spikes",Default=false},function(v) S.toggle_spikes_esp(v) end)
TabHNS2:Section({Title="Utilities"})
T(TabHNS2,{Title="Spikes Kill",Default=false},function(v) S.toggle_spikes_kill(v) end)
T(TabHNS2,{Title="Anti-Spikes",Default=false},function(v) S.toggle_anti_spikes(v) end)
-- Jump Rope Tab (NEW)
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
-- Tug of War Tab (NEW)
local TabTug=Window:Tab({Title="Tug of War",Icon="swords"})
TabTug:Section({Title="Tug of War"})
T(TabTug,{Title="Anti Miss QTE",Default=false},function(v) S.toggle_tug_of_war_auto_qte_miss(v) end)
T(TabTug,{Title="Auto Pull (OP)",Default=false},function(v) S.toggle_tug_auto_pull_op(v) end)
-- Glass Bridge Tab (NEW)
local TabGB=Window:Tab({Title="Glass Bridge",Icon="layers"})
TabGB:Section({Title="Utilities"})
TabGB:Button({Title="TP to End",Callback=function() S.gb_tp_end() end})
T(TabGB,{Title="AntiBreak Glass",Default=false},function(v) S.toggle_anti_break(v) end)
-- Mingle Tab (NEW)
local TabM=Window:Tab({Title="Mingle",Icon="users"})
TabM:Section({Title="Mingle"})
T(TabM,{Title="Void Kill",Default=false},function(v) S.toggle_mingle_void_kill(v) end)
-- SkySquid Tab (NEW)
local TabSS=Window:Tab({Title="SkySquid / Squid",Icon="cloud"})
TabSS:Section({Title="SkySquid"})
T(TabSS,{Title="Auto TP on Fall",Default=false},function(v) S.toggle_auto_respawn_on_fall(v) end)
T(TabSS,{Title="Void Kill",Default=false},function(v) S.toggle_void_kill(v) end)
T(TabSS,{Title="Anti Fall",Default=false},function(v) S.toggle_sky_squid_anti_fall(v) end)
TabSS:Section({Title="Orbit Kill Aura"})
T(TabSS,{Title="Enable Orbit",Default=false},function(v) S.toggle_orbit_killaura(v) end)
TabSS:Slider({Title="Orbit Radius",Step=1,Value={Min=1,Max=10,Default=3},Callback=function(v) S.OrbitRadius=math.clamp(tonumber(v) or 3,1,10) end})
TabSS:Slider({Title="Orbit Speed",Step=1,Value={Min=1,Max=10,Default=10},Callback=function(v) S.OrbitSpeed=math.clamp(tonumber(v) or 10,1,10) end})
T(TabSS,{Title="Orbit AntiHit",Default=false},function(v) S.OrbitAntiHitEnabled=v end)
-- Pentathlon Tab (NEW)
local TabPen=Window:Tab({Title="Pentathlon",Icon="trophy"})
TabPen:Section({Title="Auto Minigames"})
T(TabPen,{Title="Auto Ddakji",Default=false},function(v) S.toggle_auto_ddakji(v) end)
T(TabPen,{Title="Auto Flying Stone",Default=false},function(v) S.toggle_auto_flying_stone(v) end)
T(TabPen,{Title="Auto Gonggi",Default=false},function(v) S.toggle_auto_gonggi(v) end)
T(TabPen,{Title="Auto Spinning Top",Default=false},function(v) S.toggle_auto_spinning_top(v) end)
T(TabPen,{Title="Auto Jegi",Default=false},function(v) S.toggle_auto_jegi(v) end)
-- Rebel Tab
local TabRebel=Window:Tab({Title="Rebel",Icon="crosshair"})
TabRebel:Section({Title="Auto Become Guard"})
T(TabRebel,{Title="Auto Become Guard",Default=false},function(v) S.toggle_auto_become_guard(v) end)
TabRebel:Dropdown({Title="Guard Tier",Values={"Circle","Triangle","Square"},Value="Circle",Callback=function(v) S.set_guard_tier(v) end})
TabRebel:Section({Title="Silent Aim"})
T(TabRebel,{Title="Silent Aim",Default=false},function(v) C.RebelSilentAim=v if v then hookCombat() end end)
T(TabRebel,{Title="Only visible",Default=false},function(v) C.RebelSilentAimVisibleCheck=v end)
TabRebel:Slider({Title="FOV Radius (px)",Step=5,Value={Min=10,Max=1200,Default=C.RebelFOV},Callback=function(v) C.RebelFOV=v refreshFOVCircle() end})
TabRebel:Section({Title="FOV Circle"})
T(TabRebel,{Title="Enable FOV Circle",Default=false},function(v) C.RebelFOVCircle=v makeFOVCircle() end)
T(TabRebel,{Title="Neon glow",Default=true},function(v) C.RebelFOVNeon=v makeFOVCircle() end)
T(TabRebel,{Title="Black outline",Default=true},function(v) C.RebelFOVBlackOutline=v makeFOVCircle() end)
TabRebel:Slider({Title="Outline thickness",Step=1,Value={Min=1,Max=20,Default=5},Callback=function(v) C.RebelFOV_OutlineThickness=v refreshFOVCircle() end})
TabRebel:Slider({Title="Circle line width",Step=0.1,Value={Min=0.5,Max=15,Default=1.6},Callback=function(v) C.RebelFOVCircleWidth=v end})
TabRebel:Colorpicker({Title="FOV Color",Default=rebelFOVColor(),Callback=function(col) C.RebelFOVR=math.floor(col.R*255+0.5) C.RebelFOVG=math.floor(col.G*255+0.5) C.RebelFOVB=math.floor(col.B*255+0.5) C.FOVUseCustom=false C.FOVRainbow=false stopFovRainbow() makeFOVCircle() end})
TabRebel:Colorpicker({Title="Outline Color",Default=rebelOutlineColor(),Callback=function(col) C.RebelFOV_OutlineR=math.floor(col.R*255+0.5) C.RebelFOV_OutlineG=math.floor(col.G*255+0.5) C.RebelFOV_OutlineB=math.floor(col.B*255+0.5) C.FOVRainbow=false stopFovRainbow() makeFOVCircle() end})
TabRebel:Section({Title="FOV Rainbow"})
T(TabRebel,{Title="Rainbow FOV",Default=false},function(v) C.FOVRainbow=v if v then startFovRainbow() else stopFovRainbow() makeFOVCircle() end end)
TabRebel:Slider({Title="Blend speed",Step=0.05,Value={Min=0.1,Max=3.0,Default=0.5},Callback=function(v) C.RebelFOVBlendSpeed=v end})
TabRebel:Button({Title="Mode 1: Cycle hue",Icon="palette",Callback=function() C.FOVRainbowMode=1 C.FOVRainbow=true makeFOVCircle() startFovRainbow() end})
TabRebel:Button({Title="Mode 2: Wave",Icon="palette",Callback=function() C.FOVRainbowMode=2 C.FOVRainbow=true makeFOVCircle() startFovRainbow() end})
TabRebel:Button({Title="Mode 3: Gradient blend",Icon="palette",Callback=function() C.FOVRainbowMode=3 C.FOVRainbow=true makeFOVCircle() startFovRainbow() end})
TabRebel:Button({Title="Mode 4: Breathing pulse",Icon="palette",Callback=function() C.FOVRainbowMode=4 C.FOVRainbow=true makeFOVCircle() startFovRainbow() end})
TabRebel:Button({Title="Mode 5: Aurora",Icon="palette",Callback=function() C.FOVRainbowMode=5 C.FOVRainbow=true makeFOVCircle() startFovRainbow() end})
TabRebel:Button({Title="Mode 6: FUSION",Icon="palette",Callback=function() C.FOVRainbowMode=6 C.FOVRainbow=true makeFOVCircle() startFovRainbow() end})
TabRebel:Section({Title="Custom FOV Colors (1-9)"})
T(TabRebel,{Title="Use custom color",Default=false},function(v) C.FOVUseCustom=v makeFOVCircle() if C.FOVRainbow then startFovRainbow() end end)
local function _setFovSlot(idx,col)
    local r=math.floor(col.R*255+0.5) local g=math.floor(col.G*255+0.5) local b=math.floor(col.B*255+0.5)
    if idx==1 then C.FOVCustomR1,C.FOVCustomG1,C.FOVCustomB1=r,g,b
    elseif idx==2 then C.FOVCustomR2,C.FOVCustomG2,C.FOVCustomB2=r,g,b
    elseif idx==3 then C.FOVCustomR3,C.FOVCustomG3,C.FOVCustomB3=r,g,b
    elseif idx==4 then C.FOVCustomR4,C.FOVCustomG4,C.FOVCustomB4=r,g,b
    elseif idx==5 then C.FOVCustomR5,C.FOVCustomG5,C.FOVCustomB5=r,g,b
    elseif idx==6 then C.FOVCustomR6,C.FOVCustomG6,C.FOVCustomB6=r,g,b
    elseif idx==7 then C.FOVCustomR7,C.FOVCustomG7,C.FOVCustomB7=r,g,b
    elseif idx==8 then C.FOVCustomR8,C.FOVCustomG8,C.FOVCustomB8=r,g,b
    elseif idx==9 then C.FOVCustomR9,C.FOVCustomG9,C.FOVCustomB9=r,g,b end
    if C.FOVUseCustom then makeFOVCircle() if C.FOVRainbow then startFovRainbow() end end
end
for _i=1,9 do
    local _idx=_i
    TabRebel:Colorpicker({Title="Slot ".._idx,Default=customFOVColor(_idx),Callback=function(col) _setFovSlot(_idx,col) end})
    TabRebel:Button({Title="Use slot ".._idx,Icon="check",Callback=function() C.FOVCustomIdx=_idx C.FOVUseCustom=true makeFOVCircle() if C.FOVRainbow then startFovRainbow() end end})
end
TabRebel:Section({Title="Target Filter"})
T(TabRebel,{Title="Target players",Default=true},function(v) C.RebelTargetPlayers=v end)
T(TabRebel,{Title="Target NPC guards",Default=true},function(v) C.RebelTargetNPCs=v end)
TabRebel:Section({Title="Body Parts"})
T(TabRebel,{Title="Head",Default=true},function(v) C.RebelBodyHead=v end)
T(TabRebel,{Title="Torso",Default=true},function(v) C.RebelBodyTorso=v end)
T(TabRebel,{Title="HumanoidRootPart",Default=false},function(v) C.RebelBodyHRP=v end)
T(TabRebel,{Title="Left Arm",Default=false},function(v) C.RebelBodyLeftArm=v end)
T(TabRebel,{Title="Right Arm",Default=false},function(v) C.RebelBodyRightArm=v end)
T(TabRebel,{Title="Left Leg",Default=false},function(v) C.RebelBodyLeftLeg=v end)
T(TabRebel,{Title="Right Leg",Default=false},function(v) C.RebelBodyRightLeg=v end)
TabRebel:Section({Title="Aimbot"})
T(TabRebel,{Title="Enable Aimbot",Default=false},function(v) C.RebelAimbot=v if v then startAimbot() else stopAimbot() end end)
T(TabRebel,{Title="Only visible",Default=false},function(v) C.RebelAimbotVisibleCheck=v end)
T(TabRebel,{Title="Hold RMB",Default=false},function(v) C.RebelAimbotHoldKey=v end)
TabRebel:Slider({Title="Smooth",Step=0.05,Value={Min=0.05,Max=5.0,Default=1.0},Callback=function(v) C.RebelAimbotSmooth=v end})
TabRebel:Section({Title="Gun Mods"})
T(TabRebel,{Title="No Recoil & Spread",Default=false},function(v) C.RebelNoRecoil=v if v then hookCombat() end end)
TabRebel:Section({Title="Bullet Tracer"})
T(TabRebel,{Title="Enable Bullet Tracer",Default=false},function(v) C.BulletTracer=v end)
T(TabRebel,{Title="Glow",Default=true},function(v) C.BulletTracerGlow=v end)
T(TabRebel,{Title="White core",Default=true},function(v) C.BulletTracerWhiteCore=v end)
TabRebel:Colorpicker({Title="Tracer Color",Default=Color3.fromRGB(C.BulletTracerR,C.BulletTracerG,C.BulletTracerB),Callback=function(col) C.BulletTracerR=math.floor(col.R*255+0.5) C.BulletTracerG=math.floor(col.G*255+0.5) C.BulletTracerB=math.floor(col.B*255+0.5) end})
TabRebel:Slider({Title="Thickness",Step=0.01,Value={Min=0.05,Max=1.0,Default=0.20},Callback=function(v) C.BulletTracerThickness=v end})
TabRebel:Slider({Title="Speed (studs/s)",Step=50,Value={Min=50,Max=5000,Default=800},Callback=function(v) C.BulletTracerSpeed=v end})
TabRebel:Slider({Title="Lifetime (s)",Step=0.05,Value={Min=0.1,Max=5.0,Default=2.00},Callback=function(v) C.BulletTracerLifetime=v end})
TabRebel:Slider({Title="Range (studs)",Step=25,Value={Min=50,Max=2000,Default=1050},Callback=function(v) C.BulletTracerRange=v end})
TabRebel:Slider({Title="Start offset",Step=0.1,Value={Min=0,Max=5,Default=0.30},Callback=function(v) C.BulletTracerStartOffset=v end})
TabRebel:Slider({Title="End offset",Step=0.1,Value={Min=0,Max=5,Default=0.00},Callback=function(v) C.BulletTracerEndOffset=v end})
TabRebel:Slider({Title="Opacity",Step=0.01,Value={Min=0,Max=0.5,Default=0.00},Callback=function(v) C.BulletTracerOpacity=v end})
TabRebel:Slider({Title="Cooldown (s)",Step=0.01,Value={Min=0.01,Max=0.5,Default=0.03},Callback=function(v) C.BulletTracerCooldown=v end})
local btFadeLabels={"Quad","Linear","Expo","Back","Circ","Sine","Quint","Bounce","Elastic"}
TabRebel:Button({Title="Fade: "..btFadeLabels[C.BulletTracerFadeIdx or 1],Icon="sparkles",Callback=function() C.BulletTracerFadeIdx=(C.BulletTracerFadeIdx or 1)+1 if C.BulletTracerFadeIdx>#btFadeLabels then C.BulletTracerFadeIdx=1 end end})
TabRebel:Section({Title="Auto Brew"})
T(TabRebel,{Title="Auto brew + collect",Default=false},function(v) C.AutoBrew=v if v then startBrewLoop() else stopBrewLoop() end end)
TabRebel:Input({Title="Brew key",Value="E",Placeholder="E",Callback=function(v) local u=string.upper(v or "E") if u=="" then u="E" end C.AutoBrewSlot=u end})
TabRebel:Slider({Title="Cycle cooldown (s)",Step=0.5,Value={Min=0.5,Max=30,Default=1},Callback=function(v) C.AutoBrewInterval=v end})
-- Halloween Tab
local TabHallow=Window:Tab({Title="Halloween",Icon="ghost"})
TabHallow:Section({Title="Cryptid ESP"})
TabHallow:Paragraph({Title="Scans for objects with 'cryptid' in name."})
T(TabHallow,{Title="Chams (Highlight)",Default=false},function(v) C.Halloween_Chams=v if v then _hlwScan() end end)
T(TabHallow,{Title="Tracers (Lines)",Default=false},function(v) C.Halloween_Tracers=v if v then _hlwScan() end end)
T(TabHallow,{Title="2D Boxes",Default=false},function(v) C.Halloween_Boxes=v if v then _hlwScan() end end)
T(TabHallow,{Title="Show Name",Default=false},function(v) C.Halloween_Names=v if v then _hlwScan() end end)
T(TabHallow,{Title="Show Distance",Default=false},function(v) C.Halloween_Dist=v if v then _hlwScan() end end)
TabHallow:Section({Title="Distance Filter"})
TabHallow:Slider({Title="Min Distance (studs)",Step=10,Value={Min=0,Max=5000,Default=0},Callback=function(v) C.Halloween_MinD=v end})
TabHallow:Slider({Title="Max Distance (studs)",Step=10,Value={Min=0,Max=5000,Default=5000},Callback=function(v) C.Halloween_MaxD=v end})
TabHallow:Section({Title="Colors & Sizes"})
TabHallow:Colorpicker({Title="Chams Fill Color",Default=Color3.fromRGB(C.Halloween_ChamsR,C.Halloween_ChamsG,C.Halloween_ChamsB),Callback=function(col) C.Halloween_ChamsR=math.floor(col.R*255+0.5) C.Halloween_ChamsG=math.floor(col.G*255+0.5) C.Halloween_ChamsB=math.floor(col.B*255+0.5) end})
TabHallow:Colorpicker({Title="Chams Outline Color",Default=Color3.fromRGB(C.Halloween_ChamsOutlineR,C.Halloween_ChamsOutlineG,C.Halloween_ChamsOutlineB),Callback=function(col) C.Halloween_ChamsOutlineR=math.floor(col.R*255+0.5) C.Halloween_ChamsOutlineG=math.floor(col.G*255+0.5) C.Halloween_ChamsOutlineB=math.floor(col.B*255+0.5) end})
TabHallow:Slider({Title="Chams Outline Transparency",Step=0.05,Value={Min=0,Max=1,Default=0},Callback=function(v) C.Halloween_ChamsOutlineTransparency=v end})
TabHallow:Colorpicker({Title="Tracer Color",Default=Color3.fromRGB(C.Halloween_TracerR,C.Halloween_TracerG,C.Halloween_TracerB),Callback=function(col) C.Halloween_TracerR=math.floor(col.R*255+0.5) C.Halloween_TracerG=math.floor(col.G*255+0.5) C.Halloween_TracerB=math.floor(col.B*255+0.5) end})
TabHallow:Colorpicker({Title="Box Color",Default=Color3.fromRGB(C.Halloween_BoxR,C.Halloween_BoxG,C.Halloween_BoxB),Callback=function(col) C.Halloween_BoxR=math.floor(col.R*255+0.5) C.Halloween_BoxG=math.floor(col.G*255+0.5) C.Halloween_BoxB=math.floor(col.B*255+0.5) end})
TabHallow:Colorpicker({Title="Text Color",Default=Color3.fromRGB(C.Halloween_TextR,C.Halloween_TextG,C.Halloween_TextB),Callback=function(col) C.Halloween_TextR=math.floor(col.R*255+0.5) C.Halloween_TextG=math.floor(col.G*255+0.5) C.Halloween_TextB=math.floor(col.B*255+0.5) end})
TabHallow:Slider({Title="Tracer Thickness",Step=1,Value={Min=1,Max=10,Default=1},Callback=function(v) C.Halloween_TracerThick=v end})
TabHallow:Slider({Title="Box Thickness",Step=1,Value={Min=1,Max=10,Default=1},Callback=function(v) C.Halloween_BoxThick=v end})
TabHallow:Slider({Title="Text Size",Step=1,Value={Min=1,Max=50,Default=14},Callback=function(v) C.Halloween_TextSize=v end})
TabHallow:Slider({Title="Box Scale",Step=0.1,Value={Min=0.1,Max=5,Default=1},Callback=function(v) C.Halloween_BoxScale=v end})
TabHallow:Section({Title="Rainbow Effects"})
T(TabHallow,{Title="Rainbow Chams",Default=false},function(v) C.Halloween_RainbowChams=v end)
T(TabHallow,{Title="Rainbow Tracers",Default=false},function(v) C.Halloween_RainbowTracers=v end)
T(TabHallow,{Title="Rainbow Boxes",Default=false},function(v) C.Halloween_RainbowBoxes=v end)
T(TabHallow,{Title="Rainbow Text",Default=false},function(v) C.Halloween_RainbowText=v end)
TabHallow:Section({Title="Actions"})
TabHallow:Button({Title="Force Rescan",Icon="refresh-cw",Callback=function() _hlwClear() task.wait(0.1) _hlwScan() end})
TabHallow:Button({Title="Clear All Cryptid ESP",Icon="x",Callback=function() _hlwClear() end})
-- ESP Tab
local TabESP=Window:Tab({Title="ESP",Icon="eye"})
TabESP:Paragraph({Title="Guard ESP shows guards only. Player ESP shows regular players."})
TabESP:Section({Title="Guard ESP"})
T(TabESP,{Title="Enable Guard ESP",Default=false},function(v) C.GuardESP=v updateESP() end)
T(TabESP,{Title="Show HP bar",Default=true},function(v) C.GuardESP_HP=v end)
T(TabESP,{Title="Show Name",Default=true},function(v) C.GuardESP_Name=v end)
T(TabESP,{Title="Show Highlight",Default=true},function(v) C.GuardESP_Highlight=v end)
T(TabESP,{Title="Show Tracer",Default=false},function(v) C.GuardESP_Tracer=v end)
T(TabESP,{Title="Show Box",Default=false},function(v) C.GuardESP_Box=v end)
T(TabESP,{Title="Show Tool",Default=true},function(v) C.GuardESP_Tool=v end)
T(TabESP,{Title="Show Distance",Default=false},function(v) C.GuardESP_Distance=v end)
T(TabESP,{Title="Force ALL as Guard (debug)",Default=false},function(v) C.GuardESP_ForceAll=v updateESP() end)
T(TabESP,{Title="HP chip colored BG",Default=true},function(v) C.GuardESP_HP_ChipBg=v end)
T(TabESP,{Title="HP chip outline",Default=false},function(v) C.GuardESP_HP_Outline=v end)
TabESP:Slider({Title="Name size",Step=1,Value={Min=8,Max=32,Default=17},Callback=function(v) C.GuardESP_NameSize=v end})
TabESP:Slider({Title="Max distance",Step=10,Value={Min=0,Max=1000,Default=500},Callback=function(v) C.GuardESP_MaxDist=v updateESP() end})
TabESP:Slider({Title="Box thickness",Step=0.5,Value={Min=1,Max=6,Default=2},Callback=function(v) C.GuardESP_BoxThickness=v end})
TabESP:Slider({Title="HP bar thickness",Step=1,Value={Min=2,Max=30,Default=8},Callback=function(v) C.GuardESP_HPBarThickness=v end})
TabESP:Slider({Title="HP bar length",Step=0.1,Value={Min=0.3,Max=3.0,Default=1.5},Callback=function(v) C.GuardESP_HPBarLength=v end})
TabESP:Slider({Title="HP bar roundness",Step=1,Value={Min=0,Max=20,Default=3},Callback=function(v) C.GuardESP_HPBarRoundness=v end})
TabESP:Colorpicker({Title="Guard accent",Default=guardESPColor(),Callback=function(col) C.GuardESP_ColorR=math.floor(col.R*255+0.5) C.GuardESP_ColorG=math.floor(col.G*255+0.5) C.GuardESP_ColorB=math.floor(col.B*255+0.5) end})
TabESP:Colorpicker({Title="Guard Tracer",Default=guardTracerColor(),Callback=function(col) C.GuardESP_TracerR=math.floor(col.R*255+0.5) C.GuardESP_TracerG=math.floor(col.G*255+0.5) C.GuardESP_TracerB=math.floor(col.B*255+0.5) end})
TabESP:Colorpicker({Title="Guard Box",Default=guardBoxColor(),Callback=function(col) C.GuardESP_BoxR=math.floor(col.R*255+0.5) C.GuardESP_BoxG=math.floor(col.G*255+0.5) C.GuardESP_BoxB=math.floor(col.B*255+0.5) end})
TabESP:Section({Title="Player ESP"})
T(TabESP,{Title="Enable Player ESP",Default=false},function(v) C.PlayerESP=v updateESP() end)
T(TabESP,{Title="Show HP bar",Default=true},function(v) C.PlayerESP_HP=v end)
T(TabESP,{Title="Show Name",Default=true},function(v) C.PlayerESP_Name=v end)
T(TabESP,{Title="Show Highlight",Default=true},function(v) C.PlayerESP_Highlight=v end)
T(TabESP,{Title="Show Tracer",Default=false},function(v) C.PlayerESP_Tracer=v end)
T(TabESP,{Title="Show Box",Default=false},function(v) C.PlayerESP_Box=v end)
T(TabESP,{Title="Show Tool",Default=true},function(v) C.PlayerESP_Tool=v end)
T(TabESP,{Title="Show Distance",Default=false},function(v) C.PlayerESP_Distance=v end)
T(TabESP,{Title="HP chip colored BG",Default=true},function(v) C.PlayerESP_HP_ChipBg=v end)
T(TabESP,{Title="HP chip outline",Default=false},function(v) C.PlayerESP_HP_Outline=v end)
TabESP:Input({Title="Custom Name",Value="",Placeholder="empty = real",Callback=function(v) C.PlayerESP_CustomName=v or "" updateESP() end})
T(TabESP,{Title="Rainbow name",Default=false},function(v) C.PlayerESP_NameRainbow=v end)
TabESP:Slider({Title="Rainbow speed",Step=0.05,Value={Min=0.1,Max=3.0,Default=1.0},Callback=function(v) C.PlayerESP_NameRainbowSpeed=v end})
TabESP:Slider({Title="Name size",Step=1,Value={Min=8,Max=32,Default=17},Callback=function(v) C.PlayerESP_NameSize=v end})
TabESP:Slider({Title="Max distance",Step=10,Value={Min=0,Max=1000,Default=500},Callback=function(v) C.PlayerESP_MaxDist=v updateESP() end})
TabESP:Colorpicker({Title="Player accent",Default=playerESPColor(),Callback=function(col) C.PlayerESP_ColorR=math.floor(col.R*255+0.5) C.PlayerESP_ColorG=math.floor(col.G*255+0.5) C.PlayerESP_ColorB=math.floor(col.B*255+0.5) end})
TabESP:Colorpicker({Title="Player Tracer",Default=playerTracerColor(),Callback=function(col) C.PlayerESP_TracerR=math.floor(col.R*255+0.5) C.PlayerESP_TracerG=math.floor(col.G*255+0.5) C.PlayerESP_TracerB=math.floor(col.B*255+0.5) end})
TabESP:Colorpicker({Title="Player Box",Default=playerBoxColor(),Callback=function(col) C.PlayerESP_BoxR=math.floor(col.R*255+0.5) C.PlayerESP_BoxG=math.floor(col.G*255+0.5) C.PlayerESP_BoxB=math.floor(col.B*255+0.5) end})
TabESP:Section({Title="Text"})
TabESP:Button({Title="Next font (now: "..(ESP_FONT_NAMES[C.ESP_FontIdx or 1] or "GothamBlack")..")",Icon="type",Callback=function() C.ESP_FontIdx=(C.ESP_FontIdx or 1)+1 if C.ESP_FontIdx>#ESP_FONT_NAMES then C.ESP_FontIdx=1 end end})
TabESP:Button({Title="Reset font",Icon="rotate-ccw",Callback=function() C.ESP_FontIdx=1 end})
-- Power ESP Section (NEW)
TabESP:Section({Title="Power ESP (NEW)"})
T(TabESP,{Title="Power ESP",Desc="Show equipped power above head",Default=false},function(v) S.toggle_esp_powers(v) end)
TabESP:Colorpicker({Title="Power Color",Default=C.PowerESPColor,Callback=function(c) C.PowerESPColor=c end})
TabESP:Dropdown({Title="Power Font",Values={"UI","System","Plex","Monospace"},Value="Plex",Callback=function(v) C.PowerESPFont=({UI=0,System=1,Plex=2,Monospace=3})[v] or 2 end})
TabESP:Slider({Title="Power Size",Step=1,Value={Min=10,Max=40,Default=16},Callback=function(v) C.PowerESPSize=v end})
-- HnS ESP Section (NEW)
TabESP:Section({Title="Hide & Seek ESP (chase game)"})
TabESP:Paragraph({Title="Seekers=red, Hiders=green, Guards=yellow"})
T(TabESP,{Title="Enable H&S ESP",Default=false},function(v) S.toggle_hns_esp(v) end)
TabESP:Colorpicker({Title="Hider Color",Default=C.HNSSafeColor,Callback=function(c) C.HNSSafeColor=c end})
TabESP:Colorpicker({Title="Seeker Color",Default=C.HNSSeekerColor,Callback=function(c) C.HNSSeekerColor=c end})
TabESP:Colorpicker({Title="Guard Color",Default=C.HNSGuardColor,Callback=function(c) C.HNSGuardColor=c end})
TabESP:Colorpicker({Title="Tracer Color",Default=C.HNSTracerColor,Callback=function(c) C.HNSTracerColor=c end})
-- Dalgona Tab
local TabDalgona=Window:Tab({Title="Dalgona",Icon="cookie"})
TabDalgona:Section({Title="Cookie"})
T(TabDalgona,{Title="One Click Complete",Desc="Mouse-guided outline carve",Default=false},function(v) setOneClickDalgona(v) end)
-- Dalgona Additions
TabDalgona:Button({Title="Anti Crack",Icon="shield",Callback=function() S.toggle_anti_crack() end})
TabDalgona:Button({Title="Free Lighter",Icon="flame",Callback=function() S.dalgona_lighter() end})
T(TabDalgona,{Title="Auto Relax Breathing",Desc="Auto-click breath",Default=false},function(v) S.toggle_dalgona_auto_relax(v) end)
-- Configs Tab
local TabConfigs=Window:Tab({Title="Configs",Icon="save"})
TabConfigs:Section({Title="Save / Load"})
local configNameInput="default"
TabConfigs:Input({Title="Config Name",Value="default",Placeholder="default",Callback=function(v) configNameInput=v or "default" end})
TabConfigs:Button({Title="Save",Icon="save",Callback=function() saveConfig(configNameInput) end})
TabConfigs:Button({Title="Load",Icon="folder-open",Callback=function() loadConfig(configNameInput) end})
TabConfigs:Section({Title="Auto-Load"})
TabConfigs:Button({Title="Set as autoload",Icon="pin",Callback=function() local n=tostring(configNameInput):gsub("[^%w%-%_]","") if n=="" then n="default" end saveAutoloadName(n) end})
TabConfigs:Button({Title="Reset auto-load",Icon="x",Callback=function() clearAutoloadName() end})
TabConfigs:Section({Title="Menu Key"})
TabConfigs:Paragraph({Title="Current: "..tostring(C.MenuKey)})
TabConfigs:Button({Title="Set Menu Key",Icon="keyboard",Callback=function()
    local conn
    conn=UIS.InputBegan:Connect(function(input)
        if input.UserInputType~=Enum.UserInputType.Keyboard then return end
        C.MenuKey=input.KeyCode
        if conn then conn:Disconnect() end
    end)
end})
TabConfigs:Button({Title="Force Open Menu",Icon="maximize",Callback=function() pcall(function() Window:Open() end) _menuOpen=true end})
TabConfigs:Section({Title="Share"})
local shareBoxText=""
TabConfigs:Input({Title="Paste JSON to import",Value="",Placeholder="paste here",Callback=function(v) shareBoxText=v or "" end})
TabConfigs:Button({Title="Export to clipboard",Icon="copy",Callback=function() local pl={C=packStore(C),H=packStore(H),anim=S.animEnabled} local json=HttpService:JSONEncode(pl) if setclipboard then pcall(function() setclipboard(json) end) end end})
TabConfigs:Button({Title="Import from box",Icon="download",Callback=function() if shareBoxText=="" then return end local ok,data=pcall(function() return HttpService:JSONDecode(shareBoxText) end) if ok and type(data)=="table" then applyData(data) end end})
TabConfigs:Section({Title="Unload"})
TabConfigs:Button({Title="FULL UNLOAD",Icon="trash-2",Callback=function() if S.doFullUnload then pcall(S.doFullUnload) end end})
-- ===== UNLOAD =====
S.doFullUnload=function()
    if S.unloaded then return end
    S.running=false
    pcall(unhookCombat) pcall(stopAimbot)
    pcall(destroyFOVCircle) pcall(stopFovRainbow)
    pcall(stopBrewLoop) pcall(_hlwClear) pcall(_stopNoclip)
    pcall(S.clearHNSEsp) pcall(S.clear_esp_powers)
    for obj,state in pairs(S.hiddenNicks) do if obj and obj.Parent then pcall(function() obj.Enabled=state.enabled end) end end
    table.clear(S.hiddenNicks)
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr.Character then
            local h=plr.Character:FindFirstChildOfClass("Humanoid")
            if h then pcall(function() h.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.Viewer h.NameDisplayDistance=100 h.HealthDisplayDistance=100 end) end
        end
    end
    for _,c in ipairs(S.perCharConns) do pcall(function() c:Disconnect() end) end
    table.clear(S.perCharConns) table.clear(S.watchedKeys) table.clear(S.nickNameCache)
    if S.btAnimConn then pcall(function() S.btAnimConn:Disconnect() end) S.btAnimConn=nil end
    if S.morph._watchConn then pcall(function() S.morph._watchConn:Disconnect() end) S.morph._watchConn=nil end
    pcall(function() applyFullBright(false) end) pcall(function() applyRemoveFog(false) end)
    S.unloaded=true
    pcall(function()
        C.Enabled=false H.Enabled=false C.RadiusVis=false H.RadiusVis=false
        C.GuardESP=false C.PlayerESP=false
        C.RemoveHands=false C.RemoveLegs=false C.RemoveTorso=false
        C.Headless=false C.Korblox=false C.HideNick=false C.HideOtherNames=false
        C.FullBright=false C.RemoveFog=false C.AutoBrew=false C.BulletTracer=false
        S.oneClickDalgona=false
        C.RLGL_AutoDodge=false C.RLGL_TimerEndDodge=false
        C.RebelSilentAim=false C.RebelNoRecoil=false C.RebelAimbot=false C.RebelFOVCircle=false
        C.Halloween_Chams=false C.Halloween_Tracers=false C.Halloween_Boxes=false C.Halloween_Names=false C.Halloween_Dist=false
        C.InfJump=false C.Noclip=false
    end)
    pcall(function()
        for part,data in pairs(_G.__dalgonaCache) do if part and part.Parent then pcall(function() part.Position=data.Position part.Transparency=data.Transparency end) end end
        table.clear(_G.__dalgonaCache)
    end)
    pcall(unhook) pcall(clearAllGuardESP) pcall(clearAllPlayerESP)
    if vizConn then pcall(function() vizConn:Disconnect() end) end
    if uiDisc then pcall(function() uiDisc:Destroy() end) end
    if hnsDisc then pcall(function() hnsDisc:Destroy() end) end
    for i=1,#S.conns do pcall(function() if S.conns[i] and S.conns[i].Disconnect then S.conns[i]:Disconnect() end end) end
    table.clear(S.conns)
    for _,c in pairs(S.added) do pcall(function() if c and c.Disconnect then c:Disconnect() end end) end
    table.clear(S.added)
    if S.tracerGui then pcall(function() S.tracerGui:Destroy() end) S.tracerGui=nil end
    if S.overlayGui then pcall(function() S.overlayGui:Destroy() end) S.overlayGui=nil end
    pcall(function() if Window and Window.Destroy then Window:Destroy() end end)
    if getgenv then pcall(function() getgenv().__ui_dodge=nil end) end
end
_G.__XD_UNLOAD=S.doFullUnload
-- ===== LOOPS =====
task.spawn(function()
    while S.running and not S.unloaded do
        pcall(function()
            if C.RemoveHands or C.RemoveLegs or C.RemoveTorso then rebuildLimbCache() end
            if C.Enabled or H.Enabled then
                S.cachedUITool=findUITool() S.cachedDodgeTool=findDodgeTool()
                S.cachedSlot=inferSlotFor(S.cachedUITool,"T",C.ManualUISlot)
                S.cachedDodgeSlot=inferSlotFor(S.cachedDodgeTool,"1",C.ManualHnSSlot)
            end
            if (C.RebelSilentAim or C.RebelNoRecoil) and not S.combatHooked then hookCombat() end
        end)
        task.wait(0.1)
    end
end)
task.spawn(function() while S.running and not S.unloaded do if C.GuardESP or C.PlayerESP then pcall(updateESP) end task.wait(0.5) end end)
task.spawn(function()
    _G.__rlglLastSec=nil _G.__rlglTimerEndedAt=0 _G.__rlglLastFire=0
    while S.running and not S.unloaded do
        pcall(function()
            local onMap=_G.__rlgl_isOnMap()
            if not onMap then _G.__rlglLastSec=nil _G.__rlglTimerEndedAt=0 _G.__rlglWasRed=false task.wait(0.5) return end
            if C.RLGL_AutoDodge then
                local red=_G.__rlgl_isRed() local moving=_G.__rlgl_isMoving(C.RLGL_VelThreshold or 0.3) local safe=_G.__rlgl_inSafeZone()
                if red and not _G.__rlglWasRed then _G.__rlglRedStartAt=tick() end
                _G.__rlglWasRed=red
                local redElapsed=red and (tick()-_G.__rlglRedStartAt) or 0
                local minDelay=C.RLGL_RedDelay or 0.1 local ok=true
                if safe then ok=false end
                if C.RLGL_OnlyRedLight and ok then if not red then ok=false end if redElapsed<minDelay then ok=false end end
                if ok and not moving then ok=false end
                local now=tick()
                if ok and (now-_G.__rlglLast)>=(C.RLGL_MinInterval or 0.15) then _G.__rlglLast=now task.spawn(_G.__rlgl_fireDodge) end
            end
            if C.RLGL_TimerEndDodge then
                local sec=_G.__rlgl_timerSeconds() local safe=_G.__rlgl_inSafeZone() local finish=_G.__rlgl_inFinishZone()
                if sec~=nil then _G.__rlglLastSec=sec end
                if sec~=nil and sec>10 then _G.__rlglTimerEndedAt=0 end
                local justEnded=false
                if sec~=nil and sec<=0 then justEnded=true end
                if sec==nil and _G.__rlglLastSec and _G.__rlglLastSec<=3 then justEnded=true end
                if justEnded and _G.__rlglTimerEndedAt==0 then _G.__rlglTimerEndedAt=tick() _G.__rlglLastFire=0 end
                if _G.__rlglTimerEndedAt>0 and not safe and not finish then
                    local delay=C.RLGL_TimerEndDelay or 0 local interval=C.RLGL_TimerEndInterval or 0.15 local maxDur=C.RLGL_TimerEndMaxDuration or 12
                    local sinceEnd=tick()-_G.__rlglTimerEndedAt
                    if sinceEnd>maxDur then _G.__rlglTimerEndedAt=0
                    elseif sinceEnd>=delay then
                        local now=tick()
                        if _G.__rlglLastFire==0 or (now-_G.__rlglLastFire>=interval) then _G.__rlglLastFire=now task.spawn(_G.__rlgl_fireDodge) end
                    end
                end
            end
        end)
        task.wait(0.05)
    end
end)
do
    if ProximityPromptService then
        pcall(function() ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt,player) if S.unloaded or player~=LP or not C.InstantInteract then return end pcall(fireproximityprompt,prompt) end) end)
    end
end
track(LP.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if S.unloaded then return end
    rebuildLimbCache()
    if C.RemoveHands then applyRemoveHands(true) end
    if C.RemoveLegs then applyRemoveLegs(true) end
    if C.RemoveTorso then applyRemoveTorso(true) end
    if C.Headless then applyHeadless(true) end
    if C.Korblox then applyKorblox(true) end
    if C.RebelSilentAim or C.RebelNoRecoil then S.combatHooked=false task.defer(function() pcall(hookCombat) end) end
    if C.Noclip then pcall(_startNoclip) end
    S.aimbotTarget=nil
end))
ensureHandsLoop()
do
    local al=loadAutoloadName()
    if al~="" then local ok=loadConfig(al) if ok then print("[Xionix] Auto-loaded:",al) end
    else pcall(function() if S.FILE.isfile and S.FILE.isfile(configPath("default")) then loadConfig("default") end end) end
end
if getgenv then getgenv().__ui_dodge={shutdown=S.doFullUnload,config=C,H=H} end
print("[Xionix_Dewamp v 1.2] LOADED (HSX additions, Strict always ON, Menu=N)")
