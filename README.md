### ClickHouse Keeper 23.12 vs ZooKeeper 3.8

- **2-4x** times **slower**, **3-7x** bigger **latency** in **single thread**
- **1.3-2.4x** times **slower** **3-7** bigger **latency** with **32 threads**

### RaftKeeper vs ZooKeeper 3.8

- **2x faster** in cluster setup with 32 threads
- **5x slower** without concurrency

#### TL;DR;

This is the comparison of ClickHouse Keeper vs ZooKeeper under ClickHouse load:

| test_name | duration | max_latency |
|:-|-:|-:|
| ClickHouse x1 + RaftKeeper x1 | 127 | 4532 |
| ClickHouse x1 + RaftKeeper x3 | 128 | 4601 |
| ClickHouse x2 + RaftKeeper x1 | 129 | 4630 |
| ClickHouse x2 + RaftKeeper x3 | 130 | 4727 |
| ClickHouse x1 + RaftKeeper x1 (concurrency 32) | 3 | 2726 |
| ClickHouse x1 + RaftKeeper x3 (concurrency 32) | 3 | 2764 |
| ClickHouse x2 + RaftKeeper x1 (concurrency 32) | 3 | 2712 |
| ClickHouse x2 + RaftKeeper x3 (concurrency 32) | 2 | 2839 |
| ClickHouse x1 + Keeper 23.12 x1 | 83 | 2953 |
| ClickHouse x1 + Keeper 23.12 x3 | 161 | 5581 |
| ClickHouse x2 + Keeper 23.12 x1 | 93 | 3170 |
| ClickHouse x2 + Keeper 23.12 x3 | 185 | 7442 |
| ClickHouse x1 + Keeper 23.12 x1 (concurrency 32) | 3 | 3196 |
| ClickHouse x1 + Keeper 23.12 x3 (concurrency 32) | 8 | 7676 |
| ClickHouse x2 + Keeper 23.12 x1 (concurrency 32) | 3 | 2979 |
| ClickHouse x2 + Keeper 23.12 x3 (concurrency 32) | 7 | 6946 |
| ClickHouse x1 + ZooKeeper 3.8 x1 | 22 | 749 |
| ClickHouse x1 + ZooKeeper 3.8 x3 | 36 | 1354 |
| ClickHouse x2 + ZooKeeper 3.8 x1 | 26 | 882 |
| ClickHouse x2 + ZooKeeper 3.8 x3 | 48 | 1871 |
| ClickHouse x1 + ZooKeeper 3.8 x1 (concurrency 32) | 3 | 2180 |
| ClickHouse x1 + ZooKeeper 3.8 x3 (concurrency 32) | 4 | 4176 |
| ClickHouse x2 + ZooKeeper 3.8 x1 (concurrency 32) | 2 | 2024 |
| ClickHouse x2 + ZooKeeper 3.8 x3 (concurrency 32) | 4 | 4180 |

*Please submit pull requests for newer versions of ClickHouse Keeper (note, that it does not make a lot of sense to try newer ClickHouse Server)*

*RaftKeeper is based on [this](https://github.com/JDRaftKeeper/RaftKeeper/commit/163f3481ac80c4245f1ae2a103aef9f81d782a0a) commit*

*Version of ClickHouse server is 23.4 everywhere (since only it has [InMemory data parts](https://github.com/ClickHouse/ClickHouse/pull/49429))*

### Run

```sh
RAFT_KEEPER_BIN=/path/to/raftkeeper docker-compose run --rm benchmark
```

### Notes

- we cannot use `network_mode=host` since we need DNS
- we may try to use tmpfs to reduce the IO load, but apparently even with disks it shows the difference (SSD)
