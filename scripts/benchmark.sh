#!/usr/bin/env bash

function wait_server_initialized()
{
    local server="$1" && shift
    local cluster="$1" && shift
    local zookeeper_name="$1" && shift

    let tries=100 i=0
    while [[ $i -lt $tries ]]; do
        (( ++i ))
        sleep 0.1
        # Use system.zookeeper to wait zookeeper as well
        clickhouse-client -mn -q "
            DROP TABLE IF EXISTS test_$zookeeper_name ON CLUSTER $cluster;

            CREATE TABLE IF NOT EXISTS test_$zookeeper_name
            ON CLUSTER $cluster
            (p UInt64)
            ENGINE = ReplicatedMergeTree('$zookeeper_name:/clickhouse/tables/{database}/{table}', '{hostname}') ORDER BY tuple();
        " --format Null --host "$server" >&/dev/null || continue
        echo "* coordinator=$zookeeper_name became available on server=$server and cluster=$cluster after $i iterations"
        return
    done

    echo "* coordinator=$zookeeper_name is not available on server=$server and cluster=$cluster after $i iterations" >&2
    return 1
}

function wait_table_initialized()
{
    local server="$1" && shift
    local table="$1" && shift

    let tries=100 i=0
    while [[ $i -lt $tries ]]; do
        (( ++i ))
        sleep 1
        local insert_opts=(
            -q "INSERT INTO $table VALUES (0)"
            --insert_keeper_max_retries 0
            --format Null
            --host "$server"
        )
        clickhouse-client "${insert_opts[@]}" 2>/dev/null || continue
        echo "* $table on $server became ready in $i iterations"
        return
    done

    echo "* $table on $server was not ready in $i iterations" >&2
    return 1
}

function main()
{
    local server="$1" && shift
    local cluster="$1" && shift
    local zookeeper_host="$1" && shift
    local zookeeper_name="$1" && shift

    echo "* Running benchmark: server=$server, cluster=$cluster, zookeeper_host=$zookeeper_host, zookeeper_name=$zookeeper_name, clickhouse-benchmark options=$*"

    wait_server_initialized "$server" "$cluster" "$zookeeper_name" || return

    clickhouse-client -nm --host "$server" -q "
    DROP TABLE IF EXISTS bench ON CLUSTER $cluster;
    CREATE TABLE bench ON CLUSTER $cluster
    (p UInt64)
    ENGINE = ReplicatedMergeTree('$zookeeper_name:/clickhouse/tables/{database}/{table}', '{hostname}')
    ORDER BY tuple()
    PARTITION BY p
    SETTINGS
        in_memory_parts_enable_wal=0,
        -- NOTE: merges will be done via non-InMemory parts
        min_bytes_for_compact_part='100Mi',
        min_bytes_for_wide_part='100Mi',
        parts_to_delay_insert=1e6,
        parts_to_throw_insert=1e6,
        max_parts_in_total=1e6;
    " >/dev/null
    wait_table_initialized "$server" "bench" || return

    local bench_opts=(
        # Pass any options for clickhouse-benchmark
        "$@"

        --query "INSERT INTO bench SELECT randConstant()%100 from numbers(100)"

        --delay 0
        --iterations 32
        --host "$server"

        # insert each row as a separate part
        --min_insert_block_size_rows 1
        --insert_deduplicate 0
        --insert_keeper_max_retries 0
    )
    # NOTE: maybe in the meantime spawn chdig to show the queries?
    # NOTE: also we can calculate ZooKeeper metrics from system.zookeeper or via statistics from the ZooKeeper/Keeper
    time clickhouse-benchmark "${bench_opts[@]}" |& grep -e Exception -e 'QPS:'

    # TODO: reset latency
    clickhouse keeper-client --host "$zookeeper_host" --port 2181 <<<stat | grep Latency

    clickhouse-client --host "$server" -q "DROP TABLE IF EXISTS bench ON CLUSTER $cluster" >/dev/null
}
main "$@"
