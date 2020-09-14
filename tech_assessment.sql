

drop table xchange_rate;
create table xchange_rate (
date date, 
currency varchar(12), 
rate float
);


copy mkim.xchange_rate from local '/Users/mkim/Documents/exchange_rates.csv' delimiter ',' enclosed by '"' skip 1;
+-------------+
| Rows Loaded |
+-------------+
|        1176 |
+-------------+


drop table transaction_1;
create table transaction_1 (
buyer_id int, 
buyer_country varchar(12),
seller_id int, 
seller_country varchar(12),
product_id int, 
category varchar(256),
brand varchar(256),
purchase_date date, 
currency varchar(12),
value_of_item float 
);



copy mkim.transaction_1 from local '/Users/mkim/Documents/transactions_1.csv' delimiter ',' enclosed by '"' skip 1;
+-------------+
| Rows Loaded |
+-------------+
|       74948 |
+-------------+


drop table transaction_2;
create table transaction_2 (
buyer_id int, 
buyer_country varchar(12),
seller_id int, 
seller_country varchar(12),
product_id int, 
category varchar(256),
brand varchar(256),
purchase_date date, 
currency varchar(12),
value_of_item float 
);



copy mkim.transaction_2 from local '/Users/mkim/Documents/transactions_2.csv' delimiter ',' enclosed by '"' skip 1;
+-------------+
| Rows Loaded |
+-------------+
|       11804 |
+-------------+



drop table transaction_3;
create table transaction_3 (
buyer_id int, 
buyer_country varchar(12),
seller_id int, 
seller_country varchar(12),
product_id int, 
category varchar(256),
brand varchar(256),
purchase_date date, 
currency varchar(12),
value_of_item float 
);



copy mkim.transaction_3 from local '/Users/mkim/Documents/transactions_3.csv' delimiter ',' enclosed by '"' skip 1;
+-------------+
| Rows Loaded |
+-------------+
|       75921 |
+-------------+



drop table transaction_4;
create table transaction_4 (
buyer_id int, 
buyer_country varchar(12),
seller_id int, 
seller_country varchar(12),
product_id int, 
category varchar(256),
brand varchar(256),
purchase_date date, 
currency varchar(12),
value_of_item float 
);



copy mkim.transaction_4 from local '/Users/mkim/Documents/transactions_4.csv' delimiter ',' enclosed by '"' skip 1;
+-------------+
| Rows Loaded |
+-------------+
|       74998 |
+-------------+

--total rows loaded: 238,847


drop table if exists total_transactions;
create local temp table total_transactions on commit preserve rows as ( 
select * from transaction_1 
union all 
select * from transaction_2 
union all 
select * from transaction_3 
union all 
select * from transaction_4);

select count(seller_id), count(distinct seller_id) from total_transactions;
+--------+--------+
| count  | count  |
+--------+--------+
| 237671 | 114227 |
+--------+--------+

select sum(t.value_of_item/x.rate) as total_value_of_sales 
from total_transactions t
join xchange_rate x on x.currency = t.currency and t.purchase_date = x.date ;
+----------------------+
| total_value_of_sales |
+----------------------+
|     5453914.78621849 |
+----------------------+

--top 5 brands by # purchases
select 
  brand, 
  count(*) as purchases
from 
  total_transactions 
where 
  brand in ('Dr. Martens', 'Adidas', 'Vans')
group by 1 
order by 2 desc;
+-------------+-----------+
|    brand    | purchases |
+-------------+-----------+
| Adidas      |      3905 |
| Vans        |      1998 |
| Dr. Martens |      1177 |
+-------------+-----------+


select count(distinct product_id) 
from total_transactions 
where category = 'Tops - Womens' and brand is null;
+-------+
| count |
+-------+
| 20242 |
+-------+


with brands as ( 
select brand
from total_transactions 
group by 1
having count(*) between 20 and 30)
select count(*) from brands;
+-------+
| count |
+-------+
|    85 |
+-------+


