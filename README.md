# Redis内存分析工具

通过使用Redis命令`keys *`，`object idletime {KEY}`，`debug object {KEY}`，来导出Redis中各个key的闲置时间以及序列化之后的大小。

目前有shell和python两个版本，shell暂时没找到使用pipeline的方法，所以导出过程中速度很慢，并且对Redis有压力。 