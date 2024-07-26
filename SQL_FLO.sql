-- Kaç farklý müþterinin alýþveriþ yaptýðýný gösterecek sorguyu yazýnýz.
SELECT
  COUNT(DISTINCT(master_id)) AS KÝSÝ_SAYÝSÝ
  FROM flo_data_20K
  SELECT * FROM flo_data_20K
--Toplam yapýlan alýþveriþ sayýsý ve ciroyu getirecek sorguyu yazýnýz.
SELECT
  SUM(order_num_total_ever_online + order_num_total_ever_offline) AS TOPLAM_ALISVERIS,
  ROUND(SUM(customer_value_total_ever_offline + customer_value_total_ever_online), 2) AS TOPLAM_CIRO
  FROM flo_data_20k;
  SELECT * FROM flo_data_20K
--Alýþveriþ baþýna ortalama ciroyu getirecek sorguyu yazýnýz. 
SELECT 
   ROUND(SUM(customer_value_total_ever_offline + customer_value_total_ever_online)/ SUM(order_num_total_ever_online + order_num_total_ever_offline), 2) AS ORTALAMA_CIRO
   FROM flo_data_20K
   SELECT * FROM flo_data_20K
-- En son alýþveriþ yapýlan kanal (last_order_channel) üzerinden yapýlan alýþveriþlerin toplam ciro ve alýþveriþ sayýlarýný getirecek sorguyu yazýnýz
SELECT
last_order_channel AS EN_SON_ALISVERIS_KANALI,
   SUM(customer_value_total_ever_offline + customer_value_total_ever_online) AS TOPLAM_CIRO,
   SUM(order_num_total_ever_online + order_num_total_ever_offline) AS ALISVERIS_SAYISI
   FROM flo_data_20K
   GROUP BY last_order_channel
-- Store type kýrýlýmýnda elde edilen toplam ciroyu getiren sorguyu yazýnýz.
SELECT
   store_type AS COMPANY,
   SUM(customer_value_total_ever_offline + customer_value_total_ever_online) AS TOPLAM_CIRO
   FROM flo_data_20K
   GROUP BY store_type
-- Yýl kýrýlýmýnda alýþveriþ sayýlarýný getirecek sorguyu yazýnýz (Yýl olarak müþterinin ilk alýþveriþ tarihi (first_order_date) yýlýný baz alýnýz)
SELECT
   YEAR(first_order_date) AS YIL,
   SUM(order_num_total_ever_online + order_num_total_ever_offline) AS ALISVERIS_SAYISI
   FROM flo_data_20K
   GROUP BY YEAR(first_order_date)
--En son alýþveriþ yapýlan kanal kýrýlýmýnda alýþveriþ baþýna ortalama ciroyu hesaplayacak sorguyu yazýnýz. 
SELECT
   last_order_channel AS EN_SON_ALISVERIS_KANALI,
   ROUND(SUM(customer_value_total_ever_offline + customer_value_total_ever_online)/ SUM(order_num_total_ever_online + order_num_total_ever_offline), 2) AS ORTALAMA_CIRO
   FROM flo_data_20K
   GROUP BY last_order_channel 
-- Son 12 ayda en çok ilgi gören kategoriyi getiren sorguyu yazýnýz.
SELECT 
    interested_in_categories_12 AS SON_BIR_YILDA_ALISVERIS_YAPTIGI_KATEGORI,
	COUNT (*) FREKANS_BILGISI 
	FROM flo_data_20K
	GROUP BY interested_in_categories_12
	ORDER BY 2 DESC;
-- En çok tercih edilen store_type bilgisini getiren sorguyu yazýnýz.
SELECT TOP 1
   store_type, 
   COUNT (*) FREKANS_BILGISI
   FROM flo_data_20K
   GROUP BY store_type
   ORDER BY FREKANS_BILGISI DESC;