select count(*) from total_transactions 
where buyer_country = 'IT' and category = 'Shoes';
+-------+
| count |
+-------+
|   329 |
+-------+


select 
  t.seller_country, 
  avg(t.value_of_item/x.rate) as avg_transaction_value 
from 
  total_transactions t 
join 
  xchange_rate x on x.currency = t.currency and x.date = t.purchase_date
where 
  t.seller_country in ('FR', 'DE', 'GB')
group by 1 
order by 2 desc;
+----------------+-----------------------+
| seller_country | avg_transaction_value |
+----------------+-----------------------+
| FR             |      62.4900623805648 |
| DE             |       43.531304269194 |
| GB             |      22.4419418894892 |
+----------------+-----------------------+



select 
  t.brand, 
  avg(t.value_of_item/x.rate) as avg_transaction_value 
from 
  total_transactions t 
join 
  xchange_rate x on x.currency = t.currency and x.date = t.purchase_date
where 
  t.brand in ('Loewe', 'Nike', 'Goyard')
group by 1 
order by 2 desc;
+--------+-----------------------+
| brand  | avg_transaction_value |
+--------+-----------------------+
| Goyard |      289.390018822789 |
| Loewe  |                   275 |
| Nike   |       33.551592928467 |
+--------+-----------------------+


select sum(t.value_of_item/x.rate) as value
from total_transactions t 
join xchange_rate x on x.currency = t.currency and x.date = t.purchase_date
where t.buyer_country = 'US' and t.seller_country = 'US';
+------------------+
|      value       |
+------------------+
| 1786466.51573699 |
+------------------+


select 
  count(case when buyer_country = 'GB' then product_id end)/count(product_id) as perc_gb_buyers 
from 
  total_transactions 
where 
  seller_country = 'GB';
+----------------------+
|    perc_gb_buyers    |
+----------------------+
| 0.961732146577300777 |
+----------------------+


with base as (
select 
  buyer_country,
  count(case when buyer_country != seller_country then product_id end)/count(product_id) as perc_intl
from 
  total_transactions 
group by 1) 
select * from base where buyer_country in ('FR', 'GB', 'AU');
+---------------+----------------------+
| buyer_country |      perc_intl       |
+---------------+----------------------+
| FR            | 0.940074906367041199 |
| GB            | 0.006146810785128875 |
| AU            | 0.073589222165734621 |
+---------------+----------------------+


select 
  t.purchase_date, 
  sum(t.value_of_item/x.rate) as total_value 
from 
  total_transactions t 
join 
  xchange_rate x on t.currency = x.currency and t.purchase_date = x.date 
group by 1 
order by 2 desc;
+---------------+------------------+
| purchase_date |   total_value    |
+---------------+------------------+
| 2019-08-01    | 843461.521720416 |
| 2019-08-06    | 833302.560188703 |
| 2019-08-05    | 813330.759189677 |
| 2019-08-07    | 797378.343082755 |
| 2019-08-02    | 788491.603555506 |
| 2019-08-04    |  724748.69112057 |
| 2019-08-03    | 653201.307360862 |
+---------------+------------------+



with base as ( 
select 
  avg(t.value_of_item/x.rate) as avg_value 
from 
  total_transactions t 
join 
  xchange_rate x on t.currency = x.currency and t.purchase_date = x.date 
),
by_purch_date as ( 
select 
  t.purchase_date, 
  avg(t.value_of_item/x.rate) as total_value 
from 
  total_transactions t 
join 
  xchange_rate x on t.currency = x.currency and t.purchase_date = x.date 
group by 1 
),
semi as (
select * from by_purch_date 
cross join base order by 1)
select *, total_value-avg_value as value_diff 
from semi
order by value_diff;
+---------------+------------------+------------------+---------------------+
| purchase_date |   total_value    |    avg_value     |     value_diff      |
+---------------+------------------+------------------+---------------------+
| 2019-08-04    | 22.2049906896832 | 22.9473296540953 |  -0.742338964412117 |
| 2019-08-05    | 22.7536930812611 | 22.9473296540953 |  -0.193636572834262 |
| 2019-08-06    | 22.8045910125257 | 22.9473296540953 |  -0.142738641569579 |
| 2019-08-07    | 22.9368986043825 | 22.9473296540953 | -0.0104310497127855 |
| 2019-08-03    | 23.0756105331142 | 22.9473296540953 |   0.128280879018828 |
| 2019-08-01    | 23.3322689272591 | 22.9473296540953 |   0.384939273163759 |
| 2019-08-02    | 23.5195109188816 | 22.9473296540953 |   0.572181264786298 |
+---------------+------------------+------------------+---------------------+


