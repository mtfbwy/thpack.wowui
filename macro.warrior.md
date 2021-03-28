# tips

血性狂暴没有gcd，立即进战斗

狂暴之怒有gcd

# 热键原则

b 重要但低频的技能

c 读条 e aoe f 常用攻击 r 瞬发/dot

g 最重要的控制 t 短效严重失能 v 长效失能

h 治疗/恢复道具

q 终结技

alt-q 自保

x 打断

z 位移技能

1-4 治疗 2 瞬发/dot

mouse3 自动前进

mouse4 饰品/自利

mouse5 糖/血瓶

mouse6-9 按需

alt-w 自动前进

shift-s 上马

alt-a 宝宝攻击

f1 角色

f2 地图

f3 背包

f4 开关姓名板

f10 系统菜单

# 宏

## 通用宏

上马宏
```
/changeactionbar 2
#showtooltip
/施放 召唤战马(召唤)
/cast 迅捷霜刃豹缰绳
/cast 寻找矿物
```

饰品宏。结合TrinketMenu相当有效
```
#showtooltip
/use [nomod] 13; 14
```

糖
```
#showtooltip
/cast [mod][button:2] 制造次级治疗石
/stopmacro [mod][button:2]
/use [nomod] 特效治疗石
/use [nomod] 强效治疗石
/use [nomod] 次级治疗石
/use 特效治疗药水
/use 超强治疗药水
/use 治疗药水
/use 次级治疗药水
```

矿
```
#showtooltip
/cast [mod][button:2] 熔炼; 寻找矿物
```

烹饪
```
#showtooltip
/cast [mod][button:2] 基础营火; 烹饪
```

交奥山碎甲片
```
/run GossipTitleButton1:Click()
/run QuestFrameCompleteButton:Click()
/run QuestFrameCompleteQuestButton:Click()
```

## 战士宏

一键压制：切战斗姿态立即压制
```
#showtooltip 压制
/cast [nostance:1] 战斗姿态
/cast [stance:1] 压制
```

同理有一键复仇
```
#showtooltip
/cast [nostance:2] 防御姿态
/cast [stance:2] 复仇
```

一键拦截
```
#showtooltip 拦截
/cast [nostance:3] 狂暴姿态
/cast 血性狂暴
/cast 狂暴之怒
/cast 拦截
```

buff/b
```
#showtooltip
/cast [nomod] 血性狂暴; 战斗怒吼
```

c
```
/changeactionbar 2
#showtooltip
/startattack
/cast [mod] 猛击
/stopmacro [mod]
#/cast 致死打击
#/cast 盾牌猛击
/cast 嗜血
```

aoe/e
```
#showtooltip
/cast [mod] 挫志怒吼
/stopmacro [mod]
/cast [stance:1] 雷霆一击
/cast [stance:2] 盾牌格挡
/cast [stance:3] 旋风斩
```

英勇，且可骗副手命中，绑f
```
/changeactionbar 2
#showtooltip
/cast [mod] 顺劈斩
/stopmacro [mod]
/startattack
/cast 英勇打击
/stopcasting
```

```
#showtooltip
/cast [mod] 破甲攻击
/stopmacro [mod]
/cast [stance:1] 撕裂
/cast [stance:2] 破甲攻击
/cast [stance:3] 狂暴之怒
```

斩杀+保命。保命的2姿态决不可绑嘲讽
```
#showtooltip
/equip [mod] 钻孔虫之碟
/equip [mod] 奎尔塞拉
/cast [mod,nostance:2] 防御姿态
/cast [mod,stance:2] 盾墙
/stopmacro [mod]
#/cast [stance:2] 破釜沉舟
/cast [stance:2] 盾牌格挡; 斩杀
```

嘲讽
```
#showtooltip
/cast [mod] 挑战怒吼
/stopmacro [mod]
/cast [stance:1] 惩戒痛击
/stopmacro [stance:1]
/cast [nostance:2] 防御姿态
/cast [stance:2] 嘲讽
```

减速控制
```
#showtooltip
/cast [mod] 刺耳怒吼; [stance:2] 缴械; 断筋
```

打断
```
#showtooltip
/cast [stance:3] 拳击; 盾击
```