-- En son alýþveriþ yapýlan kanal (last_order_channel) bazýnda, en çok ilgi gören kategoriyi ve bu kategoriden ne kadarlýk alýþveriþ yapýldýðýný getiren sorguyu yazýnýz
SELECT DISTINCT last_order_channel,
       (
	SELECT top 1 interested_in_categories_12
	FROM flo_data_20K  
	WHERE last_order_channel=f.last_order_channel
	group by interested_in_categories_12
	order by 
	SUM(order_num_total_ever_online+order_num_total_ever_offline) desc 
),
(
	SELECT top 1 SUM(order_num_total_ever_online+order_num_total_ever_offline)
	FROM flo_data_20K  
	WHERE last_order_channel=f.last_order_channel
	group by interested_in_categories_12
	order by 
	SUM(order_num_total_ever_online+order_num_total_ever_offline) desc 
)
FROM flo_data_20K F
-- En çok alýþveriþ yapan kiþinin ID’ sini getiren sorguyu yazýnýz.
SELECT TOP 1 master_id 
FROM flo_data_20K
GROUP BY master_id 
ORDER BY SUM(order_num_total_ever_online+order_num_total_ever_offline) DESC
--  En çok alýþveriþ yapan kiþinin alýþveriþ baþýna ortalama cirosunu ve alýþveriþ yapma gün ortalamasýný (alýþveriþ sýklýðýný) getiren sorguyu yazýnýz.
SELECT D.master_id,
ROUND((D.TOPLAM_CIRO / D.TOPLAM_SIPARIS_SAYISI),2) SIPARIS_BASINA_ORTALAMA,
ROUND((DATEDIFF(DAY, first_order_date, last_order_date)/D.TOPLAM_SIPARIS_SAYISI ),1) ALISVERIS_GUN_ORT
FROM
(
SELECT TOP 1 master_id, first_order_date, last_order_date,
		   SUM(customer_value_total_ever_offline +customer_value_total_ever_online) TOPLAM_CIRO,
		   SUM(order_num_total_ever_offline + order_num_total_ever_online) TOPLAM_SIPARIS_SAYISI
	FROM flo_data_20K 
	GROUP BY master_id,first_order_date, last_order_date
ORDER BY TOPLAM_CIRO DESC
) D
--En çok alýþveriþ yapan (ciro bazýnda) ilk 100 kiþinin alýþveriþ yapma gün ortalamasýný (alýþveriþ sýklýðýný) getiren sorguyu yazýnýz. 
SELECT  
D.master_id,
       D.TOPLAM_CIRO,
	   D.TOPLAM_SIPARIS_SAYISI,
       ROUND((D.TOPLAM_CIRO / D.TOPLAM_SIPARIS_SAYISI),2) SIPARIS_BASINA_ORTALAMA,
	   DATEDIFF(DAY, first_order_date, last_order_date) ILK_SN_ALVRS_GUN_FRK,
	  ROUND((DATEDIFF(DAY, first_order_date, last_order_date)/D.TOPLAM_SIPARIS_SAYISI ),1) ALISVERIS_GUN_ORT	 
  FROM
(
SELECT TOP 100 master_id, first_order_date, last_order_date,
		   SUM(customer_value_total_ever_offline + customer_value_total_ever_online) TOPLAM_CIRO,
		   SUM(order_num_total_ever_offline + order_num_total_ever_online) TOPLAM_SIPARIS_SAYISI
	FROM flo_data_20K 
	GROUP BY master_id,first_order_date, last_order_date
ORDER BY TOPLAM_CIRO DESC
) D
-- En son alýþveriþ yapýlan kanal (last_order_channel) kýrýlýmýnda en çok alýþveriþ yapan müþteriyi getiren sorguyu yazýnýz.
SELECT DISTINCT last_order_channel,
(
	SELECT top 1 master_id
	FROM flo_data_20K  
	WHERE last_order_channel=f.last_order_channel
	group by master_id
	order by 
	SUM(customer_value_total_ever_offline+customer_value_total_ever_online) desc 
) EN_COK_ALISVERIS_YAPAN_MUSTERI,
(
	SELECT top 1 SUM(customer_value_total_ever_offline+customer_value_total_ever_online)
	FROM flo_data_20K  
	WHERE last_order_channel=f.last_order_channel
	group by master_id
	order by 
	SUM(customer_value_total_ever_offline+customer_value_total_ever_online) desc 
) CIRO
FROM flo_data_20K F
--En son alýþveriþ yapan kiþinin ID’ sini getiren sorguyu yazýnýz. (Max son tarihte birden fazla alýþveriþ yapan ID bulunmakta. Bunlarý da getiriniz.)
SELECT master_id,last_order_date 
FROM flo_data_20K
WHERE last_order_date=(SELECT MAX(last_order_date) 
FROM flo_data_20K)













   




  




 
