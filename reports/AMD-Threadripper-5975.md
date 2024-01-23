### ClickHouse Keeper vs ZooKeeper

Briefly: ZooKeeper is faster (2-4x)

#### TL;DR;

This is the comparison of ClickHouse Keeper vs ZooKeeper under ClickHouse load:

type|concurrency|time|max coordinator latency (ms)
-|-|-|-
ClickHouse 22.4 x1 + Keeper 22.6 x1|-|2m4s|119
ClickHouse 22.4 x1 + Keeper 22.6 x3|-|4m29s|192
ClickHouse 22.4 x2 + Keeper 22.6 x1|-|2m18s|210
ClickHouse 22.4 x2 + Keeper 22.6 x3|-|5m20s|265
ClickHouse 22.4 x1 + Keeper 22.6 x1|32|5.289s|210
ClickHouse 22.4 x1 + Keeper 22.6 x3|32|14.341s|265
ClickHouse 22.4 x2 + Keeper 22.6 x1|32|4.528s|210
ClickHouse 22.4 x2 + Keeper 22.6 x3|32|15.023s|265
ClickHouse 22.4 x1 + ZooKeeper 3.7 x1|-|30.590s|26
ClickHouse 22.4 x1 + ZooKeeper 3.7 x3|-|55.080s|56
ClickHouse 22.4 x2 + ZooKeeper 3.7 x1|-|26.928s|26
ClickHouse 22.4 x2 + ZooKeeper 3.7 x3|-|1m22.483s|79
ClickHouse 22.4 x1 + ZooKeeper 3.7 x1|32|3.227s|26
ClickHouse 22.4 x1 + ZooKeeper 3.7 x3|32|4.253s|79
ClickHouse 22.4 x2 + ZooKeeper 3.7 x1|32|2.324s|26
ClickHouse 22.4 x2 + ZooKeeper 3.7 x3|32|4.262s|79

*Please submit pull requests for newer versions of ClickHouse Keeper (note, that it does not make a lot of sense to try newer ClickHouse Server)*

### Latency comparison by operation

| op_num | count | zookeeper.count | duration_ms_q99 | zookeeper.duration_ms_q99 | slower |
|:-|-:|-:|-:|-:|-:|
| Watch | 1244 | 1225 | 0 | 0 | nan |
| Create | 13582 | 13147 | 29048 | 11308 | 2.57 |
| Remove | 13506 | 13027 | 113840 | 11164 | 10.2 |
| Exists | 9489 | 6492 | 26680 | 10650 | 2.51 |
| Get | 8728 | 8250 | 19834 | 8348 | 2.38 |
| Set | 5442 | 4817 | 27352 | 10870 | 2.52 |
| Sync | 4 | 2 | 12735 | 1239 | 10.28 |
| Heartbeat | 233 | 227 | 0 | 0 | nan |
| List | 5623 | 5077 | 27602 | 10893 | 2.53 |
| Check | 15 | 4 | 27824 | 12753 | 2.18 |
| Multi | 9967 | 6629 | 124594 | 10977 | 11.35 |
| MultiRead | 2422 | 0 | 26384 | 0 | inf |

*This results are for sequential run with single coordinator and single server*