select 
  category, 
  count(*) as transactions 
from 
  total_transactions 
where 
  purchase_date = '2019-08-03' 
group by 1
order by 2 desc;
+-------------------+--------------+
|     category      | transactions |
+-------------------+--------------+
| Tops - Womens     |         5449 |
| Tops - Mens       |         4019 |
| Bottoms - Womens  |         3477 |
| Accessories       |         2603 |
| Shoes             |         2542 |
| Dresses           |         2091 |
| Jewellery         |         1850 |
| Beauty            |          998 |
| Other             |          882 |
| Outerwear         |          715 |
| Bottoms - Mens    |          712 |
| Lingerie          |          569 |
| Outerwear - Mens  |          537 |
| Home              |          410 |
| Tech              |          408 |
| Music             |          318 |
| Kids              |          236 |
| Art               |          217 |
| Books & magazines |          141 |
| Film              |           63 |
| Sports equipment  |           44 |
| Underwear         |           20 |
| Transportation    |            3 |
| NULL              |            2 |
| UNSPECIFIED       |            1 |
+-------------------+--------------+


select 
  count(case when seller_country = 'GB' then product_id end)/count(product_id) as perc_from_gb_sellers 
from 
  total_transactions;
+----------------------+
| perc_from_gb_sellers |
+----------------------+
| 0.585696193477538278 |
+----------------------+


with base as ( 
select seller_id 
from total_transactions 
where seller_country = 'GB'
group by 1
having count(*)>100)
select count(*) from base;
+-------+
| count |
+-------+
|    30 |
+-------+


with base as ( 
select 
  t.seller_id, 
  sum(t.value_of_item/x.rate) as total_value 
from 
  total_transactions t 
join 
  xchange_rate x on t.currency = x.currency and t.purchase_date = x.date 
where 
  seller_country = 'US'
group by 1) 
select * from base where seller_id in (4166362,3166396,2692588) order by 2 desc;

+-----------+------------------+
| seller_id |   total_value    |
+-----------+------------------+
|   2692588 | 18125.9368741606 |
|   4166362 | 7954.42075168484 |
|   3166396 | 4189.30402835888 |
+-----------+------------------+


with base as ( 
select 
  t.brand, 
  avg(case when t.buyer_country = t.seller_country then t.value_of_item/x.rate end) as dom_value, 
  avg(case when t.buyer_country != t.seller_country then t.value_of_item/x.rate end) as intl_value 
from 
  total_transactions t 
join 
  xchange_rate x on t.currency = x.currency and t.purchase_date = x.date
group by 1)
,value_diff as ( 
select 
  *, 
  abs(dom_value-intl_value) as abs_diff 
from 
  base 
  	)
select * from value_diff where brand in ('Canada Goose', 'Goyard', 'Loewe') order by 4 desc;

+--------------+------------------+------------+------------------+
|    brand     |    dom_value     | intl_value |     abs_diff     |
+--------------+------------------+------------+------------------+
| Goyard       | 179.085028234183 |        510 | 330.914971765817 |
| Loewe        |               65 |        380 |              315 |
| Canada Goose | 180.043335398487 |       4.95 | 175.093335398487 |
+--------------+------------------+------------+------------------+



