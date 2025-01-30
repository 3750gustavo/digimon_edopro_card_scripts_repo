--MirageGaogamon
local s,id,o=GetID()
function s.initial_effect(c)
	Fusion.AddProcMix(c,s.digivice,true,37501145,37501119)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit)
	--destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	--negates target
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_NEGATE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_BECOME_TARGET)
	e2:SetCountLimit(1)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--cannot be destroyed by battle on your battle phase
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_ONFIELD)
	e3:SetValue(s.efilter)
	c:RegisterEffect(e3)
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
	return c:IsCode(37501101) or c:IsCode(37501119)
end
function s.digimon(c)
	return c:IsCode(37501100)
end
function s.efilter(e)
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
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

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tc=Duel.GetAttacker()
	if tc==c then tc=Duel.GetAttackTarget() end
	if chk==0 then return tc and tc:IsFaceup() and tc:GetAttack()<=c:GetAttack() end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,tc:GetAttack())
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetAttacker()
	local d = Duel.GetAttackTarget()
	local pos = d:GetSequence()
	if d == c then
		d = Duel.GetAttacker()
		pos = d:GetSequence()
	end
	if tc==c then tc=Duel.GetAttackTarget() end
	if tc:IsRelateToBattle() and tc:GetAttack()<=c:GetAttack() then
		local atk=tc:GetAttack()
		if Duel.Destroy(tc,REASON_EFFECT)~=0 then
			Duel.Damage(1-tp,atk,REASON_EFFECT)
			local adjPos1 = pos + 1 -- Position of the adjacent zone (pos+1)
			local adjPos2 = pos - 1 -- Position of the adjacent zone (pos-1)
			if adjPos1 <= 4 then
			Debug.ShowHint("entrou no if da direita")
			local adjCard1 = Duel.GetFieldCard(1-tp,LOCATION_MZONE,adjPos1) -- Get the card in the adjacent zone (pos+1)
			if adjCard1 then
				local e3 = Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(EFFECT_UPDATE_ATTACK)
				e3:SetValue(-atk)
				e3:SetReset(RESET_EVENT + RESETS_STANDARD)
				adjCard1:RegisterEffect(e3)
			end
			if adjPos2>=0 then
				   Debug.ShowHint("entrou no if da esquerda")
			local adjCard2 = Duel.GetFieldCard(1-tp,LOCATION_MZONE,adjPos2) -- Get the card in the adjacent zone (pos-1)
			if adjCard2 then
				local e5 = Effect.CreateEffect(c)
				e5:SetType(EFFECT_TYPE_SINGLE)
				e5:SetCode(EFFECT_UPDATE_ATTACK)
				e5:SetValue(-atk)
				e5:SetReset(RESET_EVENT + RESETS_STANDARD)
				adjCard2:RegisterEffect(e5)
					end 
				end
			end
		end
	end
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsContains(e:GetHandler())
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckAdjacent() end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c = e:GetHandler()
	local seq = c:GetSequence()
	Card.MoveAdjacent(e:GetHandler())
	local pos = c:GetSequence()
	if pos ~= seq then
		Duel.NegateEffect(ev)
	end
end