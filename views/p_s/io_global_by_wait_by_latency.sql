/* Copyright (c) 2014, Oracle and/or its affiliates. All rights reserved.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; version 2 of the License.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301  USA */

/*
 * View: io_global_by_wait_by_latency
 *
 * Show the top global IO consumers by latency
 *
 * mysql> SELECT * FROM io_global_by_wait_by_latency;
 * +-------------------------+------------+---------------+-------------+-------------+--------------+---------------+--------------+------------+------------+-----------+-------------+---------------+-------------+
 * | event_name              | count_star | total_latency | avg_latency | max_latency | read_latency | write_latency | misc_latency | count_read | total_read | avg_read  | count_write | total_written | avg_written |
 * +-------------------------+------------+---------------+-------------+-------------+--------------+---------------+--------------+------------+------------+-----------+-------------+---------------+-------------+
 * | sql/file_parser         |       5433 | 30.20 s       | 5.56 ms     | 203.65 ms   | 22.08 ms     | 24.89 ms      | 30.16 s      |         24 | 6.18 KiB   | 264 bytes |         737 | 2.15 MiB      | 2.99 KiB    |
 * | innodb/innodb_data_file |       1344 | 1.52 s        | 1.13 ms     | 350.70 ms   | 203.82 ms    | 450.96 ms     | 868.21 ms    |        147 | 2.30 MiB   | 16.00 KiB |        1001 | 53.61 MiB     | 54.84 KiB   |
 * | innodb/innodb_log_file  |        828 | 893.48 ms     | 1.08 ms     | 30.11 ms    | 16.32 ms     | 705.89 ms     | 171.27 ms    |          6 | 68.00 KiB  | 11.33 KiB |         413 | 2.19 MiB      | 5.42 KiB    |
 * | myisam/kfile            |       7642 | 242.34 ms     | 31.71 us    | 19.27 ms    | 73.60 ms     | 23.48 ms      | 145.26 ms    |        758 | 135.63 KiB | 183 bytes |        4386 | 232.52 KiB    | 54 bytes    |
 * | myisam/dfile            |      12540 | 223.47 ms     | 17.82 us    | 32.50 ms    | 87.76 ms     | 16.97 ms      | 118.74 ms    |       5390 | 4.49 MiB   | 873 bytes |        1448 | 2.65 MiB      | 1.88 KiB    |
 * | csv/metadata            |          8 | 28.98 ms      | 3.62 ms     | 20.15 ms    | 399.27 us    | 0 ps          | 28.58 ms     |          2 | 70 bytes   | 35 bytes  |           0 | 0 bytes       | 0 bytes     |
 * | mysys/charset           |          3 | 24.24 ms      | 8.08 ms     | 24.15 ms    | 24.15 ms     | 0 ps          | 93.18 us     |          1 | 17.31 KiB  | 17.31 KiB |           0 | 0 bytes       | 0 bytes     |
 * | sql/ERRMSG              |          5 | 20.43 ms      | 4.09 ms     | 19.31 ms    | 20.32 ms     | 0 ps          | 103.20 us    |          3 | 58.97 KiB  | 19.66 KiB |           0 | 0 bytes       | 0 bytes     |
 * | mysys/cnf               |          5 | 11.37 ms      | 2.27 ms     | 11.28 ms    | 11.29 ms     | 0 ps          | 78.22 us     |          3 | 56 bytes   | 19 bytes  |           0 | 0 bytes       | 0 bytes     |
 * | sql/dbopt               |         57 | 4.04 ms       | 70.92 us    | 843.70 us   | 0 ps         | 186.43 us     | 3.86 ms      |          0 | 0 bytes    | 0 bytes   |           7 | 431 bytes     | 62 bytes    |
 * | csv/data                |          4 | 411.55 us     | 102.89 us   | 234.89 us   | 0 ps         | 0 ps          | 411.55 us    |          0 | 0 bytes    | 0 bytes   |           0 | 0 bytes       | 0 bytes     |
 * | sql/misc                |         22 | 340.38 us     | 15.47 us    | 33.77 us    | 0 ps         | 0 ps          | 340.38 us    |          0 | 0 bytes    | 0 bytes   |           0 | 0 bytes       | 0 bytes     |
 * | archive/data            |         39 | 277.86 us     | 7.12 us     | 16.18 us    | 0 ps         | 0 ps          | 277.86 us    |          0 | 0 bytes    | 0 bytes   |           0 | 0 bytes       | 0 bytes     |
 * | sql/pid                 |          3 | 218.03 us     | 72.68 us    | 154.84 us   | 0 ps         | 21.64 us      | 196.39 us    |          0 | 0 bytes    | 0 bytes   |           1 | 6 bytes       | 6 bytes     |
 * | sql/casetest            |          5 | 197.15 us     | 39.43 us    | 126.31 us   | 0 ps         | 0 ps          | 197.15 us    |          0 | 0 bytes    | 0 bytes   |           0 | 0 bytes       | 0 bytes     |
 * | sql/global_ddl_log      |          2 | 14.60 us      | 7.30 us     | 12.12 us    | 0 ps         | 0 ps          | 14.60 us     |          0 | 0 bytes    | 0 bytes   |           0 | 0 bytes       | 0 bytes     |
 * +-------------------------+------------+---------------+-------------+-------------+--------------+---------------+--------------+------------+------------+-----------+-------------+---------------+-------------+
 * 17 rows in set (0.00 sec)
 *
 * (Example from 5.6.6)
 *
 * Versions: 5.6+
 */

