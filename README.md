thpack.wowui, wow ui mod once more
==================================

玩魔兽世界的第一个号是盗贼。二三十级的时候，发现能量增长是两秒一个脉冲，于是写了个插件，将能量值、连击点和增长脉冲弄到一个框体里，搁在视野正中偏下的位置。这个插件在战场、荆棘谷和做任务的时候帮了不少忙。之后添加了敌我生命值对比、级别、稀有、施法等等，然后画材质，做美化。慢慢心就大了，写头像、法术预警、buff监视、动作条、姓名板、按键绑定等等等等，燃烧的点卡倒有一小半是在调插件。

有一次想着独乐乐不如众乐乐，就在nga上发布了一个叫thflat的姓名板，以简洁和颜好为亮点。我记得当时有一点点反响，马上就有人说在他的机器上同时出现两种迥异的姓名板，并且贴了图。我却无论如何也不能重现。很久很久之后才发现他同时还装了大脚(那是在国服相当流行的一个all-in-one插件包，直到现在服务器里「大脚世界频道」还比「世界」和「交易」更热闹)。虽然最后invalid，但这件事最终让我熄了发布插件的心。

随着反复afk，又遗失了一个非常重要的U盘，那些插件就慢慢散失了。其实没什么可惜，因为没有真正的亮点。

直到后来弄出一个框架，将异步调用包装成事件，实现了事件的多重依赖。于是移植到lua里，将还在的插件整合成了thpack。可以想像的是，再次afk几年后thpack也被发神经删掉了。

某天有感，充了月卡回去看看。o键无一不黯淡，但旧人和往事却再一次潮水般涌来。我想魔兽世界终会消亡，那天之后该如何触发昔日的欢笑和泪水？

我想thpack必须有一次更新。

献给已经模糊的名字和仍然鲜活的昨日。献给[糖水茶]。
