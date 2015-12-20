-- Runic (Darkness + Fire + Light)
-- This is a long range splash damage tower. It can automatically activate an ability periodically that gives it multi-shoot. 
-- This allows it to attack ALL creeps in an area around the primary target. I
-- In other words, every creep normally hit by the splash damage would get attacked too (with those attacks also doing splash damage). 
-- Ability lasts a few seconds, and has a few second cooldown. Autocast can be toggled to prevent inopportune casting.

RunicTower = createClass({
        tower = nil,
        towerClass = "",

        constructor = function(self, tower, towerClass)
            self.tower = tower
            self.towerClass = towerClass or self.towerClass
        end
    },
    {
        className = "RunicTower"
    },
nil)

function RunicTower:OnMagicAttackThink()
    if self.ability:IsFullyCastable() and self.ability:GetAutoCastState() and #GetCreepsInArea(self.tower:GetOrigin(), self.tower:GetAttackRange()) > 0 and not self.tower:HasModifier("modifier_silence") then
        self.tower:CastAbilityImmediately(self.ability, 1)
    end
end

function RunicTower:OnMagicAttackCast(keys)
    self.ability:ApplyDataDrivenModifier(self.tower, self.tower, "modifier_magic_attack", {})
end

function RunicTower:OnAttack(keys)
    local target = keys.target
    local caster = keys.caster
    local creeps = GetCreepsInArea(target:GetOrigin(), self.halfAOE)
    if self.tower:HasModifier("modifier_magic_attack") then
        for _, creep in pairs(creeps) do
            if creep:IsAlive() and creep:entindex() ~= target:entindex() then
                --self.tower:PerformAttack(creep, false, false, true, true, false)
                local info = 
                {
                    Target = creep,
                    Source = caster,
                    Ability = keys.ability,
                    EffectName = "particles/units/heroes/hero_visage/visage_base_attack.vpcf",
                    iMoveSpeed = 900,
                    vSourceLoc= caster:GetAbsOrigin(),
                    bDrawsOnMinimap = false,
                    bDodgeable = true,
                    bIsAttack = false,
                    bVisibleToEnemies = true,
                    bReplaceExisting = false,
                    flExpireTime = GameRules:GetGameTime() + 10,
                    bProvidesVision = true,
                    iVisionRadius = 400,
                    iVisionTeamNumber = caster:GetTeamNumber()
                }
                projectile = ProjectileManager:CreateTrackingProjectile(info)
            end
        end
    end
end

function RunicTower:OnProjectileHit(keys)
    self:OnAttackLanded({target = keys.target, isBonus = true})
end

function RunicTower:OnAttackLanded(keys)
    local target = keys.target
    if target then
        local damage = ApplyAttackDamageFromModifiers(self.tower:GetBaseDamageMax(), self.tower)
        if keys.isBonus then
            damage = damage * 0.5
        end
        DamageEntitiesInArea(target:GetOrigin(), self.halfAOE, self.tower, damage / 2)
        DamageEntitiesInArea(target:GetOrigin(), self.fullAOE, self.tower, damage / 2)
    end
end

function RunicTower:OnCreated()
    self.ability = AddAbility(self.tower, "runic_tower_magic_attack")
    Timers:CreateTimer(0.03, function()
        if IsValidEntity(self.tower) then
            self:OnMagicAttackThink()
            return 0.03
        end
    end)
    self.ability:ToggleAutoCast()
    
    self.projectileSpeed = tonumber(GetUnitKeyValue(self.towerClass, "ProjectileSpeed"))
    self.halfAOE = tonumber(GetUnitKeyValue(self.towerClass, "AOE_Half"))
    self.fullAOE = tonumber(GetUnitKeyValue(self.towerClass, "AOE_Full"))
    self.attackOrigin = self.tower:GetAttachmentOrigin(self.tower:ScriptLookupAttachment("attach_attack1"))
end

RegisterTowerClass(RunicTower, RunicTower.className)