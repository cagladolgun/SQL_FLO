-- Ka� farkl� m��terinin al��veri� yapt���n� g�sterecek sorguyu yaz�n�z.
SELECT
  COUNT(DISTINCT(master_id)) AS K�S�_SAY�S�
  FROM flo_data_20K
  SELECT * FROM flo_data_20K
--Toplam yap�lan al��veri� say�s� ve ciroyu getirecek sorguyu yaz�n�z.
SELECT
  SUM(order_num_total_ever_online + order_num_total_ever_offline) AS TOPLAM_ALISVERIS,
  ROUND(SUM(customer_value_total_ever_offline + customer_value_total_ever_online), 2) AS TOPLAM_CIRO
  FROM flo_data_20k;
  SELECT * FROM flo_data_20K
--Al��veri� ba��na ortalama ciroyu getirecek sorguyu yaz�n�z. 
SELECT 
   ROUND(SUM(customer_value_total_ever_offline + customer_value_total_ever_online)/ SUM(order_num_total_ever_online + order_num_total_ever_offline), 2) AS ORTALAMA_CIRO
   FROM flo_data_20K
   SELECT * FROM flo_data_20K
-- En son al��veri� yap�lan kanal (last_order_channel) �zerinden yap�lan al��veri�lerin toplam ciro ve al��veri� say�lar�n� getirecek sorguyu yaz�n�z
SELECT
last_order_channel AS EN_SON_ALISVERIS_KANALI,
   SUM(customer_value_total_ever_offline + customer_value_total_ever_online) AS TOPLAM_CIRO,
   SUM(order_num_total_ever_online + order_num_total_ever_offline) AS ALISVERIS_SAYISI
   FROM flo_data_20K
   GROUP BY last_order_channel
-- Store type k�r�l�m�nda elde edilen toplam ciroyu getiren sorguyu yaz�n�z.
SELECT
   store_type AS COMPANY,
   SUM(customer_value_total_ever_offline + customer_value_total_ever_online) AS TOPLAM_CIRO
   FROM flo_data_20K
   GROUP BY store_type
-- Y�l k�r�l�m�nda al��veri� say�lar�n� getirecek sorguyu yaz�n�z (Y�l olarak m��terinin ilk al��veri� tarihi (first_order_date) y�l�n� baz al�n�z)
SELECT
   YEAR(first_order_date) AS YIL,
   SUM(order_num_total_ever_online + order_num_total_ever_offline) AS ALISVERIS_SAYISI
   FROM flo_data_20K
   GROUP BY YEAR(first_order_date)
--En son al��veri� yap�lan kanal k�r�l�m�nda al��veri� ba��na ortalama ciroyu hesaplayacak sorguyu yaz�n�z. 
SELECT
   last_order_channel AS EN_SON_ALISVERIS_KANALI,
   ROUND(SUM(customer_value_total_ever_offline + customer_value_total_ever_online)/ SUM(order_num_total_ever_online + order_num_total_ever_offline), 2) AS ORTALAMA_CIRO
   FROM flo_data_20K
   GROUP BY last_order_channel 
-- Son 12 ayda en �ok ilgi g�ren kategoriyi getiren sorguyu yaz�n�z.
SELECT 
    interested_in_categories_12 AS SON_BIR_YILDA_ALISVERIS_YAPTIGI_KATEGORI,
	COUNT (*) FREKANS_BILGISI 
	FROM flo_data_20K
	GROUP BY interested_in_categories_12
	ORDER BY 2 DESC;
-- En �ok tercih edilen store_type bilgisini getiren sorguyu yaz�n�z.
SELECT TOP 1
   store_type, 
   COUNT (*) FREKANS_BILGISI
   FROM flo_data_20K
   GROUP BY store_type
   ORDER BY FREKANS_BILGISI DESC;
-- En son al��veri� yap�lan kanal (last_order_channel) baz�nda, en �ok ilgi g�ren kategoriyi ve bu kategoriden ne kadarl�k al��veri� yap�ld���n� getiren sorguyu yaz�n�z
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
-- En �ok al��veri� yapan ki�inin ID� sini getiren sorguyu yaz�n�z.
SELECT TOP 1 master_id 
FROM flo_data_20K
GROUP BY master_id 
ORDER BY SUM(order_num_total_ever_online+order_num_total_ever_offline) DESC
--  En �ok al��veri� yapan ki�inin al��veri� ba��na ortalama cirosunu ve al��veri� yapma g�n ortalamas�n� (al��veri� s�kl���n�) getiren sorguyu yaz�n�z.
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
--En �ok al��veri� yapan (ciro baz�nda) ilk 100 ki�inin al��veri� yapma g�n ortalamas�n� (al��veri� s�kl���n�) getiren sorguyu yaz�n�z. 
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
-- En son al��veri� yap�lan kanal (last_order_channel) k�r�l�m�nda en �ok al��veri� yapan m��teriyi getiren sorguyu yaz�n�z.
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
--En son al��veri� yapan ki�inin ID� sini getiren sorguyu yaz�n�z. (Max son tarihte birden fazla al��veri� yapan ID bulunmakta. Bunlar� da getiriniz.)
SELECT master_id,last_order_date 
FROM flo_data_20K
WHERE last_order_date=(SELECT MAX(last_order_date) 
FROM flo_data_20K)













   




  




 