冲锋
```
#showtooltip
/cast [nostance:1,nocombat] 战斗姿态
/cast 冲锋
/castsequence reset=6/target 断筋, 撕裂
```

### 衣品

p4 一身黑，有人追
```
/黑色龙鳞胸肩腿鞋 (鞋 驱逐者胫甲)
/equip 祭祀护手
/equip 塞拉赞恩之链 (教官的腰带)
/equip 漂亮的黑衬衣
/equip 削骨之刃
```

p5 吸血套
```
/equip 英勇头盔
/equip 英勇护手
/equip 英勇胸甲
/equip 英勇长靴
/equipslot 14 暗月卡片：英雄
/equipslot 17 上古哈卡莱之斧
/equipslot 18 上古哈卡莱之斧
```

## 圣骑士宏

驱邪
```
/startattack
#showtooltip
/cast [nomod] 驱邪术; 神圣愤怒
```

奉献
```
#showtooltip
/cast [mod] 奉献(等级 1); 奉献
```

审判
```
/changeactionbar 2
/dismount
#showtooltip
/cast [mod] 命令圣印
/stopmacro [mod]
/startattack
/castsequence reset=1 审判, 命令圣印
```

我给你讲个笑话
```
#showtooltip
/cast [mod:alt] 圣盾术; 愤怒之锤
```

制裁
```
#showtooltip
/cast [@mouseover,exists][] 制裁之锤
```

8印
```
#showtooltip
/cast [nomod] 正义圣印; 十字军圣印
```

9印
```
#showtooltip
/cast [nomod] 智慧圣印; 光明圣印
```

闪
```
/changeactionbar 2
/stand
/dismount
#showtooltip
/cast [mod:alt,@player] [@mouseover,exists] [] 圣光闪现
```

清
```
/changeactionbar 2
/stand
/dismount
#showtooltip
/cast [mod:alt,@player] [@mouseover,exists] [] 清洁术
```

大光
```
#showtooltip
/cast [mod:alt,@player] [@mouseover,exists] [] 圣光术
```

小闪
```
#showtooltip
/cast [mod:alt,@player] [@mouseover,exists] [] 圣光闪现(等级 1)
```

buff1
```
#showtooltip
/cast [raid,nomod] 强效拯救祝福; [raid] 强效光明祝福
```

buff2
```
#showtooltip
/cast [raid,nomod] 强效智慧祝福; [raid] 强效力量祝福
```

王者
```
#showtooltip
/cast [mod] 强效王者祝福; 王者祝福
```

自庇
```
#showtooltip
/cast [nomod,@player] 庇护祝福; [mod:alt,@player] 强效庇护祝福; 正义之怒
```

### 衣品

很美
```
/equip 命运
/equip 斩龙者护肩
/equip 暴君胸甲
/equip 野熊之蛮兽护臂
/equip 哈库的板甲手套
/equip 杉德尔船长的腰带
/equip 典狱官热裤
/equip 夜枭之血纹长靴
```

反伤
```
/equip 魔铸胸甲
/equip 烈焰披风
/equip 阿格曼奇之戒
/equipslot 13 纯焰精华
/equipslot 14 意志之力
/equip 爱德华之手
/equip 骨火
```

## 盗贼宏

```
#showtooltip
/cast [stance:0] 邪恶攻击; [stance:1] 绞喉
```

伏击
```
#showtooltip
/cast [stance:0] 背刺; [stance:1] 伏击
```

stun
```
#showtooltip
/cast [mod][stance:0] 肾击; [stance:1] 偷袭
```

潜行
```
#showtooltip
/cast [mod:alt] 消失; [stance:1] 搜索; [combat] 刺骨; [stance:0] 潜行;
```

打断
```
#showtooltip
/cast 脚踢
/cast 投掷
/startattack
```

## 术士宏(开发中)

```
#showtooltip
/changeactionbar 2
/startattack
/petattack
/castsequence reset=6/target 腐蚀术, 痛苦诅咒
```

```
#showtooltip
/cast [mod,pet:虚空行者] 牺牲
```

```
#showtooltip
/cast [mod] 吸取法力
/cast [nomod] 吸取灵魂
```

```
#showtooltip
/cast [mod] 吸取法力; [help,pet] 生命通道; 吸取生命
```

```
#showtooltip
/cast [nomod] 献祭; 灼热之痛
```
