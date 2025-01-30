--LadyDevimon
local s,id,o=GetID()
function s.initial_effect(c)
	local escolhi
	Fusion.AddProcMix(c,s.digivice,true,37501215,s.digivice)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit)
	--redirecionar ataque
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	--token
	local e11=Effect.CreateEffect(c)
	e11:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e11:SetDescription(aux.Stringid(id,2))
	e11:SetType(EFFECT_TYPE_QUICK_O)
	e11:SetCode(EVENT_FREE_CHAIN)
	e11:SetRange(LOCATION_MZONE)
	e11:SetCountLimit(1)
	e11:SetTarget(s.trazerdemos)
	e11:SetOperation(s.demos)
	c:RegisterEffect(e11)
	-- dark beijo/kiss
	local e12=Effect.CreateEffect(c)
	e12:SetDescription(aux.Stringid(id,3))
	e12:SetType(EFFECT_TYPE_QUICK_O)
	e12:SetCode(EVENT_FREE_CHAIN)
	e12:SetRange(LOCATION_MZONE)
	e12:SetTarget(s.target)
	e12:SetOperation(s.operation)
	c:RegisterEffect(e12)
	--digiovo
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCondition(s.pctcon)
	e4:SetTarget(s.pcttg)
	e4:SetOperation(s.pctop)
	c:RegisterEffect(e4)
end
function s.digivice(c)
	return c:IsCode(37501101) or c:IsCode(37501161)
end
function s.digimon(c)
	return c:IsCode(37501107)
end
function s.contactfil(tp)
	return Duel.GetMatchingGroup(Card.IsAbleToGraveAsCost,tp,LOCATION_ONFIELD+LOCATION_HAND,0,nil)
end
function s.contactop(g,tp)
	Duel.ConfirmCards(1-tp,g)
	Duel.SendtoGrave(g,REASON_COST+REASON_MATERIAL,nil)
end
function s.splimit(e,se,sp,st)
	return true
end
function s.pctcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
  end
  function s.pcttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
  end
  function s.pctop(e,tp,eg,ep,ev,re,r,rp)
	local token =Duel.CreateToken(tp,37501103)  
	Duel.MoveToField(token,tp,tp,LOCATION_MZONE,POS_FACEUP,true)
  end
function s.filterseducao(c)
	return c~=Duel.GetAttackTarget() and c~=Duel.GetAttacker()
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filterseducao,tp,0,LOCATION_MZONE,1,e:GetHandler()) end
	Duel.SetChainLimit(aux.FALSE)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SetChainLimit(aux.FALSE)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACKTARGET)
	local tc=Duel.SelectMatchingCard(tp,s.filterseducao,tp,0,LOCATION_MZONE,1,1,e:GetHandler()):GetFirst()
	if tc then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_SELF_ATTACK)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetReset(RESET_PHASE|PHASE_DAMAGE)
		e1:SetTargetRange(1,1)
		Duel.RegisterEffect(e1,tp)
		Duel.ChangeAttackTarget(tc,true)
	end
end
function s.trazerdemos(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,ft,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ft,tp,0)
end
function s.demos(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local fid=e:GetHandler():GetFieldID()
	for i=1,ft do
		local token=Duel.CreateToken(tp,37501214)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_ATTACK)
		--Inflict 500 damage when destroyed
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_LEAVE_FIELD)
		e1:SetOperation(s.darkfire)
		token:RegisterEffect(e1,true)
	end
	Duel.SpecialSummonComplete()
end
-- 500 damage to the opponent when destroyed
function s.darkfire(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_DESTROY) then
		-- change tp value to the opposite player
		if c:GetPreviousControler() == 0 then tp = 1 else tp = 0 end
		Duel.Damage(tp,500,REASON_EFFECT)
	end
end
function s.dna(c)
	return c:IsCode(37501214) and c:IsFaceup()
end
function s.faxada(c)
	return c:IsFaceup() and c:GetLevel()>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil) and Duel.IsExistingMatchingCard(s.dna,tp,LOCATION_MZONE,0,1,nil) end
	local g=Duel.GetMatchingGroup(s.faxada,tp,0,LOCATION_MZONE,nil)
	local tg=g:GetMaxGroup(Card.GetLevel)
	Duel.SetTargetCard(tg)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local custo = Duel.SelectMatchingCard(tp,s.dna,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.Destroy(custo,REASON_EFFECT)
	local g=Duel.GetTargetCards(e)
	local tc
	if #g>0 then
		tc=g:Select(tp,1,1,nil):GetFirst()
	else
		return
	end
	if tc then
		 --Cannot activate its effects
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3302)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		--cannot leave
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SEND_REPLACE)
		e2:SetDescription(3308)
		e2:SetValue(1)
		tc:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_RELEASE_REPLACE)
		e3:SetDescription(3303)
		tc:RegisterEffect(e3)
				--Cannot be Tributed
		local e5=Effect.CreateEffect(e:GetHandler())
		e5:SetType(EFFECT_TYPE_SINGLE)
		e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e5:SetCode(EFFECT_UNRELEASABLE_SUM)
		e5:SetRange(LOCATION_MZONE)
		e5:SetValue(1)
		tc:RegisterEffect(e5)
		local e6=e5:Clone()
		e6:SetCode(EFFECT_UNRELEASABLE_NONSUM)
		tc:RegisterEffect(e6)
            
            --Cannot be used as material for a Fusion/Synchro/Xyz Summon/link summon
			local e7=Effect.CreateEffect(e:GetHandler())
			e7:SetType(EFFECT_TYPE_SINGLE)
			e7:SetCode(EFFECT_CANNOT_BE_MATERIAL)
			e7:SetValue(aux.cannotmatfilter(SUMMON_TYPE_FUSION,SUMMON_TYPE_SYNCHRO,SUMMON_TYPE_XYZ+SUMMON_TYPE_LINK))
			tc:RegisterEffect(e7)
	end
end