local extension = Package:new("xuexi")
extension.extensionName = "study"

Fk:loadTranslationTable{
  ["xuexi"] = "学习",
  ["st"] = "学",
}

local caocao = General(extension, "st__caocao", "wei", 4, 6, General.Male)
caocao.subkingdom = "qun"
caocao.shield = 2

local st__yingjie = fk.CreateTriggerSkill{
  name = "st__yingjie",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.DrawNCards},
  on_use = function(self, event, target, player, data)
    data.n = data.n + 1
  end,
}
local st__yingjie_targetmod = fk.CreateTargetModSkill{
  name = "#st__yingjie_targetmod",
  residue_func = function(self, player, skill, scope)
    if skill.trueName == "slash_skill" and player:hasSkill(self.name) and scope == Player.HistoryPhase then
      return 1
    end
  end,
  extra_target_func = function(self, player, skill)
    if skill.trueName == "slash_skill" and player:hasSkill(self.name) then
      return 1
    end
  end,
}
local st__yingjie_maxcards = fk.CreateMaxCardsSkill{
  name = "#st__yingjie_maxcards",
  correct_func = function(self, player)
    if player:hasSkill(self.name) then
      return 1
    else
      return 0
    end
  end,
}
local st__yingjie_attackrange = fk.CreateAttackRangeSkill{
  name = "#st__yingjie_attackrange",
  correct_func = function (self, from)
    if from:hasSkill(self.name) then
      return 1
    end
    return 0
  end,
}
local st__yingjie_distance = fk.CreateDistanceSkill{
  name = "#st__yingjie_distance",
  correct_func = function(self, from, to)
    if from:hasSkill(self.name) then
      return -1
    end
  end,
}
local st__yingjie_prohibit = fk.CreateProhibitSkill{
  name = "#st__yingjie_prohibit",
  is_prohibited = function(self, from, to, card)
    if to:hasSkill(self.name) then
      return card.name == "archery_attack"
    end
  end,
}
st__yingjie:addRelatedSkill(st__yingjie_targetmod)
st__yingjie:addRelatedSkill(st__yingjie_maxcards)
st__yingjie:addRelatedSkill(st__yingjie_attackrange)
st__yingjie:addRelatedSkill(st__yingjie_distance)
st__yingjie:addRelatedSkill(st__yingjie_prohibit)
caocao:addSkill(st__yingjie)
caocao:addSkill("feiying")
Fk:loadTranslationTable{
  ["st__caocao"] = "曹操",
  ["st__yingjie"] = "英杰",
  [":st__yingjie"] = "锁定技，摸牌阶段，你额外摸一张牌；" ..
  "出牌阶段，你使用【杀】次数上限+1且目标上限+1；"..
  "你的手牌上限+1；你的攻击范围+1；你计算至其他角色距离-1；" ..
  "你不能成为【万箭齐发】的目标。",

  ["$st__yingjie1"] = "宁教我负天下人，休教天下人负我！",
  ["$st__yingjie2"] = "吾好梦中杀人！",
  ["~st__caocao"] = "霸业未成！未成啊！",
}
return extension
