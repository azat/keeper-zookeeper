### ClickHouse Keeper 23.12 vs ZooKeeper 3.8

- **2-4x** times slower, **3-7x** bigger **latency** in **single thread**
- **1.3-2.4x** times slower **3-7** bigger **latency** with **32 threads**

#### TL;DR;

This is the comparison of ClickHouse Keeper vs ZooKeeper under ClickHouse load:

type|concurrency|time|max coordinator latency (ms)
-|-|-|-
ClickHouse 23.4 x1 + Keeper 23.12 x1|-|1m22.816s|128
ClickHouse 23.4 x1 + Keeper 23.12 x3|-|2m41.186s|99
ClickHouse 23.4 x2 + Keeper 23.12 x1|-|1m34.822s|128
ClickHouse 23.4 x2 + Keeper 23.12 x3|-|3m3.516s|110
ClickHouse 23.4 x1 + Keeper 23.12 x1|32|3.458s|128
ClickHouse 23.4 x1 + Keeper 23.12 x3|32|6.975s|110
ClickHouse 23.4 x2 + Keeper 23.12 x1|32|3.480s|128
ClickHouse 23.4 x2 + Keeper 23.12 x3|32|12.408s|130
ClickHouse 23.4 x1 + ZooKeeper 3.8 x1|-|22.320s|18
ClickHouse 23.4 x1 + ZooKeeper 3.8 x3|-|37.801s|30
ClickHouse 23.4 x2 + ZooKeeper 3.8 x1|-|25.693s|18
ClickHouse 23.4 x2 + ZooKeeper 3.8 x3|-|47.412s|43
ClickHouse 23.4 x1 + ZooKeeper 3.8 x1|32|2.504s|18
ClickHouse 23.4 x1 + ZooKeeper 3.8 x3|32|5.325s|43
ClickHouse 23.4 x2 + ZooKeeper 3.8 x1|32|2.839s|20
ClickHouse 23.4 x2 + ZooKeeper 3.8 x3|32|5.277s|43

*Please submit pull requests for newer versions of ClickHouse Keeper (note, that it does not make a lot of sense to try newer ClickHouse Server)*

### Latency comparison by operation

*This results are for sequential run with single coordinator and single server*

| op_num | count | zookeeper.count | duration_ms_q99 | zookeeper.duration_ms_q99 | slower |
|:-|-:|-:|-:|-:|-:|
| Error | 524 | 684 | 98890 | 13278 | 7.45 |
| Watch | 2520 | 2161 | 0 | 0 | nan |
| Create | 55477 | 55190 | 25220 | 15914 | 1.58 |
| Remove | 53954 | 51568 | 104224 | 15673 | 6.65 |
| Exists | 21227 | 16339 | 23933 | 15517 | 1.54 |
| Get | 28896 | 28103 | 19951 | 16158 | 1.23 |
| Set | 10898 | 10064 | 23364 | 11531 | 2.03 |
| Sync | 14 | 14 | 48393 | 1219 | 39.7 |
| Heartbeat | 1240 | 561 | 0 | 0 | nan |
| List | 26389 | 25430 | 20746 | 14227 | 1.46 |
| Check | 131 | 118 | 98923 | 15655 | 6.32 |
| Multi | 26764 | 21278 | 111836 | 15811 | 7.07 |
| MultiRead | 4985 | 0 | 20284 | 0 | inf |

<details>

<summary>SQL format</summary>

```sql
SELECT
    op_num,
    keeper.count,
    zookeeper.count,
    keeper.duration_ms_q99,
    zookeeper.duration_ms_q99,
    round(keeper.duration_ms_q99 / zookeeper.duration_ms_q99, 2) AS slower
FROM
(
    SELECT
        op_num,
        count() AS count,
        quantileExact(0.99)(duration_ms) AS duration_ms_q99
    FROM system.zookeeper_log
    WHERE (type = 'Response') AND (address = '::ffff:172.19.0.9') /* host of standalone Keeper */
    GROUP BY 1
) AS keeper
LEFT JOIN
(
    SELECT
        op_num,
        count() AS count,
        quantileExact(0.99)(duration_ms) AS duration_ms_q99
    FROM remote('server2', system.zookeeper_log)
    WHERE (type = 'Response') AND (address = '::ffff:172.19.0.2') /* host of standalone ZooKeeper */
    GROUP BY 1
) AS zookeeper USING (op_num)
ORDER BY op_num ASC
FORMAT Markdown
```

</details>

### Run

```sh
docker-compose run --rm benchmark
```

### Notes

- we cannot use `network_mode=host` since we need DNS
- we may try to use tmpfs to reduce the IO load, but apparently even with disks it shows the difference (SSD)
