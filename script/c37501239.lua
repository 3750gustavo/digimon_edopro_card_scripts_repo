--Biyomon
Duel.LoadScript("DigimonProc.lua")
local s,id,o=GetID()
function s.initial_effect(c)
	Fusion.AddProcMix(c,s.digivice,true,37501238,s.digivice)
	Fusion.AddContactProc(c,DigimonProc.contactfil,DigimonProc.contactop,DigimonProc.splimit)
	--also treated as Fire
	local e11f=Effect.CreateEffect(c)
	e11f:SetType(EFFECT_TYPE_SINGLE)
	e11f:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e11f:SetRange(LOCATION_MZONE)
	e11f:SetCode(EFFECT_ADD_ATTRIBUTE)
	e11f:SetValue(ATTRIBUTE_FIRE)
	c:RegisterEffect(e11f)
	--digiovo
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCondition(DigimonProc.eggcon)
	e4:SetTarget(DigimonProc.eggtg)
	e4:SetOperation(DigimonProc.eggop)
	c:RegisterEffect(e4)
end
function s.digivice(c)
	return c:IsCode(37501101) or c:IsCode(37501119)
end