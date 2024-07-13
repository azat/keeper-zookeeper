### ClickHouse Keeper 23.12 vs ZooKeeper 3.8

- **~4x** times **slower**, **~4x** bigger **latency** in **single thread**
- **~2x** times **slower** **~2x** bigger **latency** with **32 threads**

### RaftKeeper vs ZooKeeper 3.8

- Performance is the **same** in **cluster setup with 32 threads**
- **2.5-4x slower** without concurrency and has bigger lattency

#### TL;DR;

This is the comparison of ClickHouse Keeper vs ZooKeeper under ClickHouse load:

| test_name | duration | max_latency |
|:-|-:|-:|
| ClickHouse x1 + RaftKeeper x1 | 93 | 4608 |
| ClickHouse x1 + RaftKeeper x3 | 92 | 3251 |
| ClickHouse x2 + RaftKeeper x1 | 99 | 3801 |
| ClickHouse x2 + RaftKeeper x3 | 95 | 3323 |
| ClickHouse x1 + RaftKeeper x1 (concurrency 32) | 2 | 2541 |
| ClickHouse x1 + RaftKeeper x3 (concurrency 32) | 3 | 2553 |
| ClickHouse x2 + RaftKeeper x1 (concurrency 32) | 3 | 2581 |
| ClickHouse x2 + RaftKeeper x3 (concurrency 32) | 3 | 2626 |
| ClickHouse x1 + Keeper 23.12 x1 | 84 | 3131 |
| ClickHouse x1 + Keeper 23.12 x3 | 159 | 5624 |
| ClickHouse x2 + Keeper 23.12 x1 | 93 | 3242 |
| ClickHouse x2 + Keeper 23.12 x3 | 183 | 7384 |
| ClickHouse x1 + Keeper 23.12 x1 (concurrency 32) | 4 | 3536 |
| ClickHouse x1 + Keeper 23.12 x3 (concurrency 32) | 8 | 8535 |
| ClickHouse x2 + Keeper 23.12 x1 (concurrency 32) | 3 | 3211 |
| ClickHouse x2 + Keeper 23.12 x3 (concurrency 32) | 8 | 8034 |
| ClickHouse x1 + ZooKeeper 3.8 x1 | 23 | 827 |
| ClickHouse x1 + ZooKeeper 3.8 x3 | 39 | 1471 |
| ClickHouse x2 + ZooKeeper 3.8 x1 | 26 | 854 |
| ClickHouse x2 + ZooKeeper 3.8 x3 | 47 | 1690 |
| ClickHouse x1 + ZooKeeper 3.8 x1 (concurrency 32) | 2 | 2066 |
| ClickHouse x1 + ZooKeeper 3.8 x3 (concurrency 32) | 4 | 4170 |
| ClickHouse x2 + ZooKeeper 3.8 x1 (concurrency 32) | 2 | 2092 |
| ClickHouse x2 + ZooKeeper 3.8 x3 (concurrency 32) | 4 | 4005 |

*Please submit pull requests for newer versions of ClickHouse Keeper (note, that it does not make a lot of sense to try newer ClickHouse Server)*

*RaftKeeper is based on [this](https://github.com/JDRaftKeeper/RaftKeeper/commit/459b34ac137b4a4caf0ca20d0f34f5e3ea675fd3) commit*

*Version of ClickHouse server is 23.4 everywhere (since only it has [InMemory data parts](https://github.com/ClickHouse/ClickHouse/pull/49429))*

### Run

```sh
RAFT_KEEPER_BIN=/path/to/raftkeeper docker-compose run --rm benchmark
```

### Notes

- we cannot use `network_mode=host` since we need DNS
- we may try to use tmpfs to reduce the IO load, but apparently even with disks it shows the difference (SSD)