DROP VIEW IF EXISTS io_global_by_wait_by_latency;

CREATE SQL SECURITY INVOKER VIEW io_global_by_wait_by_latency AS
SELECT SUBSTRING_INDEX(event_name, '/', -2) event_name,
       count_star,
       sys.format_time(sum_timer_wait) total_latency,
       sys.format_time(avg_timer_wait) avg_latency,
       sys.format_time(max_timer_wait) max_latency,
       sys.format_time(sum_timer_read) read_latency,
       sys.format_time(sum_timer_write) write_latency,
       sys.format_time(sum_timer_misc) misc_latency,
       count_read,
       sys.format_bytes(sum_number_of_bytes_read) total_read,
       sys.format_bytes(IFNULL(sum_number_of_bytes_read / count_read, 0)) avg_read,
       count_write,
       sys.format_bytes(sum_number_of_bytes_write) total_written,
       sys.format_bytes(IFNULL(sum_number_of_bytes_write / count_write, 0)) avg_written
  FROM performance_schema.file_summary_by_event_name 
 WHERE event_name LIKE 'wait/io/file/%'
   AND count_star > 0
 ORDER BY sum_timer_wait DESC;

/*
 * View: io_global_by_wait_by_latency_raw
 *
 * Show the top global IO consumers by latency, without any formatting
 *
 * mysql> select * from io_global_by_wait_by_latency_raw;
 * +-------------------------+------------+----------------+-------------+--------------+--------------+---------------+----------------+------------+------------+------------+-------------+---------------+-------------+
 * | event_name              | count_star | total_latency  | avg_latency | max_latency  | read_latency | write_latency | misc_latency   | count_read | total_read | avg_read   | count_write | total_written | avg_written |
 * +-------------------------+------------+----------------+-------------+--------------+--------------+---------------+----------------+------------+------------+------------+-------------+---------------+-------------+
 * | sql/file_parser         |       5945 | 33615441247050 |  5654405471 | 203652881640 |  22093704230 |   27389668280 | 33565957874540 |         26 |       7008 |   269.5385 |         808 |       2479209 |   3068.3280 |
 * | sql/FRM                 |       6332 |  1755386796800 |   277224688 | 145624702340 | 519139578620 |    1677016640 |  1234570201540 |       2040 |     865905 |   424.4632 |         439 |        103445 |    235.6378 |
 * | innodb/innodb_data_file |       1344 |  1522989889460 |  1133176798 | 350700491310 | 203817502460 |  450959403830 |   868212983170 |        147 |    2408448 | 16384.0000 |        1001 |      56213504 |  56157.3467 |
 * | innodb/innodb_log_file  |        828 |   893475794640 |  1079076921 |  30108124800 |  16315236730 |  705886928240 |   171273629670 |          6 |      69632 | 11605.3333 |         413 |       2294272 |   5555.1380 |
 * | myisam/kfile            |       7826 |   246001992860 |    31433883 |  19265276810 |  74419162870 |   23923730090 |   147659099900 |        770 |     141058 |   183.1922 |        4516 |        249602 |     55.2706 |
 * | myisam/dfile            |      13431 |   228191713620 |    16989882 |  32500163410 |  89162969350 |   17341973610 |   121686770660 |       5819 |    4873176 |   837.4594 |        1577 |       2853444 |   1809.4128 |
 * | csv/metadata            |          8 |    28975194560 |  3621899320 |  20148109020 |    399265620 |             0 |    28575928940 |          2 |         70 |    35.0000 |           0 |             0 |      0.0000 |
 * | mysys/charset           |          3 |    24244722970 |  8081574072 |  24151547420 |  24151547420 |             0 |       93175550 |          1 |      17722 | 17722.0000 |           0 |             0 |      0.0000 |
 * | sql/ERRMSG              |          5 |    20427386850 |  4085477370 |  19312386730 |  20324183100 |             0 |      103203750 |          3 |      60390 | 20130.0000 |           0 |             0 |      0.0000 |
 * | mysys/cnf               |          5 |    11366169230 |  2273233846 |  11283602460 |  11287953040 |             0 |       78216190 |          3 |         56 |    18.6667 |           0 |             0 |      0.0000 |
 * | sql/dbopt               |         57 |     4042348570 |    70918224 |    843703380 |            0 |     186430270 |     3855918300 |          0 |          0 |     0.0000 |           7 |           431 |     61.5714 |
 * | csv/data                |          4 |      411548280 |   102887070 |    234886080 |            0 |             0 |      411548280 |          0 |          0 |     0.0000 |           0 |             0 |      0.0000 |
 * | sql/misc                |         24 |      369128240 |    15380092 |     33771660 |            0 |             0 |      369128240 |          0 |          0 |     0.0000 |           0 |             0 |      0.0000 |
 * | archive/data            |         39 |      277856540 |     7124169 |     16180840 |            0 |             0 |      277856540 |          0 |          0 |     0.0000 |           0 |             0 |      0.0000 |
 * | sql/pid                 |          3 |      218026640 |    72675421 |    154841440 |            0 |      21639800 |      196386840 |          0 |          0 |     0.0000 |           1 |             6 |      6.0000 |
 * | sql/casetest            |          5 |      197152150 |    39430430 |    126310080 |            0 |             0 |      197152150 |          0 |          0 |     0.0000 |           0 |             0 |      0.0000 |
 * | sql/global_ddl_log      |          2 |       14604980 |     7302490 |     12120550 |            0 |             0 |       14604980 |          0 |          0 |     0.0000 |           0 |             0 |      0.0000 |
 * +-------------------------+------------+----------------+-------------+--------------+--------------+---------------+----------------+------------+------------+------------+-------------+---------------+-------------+
 * 17 rows in set (0.00 sec)
 *
 * (Example from 5.6.6)
 *
 * Versions: 5.6+
 */

DROP VIEW IF EXISTS io_global_by_wait_by_latency_raw;

CREATE SQL SECURITY INVOKER VIEW io_global_by_wait_by_latency_raw AS
SELECT SUBSTRING_INDEX(event_name, '/', -2) event_name,
       count_star,
       sum_timer_wait total_latency,
       avg_timer_wait avg_latency,
       max_timer_wait max_latency,
       sum_timer_read read_latency,
       sum_timer_write write_latency,
       sum_timer_misc misc_latency,
       count_read,
       sum_number_of_bytes_read total_read,
       IFNULL(sum_number_of_bytes_read / count_read, 0) avg_read,
       count_write,
       sum_number_of_bytes_write total_written,
       IFNULL(sum_number_of_bytes_write / count_write, 0) avg_written
  FROM performance_schema.file_summary_by_event_name 
 WHERE event_name LIKE 'wait/io/file/%'
   AND count_star > 0
 ORDER BY sum_timer_wait DESC;