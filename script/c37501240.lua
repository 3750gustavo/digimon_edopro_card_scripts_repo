--Birdramon
--common digimon function are loaded from here, to avoid copy and paste
Duel.LoadScript("DigimonProc.lua")
local s,id,o=GetID()
function s.initial_effect(c)
	Fusion.AddProcMix(c,s.digivice,true,37501239,s.digivice)
	Fusion.AddContactProc(c,DigimonProc.contactfil,DigimonProc.contactop,DigimonProc.splimit)
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
	--when summoned inflict damage and reduce all opponent monsters atk by this card atk and destroy any reduced to 0, cannot attack this turn with this card
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_DAMAGE+CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetTarget(s.reducetg)
	e5:SetOperation(s.reduceop)
	c:RegisterEffect(e5)
end
function s.digivice(c)
	return c:IsCode(37501101) or c:IsCode(37501119)
end
--check if any face-up monsters exist for reducing atk
function s.reducetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	local c=e:GetHandler()
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(c:GetAttack())
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,c:GetAttack())
end
function s.reduceop(e,tp,eg,ep,ev,re,r,rp)
	local player,damage_value=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	local c=e:GetHandler()
	local atk=c:GetAttack()
	--group of monsters that got atk reduced to 0
	local destroygroup=Group.CreateGroup()
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	--inflict damage equal to this card atk
	atk=Duel.Damage(player,damage_value,REASON_EFFECT) --saves in variable atk the damage received
	--if variable atk became 0, then no damage was received, so no need to reduce anything
	if atk==0 then return end
	for tc in aux.Next(g) do
		--reduce atk
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetRange(LOCATION_MZONE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(-atk) --same as the atk of this card or the damage received, whichever is lower
		tc:RegisterEffect(e1)
		--if atk became 0,then append to destroygroup
		if tc:GetAttack()==0 then destroygroup:AddCard(tc) end
	end
	--destroy any reduced to 0
	if #destroygroup>0 then	Duel.Destroy(destroygroup,REASON_EFFECT) end --
	--c cannot attack this turn if this effect resolved up to this point
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e2)
end	