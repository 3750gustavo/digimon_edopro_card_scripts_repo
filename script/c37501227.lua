--Beetlemon
Duel.LoadScript("DigimonProc.lua")
local s,id,o=GetID()
function s.initial_effect(c)
	Fusion.AddProcCodeRep(c,37501230,1)
	Fusion.AddContactProc(c,DigimonProc.contactonfield,DigimonProc.contactop,DigimonProc.splimit)
	--fusion Summon this card on your opponent's turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetHintTiming(0,TIMING_END_PHASE+TIMING_MAIN_END)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.syncon)
	e1:SetTarget(s.syntg)
	e1:SetOperation(s.synop)
	c:RegisterEffect(e1)
	--also treated as THUNDER
	local e0f=Effect.CreateEffect(c)
	e0f:SetType(EFFECT_TYPE_SINGLE)
	e0f:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0f:SetRange(LOCATION_MZONE)
	e0f:SetCode(EFFECT_ADD_RACE)
	e0f:SetValue(RACE_THUNDER)
	c:RegisterEffect(e0f)
	--cannot be destroyed if zoe or any of her fusion for is on field
	local e11=Effect.CreateEffect(c)
	e11:SetType(EFFECT_TYPE_SINGLE)
	e11:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e11:SetRange(LOCATION_MZONE)
	e11:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e11:SetCondition(s.zoecon)
	e11:SetValue(1)
	c:RegisterEffect(e11)
	local e32=e11:Clone()
	e32:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e32)
	--atku
	local e13=Effect.CreateEffect(c)
	e13:SetType(EFFECT_TYPE_FIELD)
	e13:SetRange(LOCATION_MZONE)
	e13:SetTargetRange(LOCATION_MZONE,0)
	e13:SetCode(EFFECT_UPDATE_ATTACK)
	e13:SetTarget(s.tg13)
	e13:SetValue(s.val13)
	c:RegisterEffect(e13)
	--summon Koji if destroyed
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCondition(DigimonProc.eggcon)
	e4:SetTarget(DigimonProc.eggtg)
	e4:SetOperation(s.pctop)
	c:RegisterEffect(e4)
end
local zoe_code = 37501203
function s.tg13(e,c)
	local seq_plus = e:GetHandler():GetSequence()+1
	local seq_minus = e:GetHandler():GetSequence()-1
	return c:GetSequence()==seq_minus or c:GetSequence()==seq_plus
end
function s.val13(e,c)
	return c:GetAttack()*0.25
end
function s.filterzoe(c)
	if c:IsType(TYPE_FUSION) then
	return c:IsFaceup() and c:ListsCodeAsMaterial(zoe_code)
	else return c:IsFaceup() and c:IsCode(zoe_code) end
end
function s.zoecon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filterzoe,e:GetHandlerPlayer(),LOCATION_MZONE,0,e:GetHandler())
	return #g>0
end
function s.filtra(c)
	return c:IsCode(37501230)
end
function s.pctop(e,tp,eg,ep,ev,re,r,rp)
	local token =Duel.CreateToken(tp,37501230)
	Duel.MoveToField(token,tp,tp,LOCATION_MZONE,POS_FACEUP,true)
end
function s.syncon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp and Duel.IsExistingMatchingCard(s.filtra,tp,LOCATION_MZONE,0,1,nil) and not e:GetHandler():IsStatus(STATUS_CHAINING)
end
function s.syntg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsFusionSummonableCard() end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,LOCATION_EXTRA)
end
function s.synop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		local g = Duel.SelectMatchingCard(tp,s.filtra,tp,LOCATION_MZONE,0,1,1,nil)
		Duel.SetFusionMaterial(g)
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
		Duel.SpecialSummon(c,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
	end
end