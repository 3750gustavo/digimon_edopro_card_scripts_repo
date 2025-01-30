--Lotosmon
Duel.LoadScript("DigimonProc.lua")
local s,id,o=GetID()
function s.initial_effect(c)
	Fusion.AddProcMixN(c,true,true,37501219,1,aux.FilterBoolFunction(Card.IsSetCard,0x3763),2)
	Fusion.AddContactProc(c,DigimonProc.contactfil,DigimonProc.contactop,DigimonProc.splimit)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EFFECT_CANNOT_DISABLE)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	--caduceus
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_CONFIRM)
	e1:SetTarget(s.destg)
	c:RegisterEffect(e1)
	--choose attack targets
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_PATRICIAN_OF_DARKNESS)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(0,1)
	c:RegisterEffect(e2)
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
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	if chk==0 then return bc end
	Duel.SetChainLimit(aux.FALSE)
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	local todos=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	local verdade=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
	and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) 
	and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 
	and Duel.IsExistingTarget(s.spfilter,tp,0,LOCATION_GRAVE,1,nil,e,tp)
	local escolha
	if #todos==0 and not verdade then return false
	elseif #todos==0 and verdade then escolha=Duel.SelectOption(1-tp,aux.Stringid(id,2)) escolha=1
	elseif #todos>0 and not verdade then escolha=Duel.SelectOption(1-tp,aux.Stringid(id,1))
	else escolha=Duel.SelectOption(1-tp,aux.Stringid(id,1),aux.Stringid(id,2))
	end
	--destruir todos monstros
	if escolha==0 then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,todos,#todos,1-tp,REASON_EFFECT)
		Duel.Destroy(todos,REASON_EFFECT)
	--ambos revivem um monstro do seus cemiterios
	else
		local minha_escolha=g:FilterSelect(tp,aux.TRUE,1,1,false,nil)
		local nivel=minha_escolha:GetFirst():GetLevel()
		if Duel.SpecialSummon(minha_escolha:GetFirst(),0,tp,tp,false,false,POS_FACEUP)>0 then
			--grupo 2 limitado pelo nivel da minha escolha
			local g2=Duel.GetMatchingGroup(s.spfilter,1-tp,LOCATION_GRAVE,0,nil,e,tp,nivel)
			g2=g2:Filter(Card.IsLevelBelow,nil,nivel)
			if #g2>0 then
				local sua_escolha=g2:FilterSelect(1-tp,aux.TRUE,1,1,false,nil):GetFirst()
				Duel.SpecialSummon(sua_escolha,0,1-tp,1-tp,false,false,POS_FACEUP)
			end
		end
	end
end