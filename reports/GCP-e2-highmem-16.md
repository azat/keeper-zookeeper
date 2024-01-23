OS: Ubuntu 22.04.3 LTS x86_64
Host: Google Compute Engine
Kernel: 6.2.0-1014-gcp
CPU: AMD EPYC 7B12 (16) @ 2.249GHz
Memory: 502MiB / 128802MiB

This is the comparison of ClickHouse Keeper vs ZooKeeper under ClickHouse load:

### ClickHouse 23.4 + Keeper 23.8 vs ClickHouse 23.4 + ZooKeeper 3.7

type|concurrency|time|max coordinator latency (ms)
-|-|-|-
ClickHouse 23.4 x1 + Keeper 23.8 x1|-|0m45.229s|71
ClickHouse 23.4 x1 + Keeper 23.8 x3|-|0m50.825s|114
ClickHouse 23.4 x2 + Keeper 23.8 x1|-|0m50.433s|93
ClickHouse 23.4 x2 + Keeper 23.8 x3|-|0m58.053s|135
ClickHouse 23.4 x1 + Keeper 23.8 x1|32|0m2.501s|93
ClickHouse 23.4 x1 + Keeper 23.8 x3|32|0m2.868s|135
ClickHouse 23.4 x2 + Keeper 23.8 x1|32|0m2.522s|93
ClickHouse 23.4 x2 + Keeper 23.8 x3|32|0m2.951s|135
ClickHouse 23.4 x1 + ZooKeeper 3.7 x1|-|0m23.919s|18
ClickHouse 23.4 x1 + ZooKeeper 3.7 x3|-|0m29.073s|24
ClickHouse 23.4 x2 + ZooKeeper 3.7 x1|-|0m23.861s|31
ClickHouse 23.4 x2 + ZooKeeper 3.7 x3|-|0m28.913s|29
ClickHouse 23.4 x1 + ZooKeeper 3.7 x1|32|0m2.252s|65
ClickHouse 23.4 x1 + ZooKeeper 3.7 x3|32|0m2.725s|29
ClickHouse 23.4 x2 + ZooKeeper 3.7 x1|32|0m2.435s|65
ClickHouse 23.4 x2 + ZooKeeper 3.7 x3|32|0m2.806s|29

```
┌─op_num────┬───count─┬─zookeeper.count─┬─duration_ms_q99─┬─zookeeper.duration_ms_q99─┬─slower─┐
│ Error     │   25957 │           27825 │           15721 │                     16508 │   0.95 │
│ Watch     │   82179 │           73319 │               0 │                         0 │    nan │
│ Create    │ 1534853 │         1380371 │           20192 │                     27153 │   0.74 │
│ Remove    │ 1529566 │         1371286 │          124117 │                    103184 │    1.2 │
│ Exists    │  689432 │          569366 │           20128 │                     50758 │    0.4 │
│ Get       │ 1021690 │          970370 │           17609 │                     20213 │   0.87 │
│ Set       │  303012 │          251438 │           14873 │                     13812 │   1.08 │
│ Sync      │     516 │             478 │           21745 │                     13026 │   1.67 │
│ Heartbeat │    4499 │            4438 │               0 │                         0 │    nan │
│ List      │ 1033790 │          935786 │           13910 │                     15980 │   0.87 │
│ Check     │    3236 │            2653 │           20691 │                     14567 │   1.42 │
│ Multi     │  751534 │          621454 │          147466 │                    148299 │   0.99 │
│ MultiRead │  125494 │           51112 │           14121 │                     15293 │   0.92 │
└───────────┴─────────┴─────────────────┴─────────────────┴───────────────────────────┴────────┘
```

### ClickHouse 23.4 + Keeper 23.8 vs ClickHouse 23.4 + ZooKeeper 3.8

type|concurrency|time|max coordinator latency (ms)
-|-|-|-
ClickHouse 23.4 x1 + Keeper 23.8 x1|-|0m45.008s|97
ClickHouse 23.4 x1 + Keeper 23.8 x3|-|0m54.280s|182
ClickHouse 23.4 x2 + Keeper 23.8 x1|-|0m51.887s|97
ClickHouse 23.4 x2 + Keeper 23.8 x3|-|1m3.136s|182
ClickHouse 23.4 x1 + Keeper 23.8 x1|32|0m2.656s|97
ClickHouse 23.4 x1 + Keeper 23.8 x3|32|0m3.448s|182
ClickHouse 23.4 x2 + Keeper 23.8 x1|32|0m2.535s|97
ClickHouse 23.4 x2 + Keeper 23.8 x3|32|0m3.210s|182
ClickHouse 23.4 x1 + ZooKeeper 3.8 x1|-|0m23.756s|25
ClickHouse 23.4 x1 + ZooKeeper 3.8 x3|-|0m29.111s|141
ClickHouse 23.4 x2 + ZooKeeper 3.8 x1|-|0m24.844s|44
ClickHouse 23.4 x2 + ZooKeeper 3.8 x3|-|0m33.148s|141
ClickHouse 23.4 x1 + ZooKeeper 3.8 x1|32|0m2.871s|44
ClickHouse 23.4 x1 + ZooKeeper 3.8 x3|32|0m2.721s|141
ClickHouse 23.4 x2 + ZooKeeper 3.8 x1|32|0m2.507s|141
ClickHouse 23.4 x2 + ZooKeeper 3.8 x3|32|0m3.021s|141

```
┌─op_num────┬───count─┬─zookeeper.count─┬─duration_ms_q99─┬─zookeeper.duration_ms_q99─┬─slower─┐
│ Error     │   23643 │           25349 │           15837 │                     16535 │   0.96 │
│ Watch     │   75046 │           66486 │               0 │                         0 │    nan │
│ Create    │ 1399917 │         1246765 │           20294 │                     27389 │   0.74 │
│ Remove    │ 1392292 │         1241364 │          126690 │                    105317 │    1.2 │
│ Exists    │  629102 │          514052 │           21586 │                     86250 │   0.25 │
│ Get       │  926015 │          877225 │           17781 │                     20256 │   0.88 │
│ Set       │  277555 │          227358 │           14967 │                     13888 │   1.08 │
│ Sync      │     472 │             434 │           22171 │                     12258 │   1.81 │
│ Heartbeat │    3735 │            3678 │               0 │                         0 │    nan │
│ List      │  938255 │          846017 │           14015 │                     16121 │   0.87 │
│ Check     │    2969 │            2385 │           20821 │                     14908 │    1.4 │
│ Multi     │  687811 │          562371 │          151219 │                    522166 │   0.29 │
│ MultiRead │  115154 │           46621 │           14224 │                     15399 │   0.92 │
└───────────┴─────────┴─────────────────┴─────────────────┴───────────────────────────┴────────┘
```
