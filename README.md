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
| ClickHouse x1 + RaftKeeper 2.1.1 x1 | 96 | 3392 |
| ClickHouse x1 + RaftKeeper 2.1.1 x3 | 97 | 3361 |
| ClickHouse x2 + RaftKeeper 2.1.1 x1 | 98 | 3609 |
| ClickHouse x2 + RaftKeeper 2.1.1 x3 | 95 | 3430 |
| ClickHouse x1 + RaftKeeper 2.1.1 x1 (concurrency 32) | 3 | 2613 |
| ClickHouse x1 + RaftKeeper 2.1.1 x3 (concurrency 32) | 3 | 2582 |
| ClickHouse x2 + RaftKeeper 2.1.1 x1 (concurrency 32) | 3 | 2603 |
| ClickHouse x2 + RaftKeeper 2.1.1 x3 (concurrency 32) | 3 | 2595 |
| ClickHouse x1 + Keeper 24.6 x1 | 87 | 3220 |
| ClickHouse x1 + Keeper 24.6 x3 | 163 | 5749 |
| ClickHouse x2 + Keeper 24.6 x1 | 93 | 3268 |
| ClickHouse x2 + Keeper 24.6 x3 | 198 | 8777 |
| ClickHouse x1 + Keeper 24.6 x1 (concurrency 32) | 4 | 3578 |
| ClickHouse x1 + Keeper 24.6 x3 (concurrency 32) | 8 | 7419 |
| ClickHouse x2 + Keeper 24.6 x1 (concurrency 32) | 3 | 3251 |
| ClickHouse x2 + Keeper 24.6 x3 (concurrency 32) | 8 | 8377 |
| ClickHouse x1 + ZooKeeper 3.8 x1 | 22 | 761 |
| ClickHouse x1 + ZooKeeper 3.8 x3 | 38 | 1393 |
| ClickHouse x2 + ZooKeeper 3.8 x1 | 25 | 859 |
| ClickHouse x2 + ZooKeeper 3.8 x3 | 48 | 1684 |
| ClickHouse x1 + ZooKeeper 3.8 x1 (concurrency 32) | 3 | 2442 |
| ClickHouse x1 + ZooKeeper 3.8 x3 (concurrency 32) | 5 | 4938 |
| ClickHouse x2 + ZooKeeper 3.8 x1 (concurrency 32) | 2 | 2769 |
| ClickHouse x2 + ZooKeeper 3.8 x3 (concurrency 32) | 4 | 4115 |

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
