SELECT 
    loan_risk_tier AS Borc_Yükü_Səviyyəsi,
    CASE WHEN cb_person_default_on_file = 1 THEN 'Bəli' ELSE 'Xeyr' END AS Keçmişdə_Defolt_Olub,
    COUNT(*) AS Müştəri_Sayı,
    ROUND(AVG(loan_status) * 100, 2) AS Cari_Defolt_Faizi_Pct
FROM cleaned_credit_risk_dataset
GROUP BY loan_risk_tier, cb_person_default_on_file
ORDER BY loan_risk_tier, Cari_Defolt_Faizi_Pct DESC;